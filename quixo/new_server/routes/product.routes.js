const express = require('express');
const router = express.Router();
const productController = require('../controllers/product.controller');

router.get('/all', productController.getAllProducts);
router.post('/all', productController.getAllProducts); // support both just in case

router.get('/id', productController.getProductById);
router.post('/id', productController.getProductById);

router.get('/recommended', productController.getRecommendedProducts);
router.post('/recommended', productController.getRecommendedProducts);

module.exports = router;
