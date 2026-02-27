const paymentService = require('./payment.service');

exports.getAll = async (req, res) => {
  try {
    const data = await paymentService.findAll(req.query);
    res.json({ success: true, count: data.length, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await paymentService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.initiate = async (req, res) => {
  try {
    const data = await paymentService.initiate({ ...req.body, customerId: req.user.id });
    res.status(201).json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.verify = async (req, res) => {
  try {
    const data = await paymentService.verify(req.params.id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.refund = async (req, res) => {
  try {
    const data = await paymentService.refund(req.params.id);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};
