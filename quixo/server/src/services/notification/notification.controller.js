const notificationService = require('./notification.service');

exports.getAll = async (req, res) => {
  try {
    const result = await notificationService.findByUser(req.user.id, req.query);
    res.json({ success: true, ...result });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getUnreadCount = async (req, res) => {
  try {
    const count = await notificationService.getUnreadCount(req.user.id);
    res.json({ success: true, unreadCount: count });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.markAsRead = async (req, res) => {
  try {
    const data = await notificationService.markAsRead(req.params.id, req.user.id);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};

exports.markAllRead = async (req, res) => {
  try {
    await notificationService.markAllRead(req.user.id);
    res.json({ success: true, message: 'All notifications marked as read' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.remove = async (req, res) => {
  try {
    await notificationService.remove(req.params.id, req.user.id);
    res.json({ success: true, message: 'Notification deleted' });
  } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};
