const express = require('express');
const router = express.Router();
const ctrl = require('./auth.controller');
const { authGuard } = require('../../shared/middleware/authGuard');
const { authLimiter } = require('../../shared/middleware/rateLimiter');
const { registerValidator } = require('../../shared/validators/userValidator');
const { validate } = require('../../shared/middleware/validate');

router.post('/register', authLimiter, registerValidator, validate, ctrl.register);
router.post('/login', authLimiter, ctrl.login);
router.post('/admin/login', authLimiter, ctrl.adminLogin);
router.get('/me', authGuard, ctrl.getMe);

module.exports = router;
