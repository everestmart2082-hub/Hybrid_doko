const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
    name: { type: String, required: true },
    number: { type: String, required: true, unique: true },
    email: { type: String },
    passwordHash: { type: String },
    otp: { type: String },
    suspend: { type: Boolean, default: false },
    deactivate: { type: Boolean, default: false },
    violations: [{ type: String }],
    defaultAddress: { type: mongoose.Schema.Types.ObjectId, ref: 'Address' },
}, { timestamps: true });

module.exports = mongoose.model('User', userSchema);
