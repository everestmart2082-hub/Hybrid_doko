const express = require('express');
const router = express.Router();
const ctrl = require('./order.controller');
const { authGuard } = require('../../shared/middleware/authGuard');
const { orderValidator } = require('../../shared/validators/orderValidator');
const { validate } = require('../../shared/middleware/validate');

router.get('/', authGuard, ctrl.getAll);         // list user's orders (filtered by role)
router.get('/:id', authGuard, ctrl.getById);     // order detail
router.post('/', authGuard, orderValidator, validate, ctrl.create);   // customer places order
router.put('/:id', authGuard, ctrl.update);      // update status (vendor/rider/admin)
router.post('/:id/cancel', authGuard, ctrl.cancel); // customer cancels order

module.exports = router;
