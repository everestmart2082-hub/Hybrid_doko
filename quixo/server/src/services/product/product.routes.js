const express = require('express');
const router = express.Router();
const ctrl = require('./product.controller');
const { authGuard, isVendor } = require('../../shared/middleware/authGuard');
const { productValidator } = require('../../shared/validators/productValidator');
const { validate } = require('../../shared/middleware/validate');

// ── Public routes (no token needed) ──
router.get('/', ctrl.getAll);           // browse / search / filter products
router.get('/:id', ctrl.getById);       // view single product

// ── Protected routes (vendor only) ──
router.post('/', authGuard, isVendor, productValidator, validate, ctrl.create);
router.put('/:id', authGuard, isVendor, ctrl.update);
router.delete('/:id', authGuard, isVendor, ctrl.remove);

module.exports = router;
