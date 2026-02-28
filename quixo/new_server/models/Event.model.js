const mongoose = require('mongoose');

const eventSchema = new mongoose.Schema({
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order', required: true },
    status: {
        type: String,
        enum: [
            'order preparing', 'order pending', 'cancelled', 'returned',
            'order delivered', 'khalti', 'esewa'
        ]
    },
    runningStatus: { type: String, enum: ['running', 'completed'] }
}, { timestamps: true });

module.exports = mongoose.model('Event', eventSchema);
