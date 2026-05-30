import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Roadmap = sequelize.define('Roadmap', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  goal: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  title: {
    type: DataTypes.STRING(255)
  },
  totalWeeks: {
    type: DataTypes.INTEGER
  },
  steps: {
    type: DataTypes.JSON, // Array of step objects
    allowNull: false,
    defaultValue: []
  },
  currentLevel: {
    type: DataTypes.ENUM('beginner', 'intermediate', 'advanced')
  },
  timeAvailableWeekly: {
    type: DataTypes.INTEGER
  },
  progressPercent: {
    type: DataTypes.INTEGER,
    defaultValue: 0
  }
}, {
  tableName: 'roadmaps',
  timestamps: true,
  underscored: true
});

export default Roadmap;
