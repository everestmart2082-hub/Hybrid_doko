const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    riderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Rider' },
    rating: { type: Number, required: true, min: 1, max: 5 },
    description: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Review', reviewSchema);
