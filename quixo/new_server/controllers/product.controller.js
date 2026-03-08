const Product = require('../models/Product.model');

// /api/product/all
const getAllProducts = async (req, res) => {
    try {
        const { category } = req.query; // optional category filter

        let query = { approved: true, hidden: false };
        if (category) {
            query.productCategory = category;
        }

        const products = await Product.find(query).populate('vendorId', 'name storeName rating');
        res.json({ success: true, message: products });
    } catch (error) {
        console.error("Error in getAllProducts:", error);
        res.json({ success: false, message: "server error" });
    }
};

// /api/product/id?id=... (or from body, assuming query param or body.id)
const getProductById = async (req, res) => {
    try {
        const productId = req.query.id || req.body.id;
        if (!productId) {
            return res.json({ success: false, message: "product id required" });
        }

        const product = await Product.findById(productId).populate('vendorId', 'name storeName rating');
        if (!product || !product.approved || product.hidden) {
            return res.json({ success: false, message: "product not found" });
        }

        res.json({ success: true, message: product });
    } catch (error) {
        console.error("Error in getProductById:", error);
        res.json({ success: false, message: "server error" });
    }
};

// /api/product/recommended
const getRecommendedProducts = async (req, res) => {
    try {
        // Simple recommendation logic: get top rated products
        const products = await Product.find({ approved: true, hidden: false })
            .sort({ rating: -1 }) // highest rating first
            .limit(10) // top 10 products
            .populate('vendorId', 'name storeName');

        res.json({ success: true, message: products });
    } catch (error) {
        console.error("Error in getRecommendedProducts:", error);
        res.json({ success: false, message: "server error" });
    }
};

module.exports = {
    getAllProducts,
    getProductById,
    getRecommendedProducts
};
