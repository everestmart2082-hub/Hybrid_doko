const express = require('express');
const router = express.Router();
const ctrl = require('./rider.controller');
const { authGuard, isRider, isAdmin } = require('../../shared/middleware/authGuard');

// Rider self-service
router.get('/profile', authGuard, isRider, ctrl.getProfile);
router.put('/profile', authGuard, isRider, ctrl.updateProfile);
router.post('/toggle', authGuard, isRider, ctrl.toggleAvailability);
router.put('/location', authGuard, isRider, ctrl.updateLocation);
router.get('/dashboard', authGuard, isRider, ctrl.getDashboard);

// Admin: list and view riders
router.get('/', authGuard, isAdmin, ctrl.getAll);
router.get('/:id', authGuard, ctrl.getById);

module.exports = router;
