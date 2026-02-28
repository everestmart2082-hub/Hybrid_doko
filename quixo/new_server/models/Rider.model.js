const mongoose = require('mongoose');

const riderSchema = new mongoose.Schema({
    name: { type: String, required: true },
    number: { type: String, required: true, unique: true },
    email: { type: String },
    rating: { type: Number, default: 0 },
    rcBook: { type: String },
    citizenship: { type: String },
    panCard: { type: String },
    address: { type: String },
    bikeModel: { type: String },
    bikeNumber: { type: String },
    bikeColor: { type: String },
    type: { type: String, enum: ['bike', 'scooter'] },
    bikeInsurancePaper: { type: String },
    verified: { type: Boolean, default: false },
    suspended: { type: Boolean, default: false },
    revenue: { type: Number, default: 0 },
    violations: [{ type: String }],
    passwordHash: { type: String },
    otp: { type: String }
}, { timestamps: true });

module.exports = mongoose.model('Rider', riderSchema);
