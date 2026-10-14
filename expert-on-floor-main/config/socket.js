import { Server } from 'socket.io';
import jwt from 'jsonwebtoken';
import { User, Conversation, Message } from '../models/index.js';
import { Op } from 'sequelize';
import xss from 'xss';

let io = null;

export const initSocket = (server) => {
  const allowedOrigins = (process.env.CORS_ORIGINS || 'http://localhost:3000')
    .split(',')
    .map(o => o.trim())
    .filter(Boolean);

  io = new Server(server, {
    cors: {
      origin: (origin, callback) => {
       
        if (!origin) return callback(null, true);
        if (allowedOrigins.includes(origin)) {
          return callback(null, origin);
        }
        return callback(new Error(`Origin ${origin} not allowed by CORS`));
      },
      methods: ['GET', 'POST'],
      credentials: true
    }
  });


  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token || socket.handshake.query?.token;
      if (!token) {
        return next(new Error('Authentication error: Token required'));
      }

      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      const user = await User.findByPk(decoded.id);
      if (!user) {
        return next(new Error('Authentication error: User not found'));
      }

      socket.user = user;
      next();
    } catch (err) {
      return next(new Error('Authentication error: Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    console.log(`🔌 User connected to socket: ${socket.user.name} (${socket.user.id})`);

    socket.join(`user_${socket.user.id}`);
  
    socket.on('join_conversation', async (conversationId) => {
      try {
        const conversation = await Conversation.findByPk(conversationId);
        if (!conversation) {
          return socket.emit('error', { message: 'Conversation not found' });
        }
        if (conversation.participant1Id !== socket.user.id && conversation.participant2Id !== socket.user.id) {
          return socket.emit('error', { message: 'Not authorized to join this conversation' });
        }
        socket.join(`conversation_${conversationId}`);
        console.log(`💬 User ${socket.user.id} joined conversation: ${conversationId}`);
      } catch (err) {
        socket.emit('error', { message: 'Failed to join conversation' });
      }
    });

    
    socket.on('leave_conversation', (conversationId) => {
      socket.leave(`conversation_${conversationId}`);
      console.log(`💬 User ${socket.user.id} left conversation: ${conversationId}`);
    });

    // Handle real-time messaging
    socket.on('send_message', async (data) => {
      try {
        const { conversationId, text, recipientId } = data;
        const safeText = xss(text);
        let convId = conversationId;
        let finalRecipientId = recipientId;

        if (!convId && finalRecipientId) {
          // Find or create conversation
          let conversation = await Conversation.findOne({
            where: {
              [Op.or]: [
                { participant1Id: socket.user.id, participant2Id: finalRecipientId },
                { participant1Id: finalRecipientId, participant2Id: socket.user.id }
              ]
            }
          });

          if (!conversation) {
            conversation = await Conversation.create({
              participant1Id: socket.user.id,
              participant2Id: finalRecipientId
            });
          }
          convId = conversation.id;
        } else if (convId && !finalRecipientId) {
          const conversation = await Conversation.findByPk(convId);
          if (conversation) {
            finalRecipientId = conversation.participant1Id === socket.user.id
              ? conversation.participant2Id
              : conversation.participant1Id;
          }
        }

        // Save message to database
        const message = await Message.create({
          conversationId: convId,
          senderId: socket.user.id,
          text: safeText,
          type: 'text'
        });

        // Update last message metadata
        await Conversation.update(
          { lastMessage: safeText, lastMessageAt: new Date() },
          { where: { id: convId } }
        );

        const sender = {
          name: socket.user.name,
          profileImage: socket.user.profileImage
        };

        const messageData = {
          ...message.toJSON(),
          sender
        };

        // Broadcast to conversation room members
        io.to(`conversation_${convId}`).emit('new_message', messageData);

        // Notify recipient in their personal room
        if (finalRecipientId) {
          io.to(`user_${finalRecipientId}`).emit('message_received', {
            conversationId: convId,
            message: messageData
          });
        }

      } catch (err) {
        console.error('Error sending message via socket:', err);
        socket.emit('error', { message: 'Failed to send message' });
      }
    });

    // ── WebRTC Signaling Events ───────────────────
    
    // Caller initiates a call to a recipient
    socket.on('call_user', (data) => {
      const { recipientId, conversationId, callerName, offer } = data;
      console.log(`📞 Socket: User ${socket.user.id} (${socket.user.name}) is calling User ${recipientId}`);
      io.to(`user_${recipientId}`).emit('call_received', {
        callerId: socket.user.id,
        callerName: callerName || socket.user.name,
        conversationId,
        offer
      });
    });

    // Recipient answers the call
    socket.on('answer_call', (data) => {
      const { callerId, answer } = data;
      console.log(`📞 Socket: User ${socket.user.id} answered call from User ${callerId}`);
      io.to(`user_${callerId}`).emit('call_answered', {
        recipientId: socket.user.id,
        answer
      });
    });

    // Exchange ICE candidates
    socket.on('ice_candidate', (data) => {
      const { targetId, candidate } = data;
      io.to(`user_${targetId}`).emit('ice_candidate_received', {
        senderId: socket.user.id,
        candidate
      });
    });

    // Recipient rejects the call
    socket.on('reject_call', (data) => {
      const { callerId } = data;
      console.log(`📞 Socket: User ${socket.user.id} rejected call from User ${callerId}`);
      io.to(`user_${callerId}`).emit('call_rejected', {
        recipientId: socket.user.id
      });
    });

    // Either party hangs up
    socket.on('hangup', (data) => {
      const { targetId } = data;
      console.log(`📞 Socket: Call hung up between User ${socket.user.id} and User ${targetId}`);
      io.to(`user_${targetId}`).emit('call_hungup', {
        senderId: socket.user.id
      });
    });

    socket.on('disconnect', () => {
      console.log(`🔌 User disconnected from socket: ${socket.user.name}`);
    });
  });

  return io;
};

export const getIO = () => {
  return io;
};
