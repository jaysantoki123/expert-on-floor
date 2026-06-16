import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Expert = sequelize.define('Expert', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    unique: true,
    allowNull: false
  },
  title: {
    type: DataTypes.STRING(150),
    allowNull: false
  },
  category: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  experienceYears: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  pricePerHour: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  isAvailable: {
    type: DataTypes.BOOLEAN,
    defaultValue: true
  },
  skills: {
    type: DataTypes.JSON,
    allowNull: false,
    defaultValue: []
  },
  achievements: {
    type: DataTypes.JSON,
    allowNull: true,
    defaultValue: []
  },
  bio: {
    type: DataTypes.TEXT,
    allowNull: true
  },
  totalSessions: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  avgRating: {
    type: DataTypes.DECIMAL(2, 1),
    defaultValue: 0.0
  },
  totalReviews: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  },
  availability: {
    type: DataTypes.JSON,
    allowNull: true
  },
  verificationStatus: {
    type: DataTypes.ENUM('pending', 'verified', 'rejected'),
    defaultValue: 'pending'
  },
  verificationDocuments: {
    type: DataTypes.JSON,
    allowNull: true
  },
  isFeatured: {
    type: DataTypes.BOOLEAN,
    defaultValue: false
  }
}, {
  tableName: 'expert_profiles',
  timestamps: true,
  underscored: true
});

export default Expert;
