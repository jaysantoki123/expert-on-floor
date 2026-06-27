import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';
import { Conversation, Message, User } from './models/index.js';
import { Op } from 'sequelize';

let io = null;

export const initSocket = (server) => {
  io = new Server(server, {
    cors: {
      origin: '*',
      methods: ['GET', 'POST'],
      credentials: true
    }
  });

  // Share io globally if needed
  global.io = io;

  // Authentication Middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token || 
                    socket.handshake.headers?.authorization?.split(' ')[1] ||
                    socket.handshake.query?.token;

      if (!token) {
        return next(new Error('Authentication error: Token required'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findByPk(decoded.id);
      if (!user) {
        return next(new Error('Authentication error: User not found'));
      }

      socket.user = user;
      socket.userId = user.id;
      next();
    } catch (err) {
      console.error('Socket authentication error:', err.message);
      return next(new Error('Authentication error: Invalid or expired token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 Client connected: ${socket.userId} (${socket.user.name})`);

    // Join user-specific room for direct notifications/messages
    socket.join(`user_${socket.userId}`);

    // Join a conversation room
    socket.on('join_conversation', ({ conversationId }) => {
      if (conversationId) {
        socket.join(`conversation_${conversationId}`);
        console.log(`👥 User ${socket.userId} joined conversation room: ${conversationId}`);
      }
    });

    // Leave a conversation room
    socket.on('leave_conversation', ({ conversationId }) => {
      if (conversationId) {
        socket.leave(`conversation_${conversationId}`);
        console.log(`👥 User ${socket.userId} left conversation room: ${conversationId}`);
      }
    });

    // Handle incoming real-time message via socket
    socket.on('send_message', async (data, callback) => {
      try {
        const { conversationId, recipientId, text } = data;
        if (!text || (!conversationId && !recipientId)) {
          return callback?.({ success: false, error: 'Invalid message data' });
        }

        let convId = conversationId;

        // If conversation ID is not provided, check or create conversation
        if (!convId && recipientId) {
          let conversation = await Conversation.findOne({
            where: {
              [Op.or]: [
                { participant1Id: socket.userId, participant2Id: recipientId },
                { participant1Id: recipientId, participant2Id: socket.userId }
              ]
            }
          });

          if (!conversation) {
            conversation = await Conversation.create({
              participant1Id: socket.userId,
              participant2Id: recipientId,
              lastMessage: text,
              lastMessageAt: new Date()
            });
          }
          convId = conversation.id;
        }

        // Create message in DB
        const message = await Message.create({
          conversationId: convId,
          senderId: socket.userId,
          text,
          type: 'text',
          isRead: false
        });

        // Update conversation last message
        await Conversation.update(
          { lastMessage: text, lastMessageAt: new Date() },
          { where: { id: convId } }
        );

        // Fetch full message details with sender attributes
        const fullMessage = await Message.findByPk(message.id, {
          include: [{ model: User, as: 'sender', attributes: ['id', 'name', 'profileImage'] }]
        });

        // Get target user
        const conversation = await Conversation.findByPk(convId);
        const targetUserId = conversation.participant1Id === socket.userId 
          ? conversation.participant2Id 
          : conversation.participant1Id;

        // Broadcast to the conversation room and target user room
        io.to(`conversation_${convId}`).emit('receive_message', fullMessage);
        io.to(`user_${targetUserId}`).emit('receive_message', fullMessage);
        
        // Also emit a notification event to the target user about new message/update
        io.to(`user_${targetUserId}`).emit('conversation_updated', {
          conversationId: convId,
          lastMessage: text,
          lastMessageAt: new Date(),
          senderId: socket.userId
        });

        // Acknowledge to client
        if (callback) {
          callback({ success: true, data: fullMessage });
        }
      } catch (err) {
        console.error('Socket send_message error:', err);
        if (callback) {
          callback({ success: false, error: err.message });
        }
      }
    });

    // Handle typing status
    socket.on('typing', ({ conversationId, isTyping }) => {
      if (conversationId) {
        socket.to(`conversation_${conversationId}`).emit('typing', {
          conversationId,
          userId: socket.userId,
          isTyping
        });
      }
    });

    // Handle marking messages as read
    socket.on('mark_as_read', async ({ conversationId }) => {
      try {
        if (!conversationId) return;

        // Update messages in DB
        await Message.update(
          { isRead: true },
          {
            where: {
              conversationId,
              senderId: { [Op.ne]: socket.userId },
              isRead: false
            }
          }
        );

        // Find the conversation and find the other user
        const conversation = await Conversation.findByPk(conversationId);
        if (conversation) {
          const otherUserId = conversation.participant1Id === socket.userId 
            ? conversation.participant2Id 
            : conversation.participant1Id;

          // Notify the other user that their messages were read
          io.to(`user_${otherUserId}`).emit('messages_read', { conversationId, readerId: socket.userId });
        }
      } catch (err) {
        console.error('Socket mark_as_read error:', err);
      }
    });

    socket.on('disconnect', () => {
      console.log(`🔌 Client disconnected: ${socket.userId}`);
    });
  });

  return io;
};

export const getIO = () => {
  if (!io) {
    throw new Error('Socket.io has not been initialized!');
  }
  return io;
};
