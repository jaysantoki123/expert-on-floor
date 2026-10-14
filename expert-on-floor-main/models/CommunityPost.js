import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const CommunityPost = sequelize.define('CommunityPost', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  authorId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  question: {
    type: DataTypes.TEXT,
    allowNull: false
  },
  tag: {
    type: DataTypes.STRING(50)
  },
  answersCount: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  likes: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  likedBy: {
    type: DataTypes.JSON, // Array of user IDs
    defaultValue: []
  }
}, {
  tableName: 'community_posts',
  timestamps: true,
  underscored: true
});

export default CommunityPost;
