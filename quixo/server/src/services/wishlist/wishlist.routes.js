const express = require('express');
const router = express.Router();
const ctrl = require('./wishlist.controller');
const { authGuard } = require('../../shared/middleware/authGuard');

router.get('/', authGuard, ctrl.get);
router.post('/add', authGuard, ctrl.add);
router.delete('/:productId', authGuard, ctrl.remove);

module.exports = router;
