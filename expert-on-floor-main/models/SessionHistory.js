import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const SessionHistory = sequelize.define('SessionHistory', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  learnerId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  bookingId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  expertId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  expertName: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  expertRole: {
    type: DataTypes.STRING(100),
    allowNull: false
  },
  topic: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  date: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  time: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  duration: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  type: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  status: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  price: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  rating: {
    type: DataTypes.FLOAT,
    allowNull: true
  },
  review: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  hasRecording: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  },
  tags: {
    type: DataTypes.JSON,
    defaultValue: []
  }
}, {
  tableName: 'session_histories',
  timestamps: true,
  underscored: true
});

export default SessionHistory;
