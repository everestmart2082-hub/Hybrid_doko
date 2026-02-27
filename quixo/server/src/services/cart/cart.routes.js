const express = require('express');
const router = express.Router();
const ctrl = require('./cart.controller');
const { authGuard } = require('../../shared/middleware/authGuard');

router.get('/', authGuard, ctrl.get);          // get user's cart
router.post('/add', authGuard, ctrl.addItem);      // add product to cart
router.put('/:id', authGuard, ctrl.updateItem);   // update item quantity
router.delete('/:id', authGuard, ctrl.removeItem);   // remove item
router.delete('/clear/all', authGuard, ctrl.clear);     // clear entire cart

module.exports = router;
