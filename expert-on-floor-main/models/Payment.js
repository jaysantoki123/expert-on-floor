import { DataTypes } from 'sequelize';
import sequelize from '../config/database.js';

const Payment = sequelize.define('Payment', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  bookingId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  userId: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  razorpayOrderId: {
    type: DataTypes.STRING(100)
  },
  razorpayPaymentId: {
    type: DataTypes.STRING(100),
    allowNull: true
  },
  amount: {
    type: DataTypes.INTEGER,
    allowNull: false
  },
  status: {
    type: DataTypes.ENUM('pending', 'success', 'failed', 'refunded'),
    defaultValue: 'pending'
  }
}, {
  tableName: 'payments',
  timestamps: true,
  underscored: true,
  indexes: [
    {
      name: 'payments_razorpay_order_id_unique',
      unique: true,
      fields: ['razorpay_order_id']
    }
  ]
});

export default Payment;
