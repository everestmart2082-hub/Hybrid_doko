const orderService = require('./order.service');

exports.getAll = async (req, res) => {
  try {
    const result = await orderService.findAll(req.query, req.user);
    res.json({ success: true, ...result });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await orderService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Order not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};

exports.create = async (req, res) => {
  try {
    const data = await orderService.create({ ...req.body, customerId: req.user.id });
    res.status(201).json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.update = async (req, res) => {
  try {
    const data = await orderService.update(req.params.id, req.body, req.user);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.cancel = async (req, res) => {
  try {
    const data = await orderService.cancel(req.params.id, req.user.id);
    res.json({ success: true, message: 'Order cancelled', data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};
