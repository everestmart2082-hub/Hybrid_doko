const reviewService = require('./review.service');

exports.getByProduct = async (req, res) => {
    try {
        const data = await reviewService.findByProduct(req.params.productId);
        res.json({ success: true, data });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.create = async (req, res) => {
    try {
        const data = await reviewService.create({ ...req.body, userId: req.user.id });
        res.status(201).json({ success: true, data });
    } catch (err) {
        const status = err.code === 11000 ? 400 : (err.statusCode || 500);
        const msg = err.code === 11000 ? 'You already reviewed this product' : err.message;
        res.status(status).json({ success: false, message: msg });
    }
};

exports.remove = async (req, res) => {
    try {
        await reviewService.remove(req.params.id, req.user.id);
        res.json({ success: true, message: 'Review deleted' });
    } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};
