const Review = require('./review.model');
const Product = require('../product/product.model');

exports.findByProduct = async (productId) => {
    return Review.find({ productId }).populate('userId', 'name profileImage').sort('-createdAt');
};

exports.create = async (data) => {
    const review = await Review.create(data);

    // Recalculate product rating
    const stats = await Review.aggregate([
        { $match: { productId: review.productId } },
        { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } }
    ]);

    if (stats.length > 0) {
        await Product.findByIdAndUpdate(review.productId, {
            'rating.average': Math.round(stats[0].avg * 10) / 10,
            'rating.count': stats[0].count
        });
    }

    return review;
};

exports.remove = async (id, userId) => {
    const review = await Review.findOne({ _id: id, userId });
    if (!review) throw Object.assign(new Error('Review not found or not yours'), { statusCode: 404 });
    await review.deleteOne();

    // Recalculate rating
    const stats = await Review.aggregate([
        { $match: { productId: review.productId } },
        { $group: { _id: null, avg: { $avg: '$rating' }, count: { $sum: 1 } } }
    ]);
    const avg = stats.length > 0 ? Math.round(stats[0].avg * 10) / 10 : 0;
    const count = stats.length > 0 ? stats[0].count : 0;
    await Product.findByIdAndUpdate(review.productId, { 'rating.average': avg, 'rating.count': count });
};
