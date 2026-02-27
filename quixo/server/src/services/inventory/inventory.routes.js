const express = require('express');
const router = express.Router();
const ctrl = require('./inventory.controller');
const { authGuard, isAdmin, isVendor } = require('../../shared/middleware/authGuard');

// Vendor/Admin: view inventory
router.get('/', authGuard, ctrl.getAll);
router.get('/low-stock', authGuard, isAdmin, ctrl.getLowStock);
router.get('/:id', authGuard, ctrl.getById);

// Admin only: manage inventory directly
router.post('/', authGuard, isAdmin, ctrl.create);
router.put('/:id', authGuard, isAdmin, ctrl.update);
router.delete('/:id', authGuard, isAdmin, ctrl.remove);

module.exports = router;
