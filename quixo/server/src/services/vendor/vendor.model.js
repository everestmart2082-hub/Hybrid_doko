const mongoose = require('mongoose');
const vendorSchema = new mongoose.Schema({
  userId:       { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  storeName:    { type: String, required: true },
  ownerName:    String,
  pan:          String,
  address:      String,
  contact:      String,
  businessType: String,
  description:  String,
  logo:         String,
  status:       { type: String, enum: ['pending','approved','suspended'], default: 'pending' },
  revenue:      { type: Number, default: 0 },
  rating:       { type: Number, default: 0 },
  complaints:   [{ message: String, date: Date }],
  violationCount: { type: Number, default: 0 },
}, { timestamps: true });
module.exports = mongoose.model('Vendor', vendorSchema);