const express = require('express');
const router = express.Router();
const ctrl = require('./admin.controller');
const { authGuard, isAdmin } = require('../../shared/middleware/authGuard');

router.get('/', authGuard, isAdmin, ctrl.getAll);
router.get('/:id', authGuard, isAdmin, ctrl.getById);
router.post('/', authGuard, isAdmin, ctrl.create);
router.put('/:id', authGuard, isAdmin, ctrl.update);
router.delete('/:id', authGuard, isAdmin, ctrl.remove);

module.exports = router;
