const mongoose = require('mongoose');

const vendorSchema = new mongoose.Schema({
    name: { type: String, required: true },
    number: { type: String, required: true, unique: true },
    email: { type: String },
    pan: { type: String },
    storeName: { type: String },
    address: { type: String },
    businessType: { type: String }, // textile, garment, etc.
    description: { type: String },
    geolocation: {
        type: { type: String, enum: ['Point'], default: 'Point' },
        coordinates: { type: [Number], default: [0, 0] }
    },
    verified: { type: Boolean, default: false },
    suspended: { type: Boolean, default: false },
    revenue: { type: Number, default: 0 },
    violations: [{ type: String }],
    passwordHash: { type: String },
    otp: { type: String }
}, { timestamps: true });

vendorSchema.index({ geolocation: "2dsphere" });

module.exports = mongoose.model('Vendor', vendorSchema);
