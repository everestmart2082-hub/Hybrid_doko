const express = require('express');
const router = express.Router();
const ctrl = require('./analytics.controller');
const { authGuard, isAdmin } = require('../../shared/middleware/authGuard');

router.get('/dashboard', authGuard, isAdmin, ctrl.getDashboard);
router.get('/sales', authGuard, isAdmin, ctrl.getSalesOverTime);
router.get('/top-products', authGuard, isAdmin, ctrl.getTopProducts);
router.get('/order-stats', authGuard, isAdmin, ctrl.getOrderStats);
router.get('/vendor-revenue', authGuard, isAdmin, ctrl.getRevenueByVendor);
router.get('/payment-stats', authGuard, isAdmin, ctrl.getPaymentStats);

module.exports = router;
