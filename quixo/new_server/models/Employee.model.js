const mongoose = require('mongoose');

const employeeSchema = new mongoose.Schema({
    name: { type: String, required: true },
    position: { type: String }, // e.g., Emp category(designation)
    salary: { type: Number }, // ctc
    address: { type: String },
    email: { type: String },
    phone: { type: String, required: true, unique: true },
    citizenship: { type: String },
    bankName: { type: String },
    accountNumber: { type: String },
    ifscCode: { type: String },
    pan: { type: String },
    rpp: { type: String }, // RPP
    educationalCertificate: { type: String },
    violations: [{ type: String }]
}, { timestamps: true });

module.exports = mongoose.model('Employee', employeeSchema);
