const mongoose = require('mongoose');

const cartSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    number: { type: Number, default: 1, min: 1 },
    type: { type: String, enum: ['grocery', 'ecommerce'] }
}, { timestamps: true });

module.exports = mongoose.model('Cart', cartSchema);
