const Notification = require('./notification.model');

/**
 * Get notifications for the authenticated user with pagination.
 */
exports.findByUser = async (userId, query = {}) => {
    const filter = { userId };
    if (query.type) filter.type = query.type;
    if (query.isRead === 'true') filter.isRead = true;
    if (query.isRead === 'false') filter.isRead = false;

    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    const skip = (page - 1) * limit;

    const [data, total, unreadCount] = await Promise.all([
        Notification.find(filter)
            .populate('orderId', 'status total')
            .sort('-createdAt')
            .skip(skip)
            .limit(limit),
        Notification.countDocuments(filter),
        Notification.countDocuments({ userId, isRead: false })
    ]);

    return { data, total, unreadCount, page, limit, totalPages: Math.ceil(total / limit) };
};

/**
 * Create a notification (used internally by the system).
 */
exports.create = (data) => Notification.create(data);

/**
 * Mark a single notification as read.
 */
exports.markAsRead = async (id, userId) => {
    const notification = await Notification.findOneAndUpdate(
        { _id: id, userId },
        { isRead: true },
        { new: true }
    );
    if (!notification) throw Object.assign(new Error('Notification not found'), { statusCode: 404 });
    return notification;
};

/**
 * Mark all notifications as read for a user.
 */
exports.markAllRead = async (userId) => {
    await Notification.updateMany({ userId, isRead: false }, { isRead: true });
    return { success: true };
};

/**
 * Get unread count for a user.
 */
exports.getUnreadCount = async (userId) => {
    return Notification.countDocuments({ userId, isRead: false });
};

/**
 * Delete a notification (user can only delete their own).
 */
exports.remove = async (id, userId) => {
    const notification = await Notification.findOneAndDelete({ _id: id, userId });
    if (!notification) throw Object.assign(new Error('Notification not found'), { statusCode: 404 });
};
