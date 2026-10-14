import { CommunityPost, Answer, User } from '../models/index.js';
import { Op } from 'sequelize';
import { createNotification } from './notification_controller.js';
import xss from 'xss';
import { getIO } from '../config/socket.js';
import firebaseAdmin from '../config/firebase.js';
import { getMessaging } from 'firebase-admin/messaging';

// ─── Helper: Broadcast FCM + Socket to all users except the author ───────────
async function broadcastToAll(authorId, title, body, type) {
  try {
    const otherUsers = await User.findAll({
      where: { id: { [Op.ne]: authorId } },
      attributes: ['id', 'fcmToken']
    });

    // 1. Socket.IO broadcast — real-time for users currently online
    const io = getIO();
    if (io) {
      otherUsers.forEach(u => {
        io.to(`user_${u.id}`).emit('new_notification', { title, body, type });
      });
    }

    // 2. FCM Multicast — push notification to all offline devices in one call
    if (firebaseAdmin) {
      const tokens = otherUsers
        .filter(u => u.fcmToken)
        .map(u => u.fcmToken);

      if (tokens.length > 0) {
        const multicastMsg = {
          notification: { title, body },
          data: { type, click_action: 'FLUTTER_NOTIFICATION_CLICK' },
          tokens,
        };
        const result = await getMessaging(firebaseAdmin).sendEachForMulticast(multicastMsg);
        console.log(`📣 Community broadcast sent: ${result.successCount} success, ${result.failureCount} failures`);
      }
    }

    // 3. Save DB notification rows for each user (in-app notification history)
    const { Notification } = await import('../models/index.js');
    const now = new Date();
    const rows = otherUsers.map(u => ({
      userId: u.id,
      title,
      body,
      type,
      bookingId: null,
      isRead: false,
      createdAt: now,
      updatedAt: now,
    }));
    if (rows.length > 0) {
      await Notification.bulkCreate(rows);
    }
  } catch (err) {
    console.error('❌ broadcastToAll error:', err.message);
  }
}

export const getPosts = async (req, res) => {
  try {
    const { tag, search, sort, page = 1, limit = 20 } = req.query;
    const where = {};
    if (tag) where.tag = tag;
    if (search) {
      const escapedSearch = search.replace(/[\\%_]/g, '\\$&');
      where.question = { [Op.like]: `%${escapedSearch}%` };
    }

    let order = [['createdAt', 'DESC']];
    if (sort === 'popular') order = [['likes', 'DESC']];
    else if (sort === 'unanswered') where.answersCount = 0;

    const { rows: posts, count: total } = await CommunityPost.findAndCountAll({
      where,
      include: [{ model: User, as: 'author', attributes: ['name', 'profileImage'] }],
      order,
      limit: parseInt(limit),
      offset: (parseInt(page) - 1) * parseInt(limit)
    });

    res.json({ success: true, data: posts, meta: { page: parseInt(page), total } });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const createPost = async (req, res) => {
  try {
    const { question, tag } = req.body;
    const safeQuestion = xss(question);
    const safeTag = xss(tag);
    const post = await CommunityPost.create({
      authorId: req.user.id,
      question: safeQuestion,
      tag: safeTag
    });

    // Broadcast to all other users (async — does not block response)
    const preview = safeQuestion.length > 60 ? safeQuestion.substring(0, 57) + '...' : safeQuestion;
    broadcastToAll(
      req.user.id,
      '🆕 New Community Post',
      `${req.user.name} asked: "${preview}"`,
      'community_post'
    );

    res.status(201).json({ success: true, data: post });
  } catch (error) {
    res.status(400).json({ success: false, message: 'An internal error occurred' });
  }
};

export const getPostById = async (req, res) => {
  try {
    const post = await CommunityPost.findByPk(req.params.id, {
      include: [
        { model: User, as: 'author', attributes: ['name', 'profileImage'] },
        { model: Answer, as: 'answers', include: [{ model: User, as: 'author', attributes: ['name', 'profileImage'] }] }
      ]
    });
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    res.json({ success: true, data: post });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const createAnswer = async (req, res) => {
  try {
    const { answer } = req.body;
    const safeAnswer = xss(answer);
    const newAnswer = await Answer.create({
      postId: req.params.id,
      authorId: req.user.id,
      answer: safeAnswer
    });
    const post = await CommunityPost.findByPk(req.params.id);
    if (post) {
      post.answersCount += 1;
      await post.save();

      // Notify the post author when someone answers their question (not self-answer)
      if (post.authorId !== req.user.id) {
        const preview = answer.length > 60 ? answer.substring(0, 57) + '...' : answer;
        createNotification(
          post.authorId,
          '💬 New Answer on Your Post',
          `${req.user.name} answered: "${preview}"`,
          'community_answer'
        ).catch(err => console.error('Error sending answer notification:', err));
      }
    }
    res.status(201).json({ success: true, data: newAnswer });
  } catch (error) {
    res.status(400).json({ success: false, message: 'An internal error occurred' });
  }
};

export const toggleLike = async (req, res) => {
  try {
    const post = await CommunityPost.findByPk(req.params.id);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    
    let likedBy = post.likedBy || [];
    const userId = req.user.id;
    const index = likedBy.indexOf(userId);

    let isLikedNow = false;
    if (index === -1) {
      likedBy.push(userId);
      post.likes += 1;
      isLikedNow = true;
    } else {
      likedBy.splice(index, 1);
      post.likes -= 1;
    }
    
    post.likedBy = [...likedBy];
    post.changed('likedBy', true);
    await post.save();

    // Notify the post author when someone likes their post (not self-likes)
    if (isLikedNow && post.authorId !== userId) {
      const questionPreview = post.question.length > 50
        ? post.question.substring(0, 47) + '...'
        : post.question;
      createNotification(
        post.authorId,
        '❤️ Post Liked',
        `${req.user.name} liked your post: "${questionPreview}"`,
        'post_like'
      ).catch(err => console.error('Error sending post like notification:', err));
    }

    res.json({ success: true, likes: post.likes, isLiked: isLikedNow });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};

export const toggleLikeAnswer = async (req, res) => {
  try {
    const answer = await Answer.findByPk(req.params.id);
    if (!answer) return res.status(404).json({ success: false, message: 'Answer not found' });

    let likedBy = answer.likedBy || [];
    const userId = req.user.id;
    const index = likedBy.indexOf(userId);

    let isLikedNow = false;
    if (index === -1) {
      likedBy.push(userId);
      answer.likes += 1;
      isLikedNow = true;
    } else {
      likedBy.splice(index, 1);
      answer.likes -= 1;
    }

    answer.likedBy = [...likedBy];
    answer.changed('likedBy', true);
    await answer.save();

    // Trigger notification to the author of the answer if they are not the liker
    if (isLikedNow && answer.authorId !== userId) {
      createNotification(
        answer.authorId,
        '❤️ Answer Liked',
        `${req.user.name} liked your answer: "${answer.answer.length > 50 ? answer.answer.substring(0, 47) + '...' : answer.answer}"`,
        'answer_like'
      ).catch(err => console.error('Error sending answer like notification:', err));
    }

    res.json({ success: true, likes: answer.likes, isLiked: isLikedNow });
  } catch (error) {
    res.status(500).json({ success: false, message: 'An internal error occurred' });
  }
};
