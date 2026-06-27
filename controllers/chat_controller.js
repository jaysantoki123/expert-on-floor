import { Conversation, Message, User } from '../models/index.js';
import { Op } from 'sequelize';

export const getConversations = async (req, res) => {
  try {
    const conversations = await Conversation.findAll({
      where: {
        [Op.or]: [
          { participant1Id: req.user.id },
          { participant2Id: req.user.id }
        ]
      },
      include: [
        { model: User, as: 'participant1', attributes: ['id', 'name', 'profileImage'] },
        { model: User, as: 'participant2', attributes: ['id', 'name', 'profileImage'] }
      ],
      order: [['lastMessageAt', 'DESC']]
    });

    const data = conversations.map(c => {
      const otherParticipant = c.participant1Id === req.user.id ? c.participant2 : c.participant1;
      return {
        id: c.id,
        participant: otherParticipant,
        lastMessage: { text: c.lastMessage, timestamp: c.lastMessageAt },
        unreadCount: 0 // Simplified
      };
    });

    res.json({ success: true, data });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const getMessages = async (req, res) => {
  try {
    const { id } = req.params;
    const { before, limit = 50 } = req.query;
    
    const where = { conversationId: id };
    if (before) {
      where.createdAt = { [Op.lt]: new Date(before) };
    }

    const messages = await Message.findAll({
      where,
      limit: parseInt(limit),
      order: [['createdAt', 'DESC']],
      include: [{ model: User, as: 'sender', attributes: ['name', 'profileImage'] }]
    });

    res.json({ success: true, data: messages });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createMessage = async (senderId, { conversationId, recipientId, text }) => {
  let convId = conversationId;

  if (!convId && recipientId) {
    // Find or create conversation
    let conversation = await Conversation.findOne({
      where: {
        [Op.or]: [
          { participant1Id: senderId, participant2Id: recipientId },
          { participant1Id: recipientId, participant2Id: senderId }
        ]
      }
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participant1Id: senderId,
        participant2Id: recipientId
      });
    }
    convId = conversation.id;
  }

  const message = await Message.create({
    conversationId: convId,
    senderId,
    text,
    type: 'text'
  });

  await Conversation.update(
    { lastMessage: text, lastMessageAt: new Date() },
    { where: { id: convId } }
  );

  const fullMessage = await Message.findByPk(message.id, {
    include: [{ model: User, as: 'sender', attributes: ['id', 'name', 'profileImage'] }]
  });

  return { message: fullMessage, conversationId: convId };
};

export const sendMessage = async (req, res) => {
  try {
    const { conversationId, text, recipientId } = req.body;
    const { message, conversationId: finalConvId } = await createMessage(req.user.id, { conversationId, recipientId, text });

    // Broadcast message via Socket.io if active
    if (global.io) {
      const conversation = await Conversation.findByPk(finalConvId);
      const targetUserId = conversation.participant1Id === req.user.id 
        ? conversation.participant2Id 
        : conversation.participant1Id;

      global.io.to(`conversation_${finalConvId}`).emit('receive_message', message);
      global.io.to(`user_${targetUserId}`).emit('receive_message', message);
      
      global.io.to(`user_${targetUserId}`).emit('conversation_updated', {
        conversationId: finalConvId,
        lastMessage: text,
        lastMessageAt: new Date(),
        senderId: req.user.id
      });
    }

    res.status(201).json({ success: true, data: message });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
