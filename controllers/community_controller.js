import { CommunityPost, Answer, User } from '../models/index.js';
import { Op } from 'sequelize';

export const getPosts = async (req, res) => {
  try {
    const { tag, search, sort, page = 1, limit = 20 } = req.query;
    const where = {};
    if (tag) where.tag = tag;
    if (search) where.question = { [Op.like]: `%${search}%` };

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
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createPost = async (req, res) => {
  try {
    const { question, tag } = req.body;
    const post = await CommunityPost.create({
      authorId: req.user.id,
      question,
      tag
    });
    res.status(201).json({ success: true, data: post });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
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
    res.status(500).json({ success: false, message: error.message });
  }
};

export const createAnswer = async (req, res) => {
  try {
    const { answer } = req.body;
    const newAnswer = await Answer.create({
      postId: req.params.id,
      authorId: req.user.id,
      answer
    });
    const post = await CommunityPost.findByPk(req.params.id);
    if (post) {
      post.answersCount += 1;
      await post.save();
    }
    res.status(201).json({ success: true, data: newAnswer });
  } catch (error) {
    res.status(400).json({ success: false, message: error.message });
  }
};

export const toggleLike = async (req, res) => {
  try {
    const post = await CommunityPost.findByPk(req.params.id);
    if (!post) return res.status(404).json({ success: false, message: 'Post not found' });
    
    let likedBy = post.likedBy || [];
    const userId = req.user.id;
    const index = likedBy.indexOf(userId);

    if (index === -1) {
      likedBy.push(userId);
      post.likes += 1;
    } else {
      likedBy.splice(index, 1);
      post.likes -= 1;
    }
    
    post.likedBy = likedBy; // Sequelize detects change in JSON if assigned
    await post.save();
    res.json({ success: true, likes: post.likes });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
