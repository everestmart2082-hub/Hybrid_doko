const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
  orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor' },
  transactionId: { type: String },
  pidx: { type: String },        // Khalti payment index
  method: { type: String, enum: ['khalti', 'esewa', 'fonepay', 'cashOnDelivery'], required: true },
  subTotal: { type: Number, required: true },
  vat: { type: Number, default: 0 },
  deliveryCharge: { type: Number, default: 0 },
  total: { type: Number, required: true },
  status: { type: String, enum: ['pending', 'success', 'failed', 'refunded'], default: 'pending' },
  gatewayResponse: mongoose.Schema.Types.Mixed,  // Raw response from payment gateway
}, { timestamps: true });

paymentSchema.index({ orderId: 1 });
paymentSchema.index({ customerId: 1, createdAt: -1 });

module.exports = mongoose.model('Payment', paymentSchema);