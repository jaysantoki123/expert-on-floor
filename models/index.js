import sequelize from '../config/database.js';
import User from './User.js';
import Expert from './Expert.js';
import Booking from './Booking.js';
import Review from './Review.js';
import Payment from './Payment.js';
import CommunityPost from './CommunityPost.js';
import Answer from './Answer.js';
import Roadmap from './Roadmap.js';
import Notification from './Notification.js';
import Conversation from './Conversation.js';
import Message from './Message.js';

// Associations
User.hasOne(Expert, { foreignKey: 'userId', as: 'expertProfile' });
Expert.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Booking, { foreignKey: 'learnerId', as: 'learnerBookings' });
User.hasMany(Booking, { foreignKey: 'expertId', as: 'expertBookings' });
Booking.belongsTo(User, { foreignKey: 'learnerId', as: 'learner' });
Booking.belongsTo(User, { foreignKey: 'expertId', as: 'expert' });

Booking.hasOne(Review, { foreignKey: 'bookingId', as: 'review' });
Review.belongsTo(Booking, { foreignKey: 'bookingId', as: 'booking' });

User.hasMany(Review, { foreignKey: 'learnerId', as: 'givenReviews' });
User.hasMany(Review, { foreignKey: 'expertId', as: 'receivedReviews' });
Review.belongsTo(User, { foreignKey: 'learnerId', as: 'learner' });
Review.belongsTo(User, { foreignKey: 'expertId', as: 'expert' });

Booking.hasOne(Payment, { foreignKey: 'bookingId', as: 'payment' });
Payment.belongsTo(Booking, { foreignKey: 'bookingId', as: 'booking' });

User.hasMany(CommunityPost, { foreignKey: 'authorId', as: 'posts' });
CommunityPost.belongsTo(User, { foreignKey: 'authorId', as: 'author' });

CommunityPost.hasMany(Answer, { foreignKey: 'postId', as: 'answers' });
Answer.belongsTo(CommunityPost, { foreignKey: 'postId', as: 'post' });

User.hasMany(Answer, { foreignKey: 'authorId', as: 'answers' });
Answer.belongsTo(User, { foreignKey: 'authorId', as: 'author' });

User.hasMany(Roadmap, { foreignKey: 'userId', as: 'roadmaps' });
Roadmap.belongsTo(User, { foreignKey: 'userId', as: 'user' });

User.hasMany(Notification, { foreignKey: 'userId', as: 'notifications' });
Notification.belongsTo(User, { foreignKey: 'userId', as: 'user' });

// Chat Associations
Conversation.belongsTo(User, { foreignKey: 'participant1Id', as: 'participant1' });
Conversation.belongsTo(User, { foreignKey: 'participant2Id', as: 'participant2' });
Conversation.hasMany(Message, { foreignKey: 'conversationId', as: 'messages' });
Message.belongsTo(Conversation, { foreignKey: 'conversationId', as: 'conversation' });
Message.belongsTo(User, { foreignKey: 'senderId', as: 'sender' });

const syncDB = async () => {
  try {
    await sequelize.authenticate();
    console.log('Database connected...');
    await sequelize.sync({ alter: true });
    console.log('Tables synchronized...');
  } catch (err) {
    console.error('Sequelize sync error:', err);
  }
};

export {
  sequelize,
  User,
  Expert,
  Booking,
  Review,
  Payment,
  CommunityPost,
  Answer,
  Roadmap,
  Notification,
  Conversation,
  Message,
  syncDB
};
