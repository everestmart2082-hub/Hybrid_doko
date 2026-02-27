const mongoose = require('mongoose');
const notificationSchema = new mongoose.Schema({
  userId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type:      { type: String, enum: ['order','payment','delivery','system'], default: 'system' },
  title:     { type: String, required: true },
  message:   { type: String, required: true },
  isRead:    { type: Boolean, default: false },
  orderId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
}, { timestamps: true });
module.exports = mongoose.model('Notification', notificationSchema);
