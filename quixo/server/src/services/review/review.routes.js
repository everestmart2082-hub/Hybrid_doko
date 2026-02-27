const express = require('express');
const router = express.Router();
const ctrl = require('./review.controller');
const { authGuard } = require('../../shared/middleware/authGuard');

// Public: get reviews for a product
router.get('/product/:productId', ctrl.getByProduct);

// Protected: write / delete reviews
router.post('/', authGuard, ctrl.create);
router.delete('/:id', authGuard, ctrl.remove);

module.exports = router;
