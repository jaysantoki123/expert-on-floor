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
  bookingStatus: {
    type: DataTypes.ENUM('PENDING', 'REJECTED', 'PAYMENT_PENDING', 'PAYMENT_EXPIRED', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'EXPERT_CANCELLED', 'NO_SHOW'),
    defaultValue: 'PENDING',
    field: 'booking_status'
  },
  paymentStatus: {
    type: DataTypes.ENUM('UNPAID', 'PENDING', 'PAID', 'FAILED', 'REFUNDED'),
    defaultValue: 'UNPAID',
    field: 'payment_status'
  },
  paymentId: {
    type: DataTypes.STRING(100),
    allowNull: true,
    field: 'payment_id'
  },
  status: {
    type: DataTypes.VIRTUAL,
    get() {
      const val = this.getDataValue('bookingStatus') || 'PENDING';
      if (val === 'PENDING') return 'pending';
      if (val === 'PAYMENT_PENDING') return 'pending_payment';
      if (val === 'CONFIRMED') return 'confirmed';
      if (val === 'COMPLETED') return 'completed';
      if (val === 'CANCELLED') return 'cancelled';
      return val.toLowerCase();
    }
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
