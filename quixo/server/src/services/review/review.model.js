const mongoose = require('mongoose');

const reviewSchema = new mongoose.Schema({
    userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product', required: true },
    orderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
    rating: { type: Number, required: [true, 'Rating is required'], min: 1, max: 5 },
    title: { type: String, maxlength: 100 },
    comment: { type: String, maxlength: 1000 },
    images: [String],
    isVerified: { type: Boolean, default: false },  // Purchase-verified review
}, { timestamps: true });

// One review per user per product
reviewSchema.index({ userId: 1, productId: 1 }, { unique: true });
reviewSchema.index({ productId: 1, createdAt: -1 });

module.exports = mongoose.model('Review', reviewSchema);
