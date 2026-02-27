const express = require('express');
const router = express.Router();
const ctrl = require('./vendor.controller');
const { authGuard, isVendor, isAdmin } = require('../../shared/middleware/authGuard');

// Vendor self-service
router.get('/profile', authGuard, isVendor, ctrl.getProfile);
router.put('/profile', authGuard, isVendor, ctrl.updateProfile);
router.get('/dashboard', authGuard, isVendor, ctrl.getDashboard);

// Admin: list and manage vendors
router.get('/', authGuard, isAdmin, ctrl.getAll);
router.get('/:id', authGuard, ctrl.getById);
router.put('/:id/status', authGuard, isAdmin, ctrl.updateStatus);

module.exports = router;
