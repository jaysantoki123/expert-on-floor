import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Answer = sequelize.define('Answer', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  postId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  authorId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  answer: {
    type: DataTypes.TEXT,
    allowNull: false
  }
}, {
  tableName: 'community_answers',
  timestamps: true,
  underscored: true
});

export default Answer;
