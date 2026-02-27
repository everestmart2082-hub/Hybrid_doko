const express = require('express');
const router = express.Router();
const ctrl = require('./notification.controller');
const { authGuard } = require('../../shared/middleware/authGuard');

// All notification routes require authentication
router.get('/', authGuard, ctrl.getAll);          // list user's notifications
router.get('/unread-count', authGuard, ctrl.getUnreadCount);  // unread badge count
router.put('/:id/read', authGuard, ctrl.markAsRead);      // mark single as read
router.put('/read-all', authGuard, ctrl.markAllRead);     // mark all as read
router.delete('/:id', authGuard, ctrl.remove);          // delete notification

module.exports = router;
