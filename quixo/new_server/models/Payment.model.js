const mongoose = require('mongoose');

const paymentSchema = new mongoose.Schema({
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    type: { type: String, enum: ['esewa', 'fonepay', 'cash on delivary'] },
    transactionId: { type: String },
    amount: { type: Number, required: true },
    status: { type: String, enum: ['pending', 'completed', 'failed'] }
}, { timestamps: true });

module.exports = mongoose.model('Payment', paymentSchema);
