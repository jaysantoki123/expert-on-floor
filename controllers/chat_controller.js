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

export const sendMessage = async (req, res) => {
  try {
    const { conversationId, text, recipientId } = req.body;
    let convId = conversationId;

    if (!convId && recipientId) {
      // Find or create conversation
      let conversation = await Conversation.findOne({
        where: {
          [Op.or]: [
            { participant1Id: req.user.id, participant2Id: recipientId },
            { participant1Id: recipientId, participant2Id: req.user.id }
          ]
        }
      });

      if (!conversation) {
        conversation = await Conversation.create({
          participant1Id: req.user.id,
          participant2Id: recipientId
        });
      }
      convId = conversation.id;
    }

    const message = await Message.create({
      conversationId: convId,
      senderId: req.user.id,
      text,
      type: 'text'
    });

    await Conversation.update(
      { lastMessage: text, lastMessageAt: new Date() },
      { where: { id: convId } }
    );

    res.status(201).json({ success: true, data: message });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
