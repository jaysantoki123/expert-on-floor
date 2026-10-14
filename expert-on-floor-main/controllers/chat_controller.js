import { Conversation, Message, User } from '../models/index.js';
import { Op } from 'sequelize';
import { getIO } from '../config/socket.js';
import xss from 'xss';

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
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getMessages = async (req, res) => {
  try {
    const { id } = req.params;
    const { before, limit = 50 } = req.query;

    // Verify the requesting user is a participant in this conversation
    const conversation = await Conversation.findByPk(id);
    if (!conversation) return res.status(404).json({ success: false, message: 'Conversation not found' });

    if (conversation.participant1Id !== req.user.id && conversation.participant2Id !== req.user.id) {
      return res.status(403).json({ success: false, message: 'Not authorized to view this conversation' });
    }

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
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { conversationId, text, recipientId } = req.body;
    const safeText = xss(text);
    let convId = conversationId;
    let finalRecipientId = recipientId;

    if (!convId && finalRecipientId) {
      // Find or create conversation
      let conversation = await Conversation.findOne({
        where: {
          [Op.or]: [
            { participant1Id: req.user.id, participant2Id: finalRecipientId },
            { participant1Id: finalRecipientId, participant2Id: req.user.id }
          ]
        }
      });

      if (!conversation) {
        conversation = await Conversation.create({
          participant1Id: req.user.id,
          participant2Id: finalRecipientId
        });
      }
      convId = conversation.id;
    } else if (convId && !finalRecipientId) {
      const conversation = await Conversation.findByPk(convId);
      if (!conversation) {
        return res.status(404).json({ success: false, message: 'Conversation not found' });
      }
      // Verify sender is a participant
      if (conversation.participant1Id !== req.user.id && conversation.participant2Id !== req.user.id) {
        return res.status(403).json({ success: false, message: 'Not authorized to send messages in this conversation' });
      }
      finalRecipientId = conversation.participant1Id === req.user.id
        ? conversation.participant2Id
        : conversation.participant1Id;
    }

    const message = await Message.create({
      conversationId: convId,
      senderId: req.user.id,
      text: safeText,
      type: 'text'
    });

    await Conversation.update(
      { lastMessage: safeText, lastMessageAt: new Date() },
      { where: { id: convId } }
    );

    const io = getIO();
    if (io) {
      const sender = {
        name: req.user.name,
        profileImage: req.user.profileImage
      };
      const messageData = {
        ...message.toJSON(),
        sender
      };

      io.to(`conversation_${convId}`).emit('new_message', messageData);

      if (finalRecipientId) {
        io.to(`user_${finalRecipientId}`).emit('message_received', {
          conversationId: convId,
          message: messageData
        });
      }
    }

    res.status(201).json({ success: true, data: message });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};
