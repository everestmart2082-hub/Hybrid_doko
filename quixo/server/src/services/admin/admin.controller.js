const adminService = require('./admin.service');

exports.getAll  = async (req, res) => {
  try {
    const data = await adminService.findAll(req.query);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await adminService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.create  = async (req, res) => {
  try {
    const data = await adminService.create(req.body);
    res.status(201).json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};

exports.update  = async (req, res) => {
  try {
    const data = await adminService.update(req.params.id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};

exports.remove  = async (req, res) => {
  try {
    await adminService.remove(req.params.id);
    res.json({ success: true, message: 'Deleted successfully' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
