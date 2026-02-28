const mongoose = require('mongoose');

const payrollSchema = new mongoose.Schema({
    employeeId: { type: mongoose.Schema.Types.ObjectId, ref: 'Employee', required: true },
    amount: { type: Number, required: true },
    date: { type: Date, default: Date.now },
    status: { type: String, enum: ['pending', 'paid'] }
}, { timestamps: true });

module.exports = mongoose.model('Payroll', payrollSchema);
