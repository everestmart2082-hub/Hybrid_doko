const express = require('express');
const router = express.Router();
const ctrl = require('./user.controller');
const { authGuard, isAdmin } = require('../../shared/middleware/authGuard');

// Profile
router.get('/profile', authGuard, ctrl.getProfile);
router.put('/profile', authGuard, ctrl.updateProfile);

// Addresses
router.get('/addresses', authGuard, ctrl.getAddresses);
router.post('/address', authGuard, ctrl.addAddress);
router.put('/address/:id', authGuard, ctrl.updateAddress);
router.delete('/address/:id', authGuard, ctrl.deleteAddress);
router.put('/address/:id/default', authGuard, ctrl.setDefaultAddress);

// Admin: list all users
router.get('/', authGuard, isAdmin, ctrl.getAll);

module.exports = router;
