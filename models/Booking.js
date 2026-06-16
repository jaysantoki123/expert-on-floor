import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Booking = sequelize.define('Booking', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  learnerId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  expertId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  sessionType: {
    type: DataTypes.ENUM('chat', 'audio', 'video'),
    allowNull: false
  },
  date: {
    type: DataTypes.DATEONLY,
    allowNull: false
  },
  timeSlot: {
    type: DataTypes.TIME,
    allowNull: false
  },
  durationMinutes: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  topic: {
    type: DataTypes.STRING(255),
    allowNull: true
  },
  status: {
    type: DataTypes.ENUM('pending_payment', 'confirmed', 'completed', 'cancelled'),
    defaultValue: 'pending_payment'
  },
  amount: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  razorpayOrderId: {
    type: DataTypes.STRING(100),
    allowNull: true
  }
}, {
  tableName: 'bookings',
  timestamps: true,
  underscored: true
});

export default Booking;
