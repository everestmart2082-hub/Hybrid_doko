const mongoose = require('mongoose');

const addressSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    label: { type: String, enum: ['Home', 'work', 'office'] },
    city: { type: String },
    state: { type: String },
    pincode: { type: String },
    landmark: { type: String },
    phoneNumber: { type: String },
    email: { type: String },
    isDefault: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Address', addressSchema);
