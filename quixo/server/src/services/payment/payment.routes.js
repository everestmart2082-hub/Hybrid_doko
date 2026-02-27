const express = require('express');
const router = express.Router();
const ctrl = require('./payment.controller');
const { authGuard, isAdmin } = require('../../shared/middleware/authGuard');

router.get('/', authGuard, ctrl.getAll);       // list payments (admin or user's own)
router.get('/:id', authGuard, ctrl.getById);      // payment details
router.post('/initiate', authGuard, ctrl.initiate);     // start payment
router.post('/:id/verify', authGuard, ctrl.verify);       // verify gateway callback
router.post('/:id/refund', authGuard, isAdmin, ctrl.refund); // admin refund

module.exports = router;
