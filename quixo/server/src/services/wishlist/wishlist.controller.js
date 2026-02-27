const wishlistService = require('./wishlist.service');

exports.get = async (req, res) => {
    try {
        const data = await wishlistService.get(req.user.id);
        res.json({ success: true, data });
    } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.add = async (req, res) => {
    try {
        const data = await wishlistService.addProduct(req.user.id, req.body.productId);
        res.json({ success: true, data });
    } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};

exports.remove = async (req, res) => {
    try {
        const data = await wishlistService.removeProduct(req.user.id, req.params.productId);
        res.json({ success: true, data });
    } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};
