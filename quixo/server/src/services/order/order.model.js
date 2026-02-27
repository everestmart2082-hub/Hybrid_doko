const mongoose = require('mongoose');

const orderItemSchema = new mongoose.Schema({
  productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
  name: { type: String, required: true },
  price: { type: Number, required: true },
  qty: { type: Number, required: true, min: 1 },
  image: String
}, { _id: false });

const orderSchema = new mongoose.Schema({
  customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  riderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Rider' },
  items: { type: [orderItemSchema], required: true, validate: v => v.length > 0 },
  status: {
    type: String,
    enum: ['pending', 'confirmed', 'preparing', 'picked', 'out_for_delivery', 'delivered', 'cancelled'],
    default: 'pending'
  },
  deliveryType: { type: String, enum: ['quick', 'ecommerce'], required: true },
  address: {
    address: { type: String, required: true },
    city: String,
    lat: Number,
    lng: Number
  },
  subTotal: { type: Number, required: true },
  vat: { type: Number, default: 0 },
  deliveryCharge: { type: Number, default: 0 },
  total: { type: Number, required: true },
  paymentMethod: { type: String, enum: ['khalti', 'esewa', 'fonepay', 'cashOnDelivery'], required: true },
  paymentStatus: { type: String, enum: ['pending', 'paid', 'refunded'], default: 'pending' },
  deliveryOTP: String,
  estimatedDelivery: Date,
  notes: String,
  statusHistory: [{
    status: String,
    timestamp: { type: Date, default: Date.now },
    note: String
  }]
}, { timestamps: true });

// Indexes
orderSchema.index({ customerId: 1, createdAt: -1 });
orderSchema.index({ vendorId: 1, status: 1 });
orderSchema.index({ riderId: 1, status: 1 });
orderSchema.index({ status: 1 });

module.exports = mongoose.model('Order', orderSchema);