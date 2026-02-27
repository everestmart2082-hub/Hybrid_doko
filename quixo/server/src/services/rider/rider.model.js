const mongoose = require('mongoose');
const riderSchema = new mongoose.Schema({
  userId:         { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  name:           String, phone: String, email: String,
  rcBook:         String,
  citizenship:    String,
  panCard:        String,
  address:        String,
  bikeDetails:    String,
  bikeInsurance:  String,
  status:         { type: String, enum: ['pending','approved','suspended'], default: 'pending' },
  isAvailable:    { type: Boolean, default: false },
  earnings:       { type: Number, default: 0 },
  deliveredOrders:{ type: Number, default: 0 },
  rating:         { type: Number, default: 0 },
  location:       { lat: Number, lng: Number },
  violationCount: { type: Number, default: 0 },
}, { timestamps: true });
module.exports = mongoose.model('Rider', riderSchema);