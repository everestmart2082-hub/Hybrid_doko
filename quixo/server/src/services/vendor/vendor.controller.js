const vendorService = require('./vendor.service');

exports.getProfile = async (req, res) => {
  try {
    const data = await vendorService.findByUserId(req.user.id);
    if (!data) return res.status(404).json({ success: false, message: 'Vendor profile not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateProfile = async (req, res) => {
  try {
    const vendor = await vendorService.findByUserId(req.user.id);
    if (!vendor) return res.status(404).json({ success: false, message: 'Vendor not found' });
    const data = await vendorService.update(vendor._id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.getDashboard = async (req, res) => {
  try {
    const vendor = await vendorService.findByUserId(req.user.id);
    if (!vendor) return res.status(404).json({ success: false, message: 'Vendor not found' });
    const data = await vendorService.getDashboard(vendor._id);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getAll = async (req, res) => {
  try {
    const data = await vendorService.findAll(req.query);
    res.json({ success: true, count: data.length, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await vendorService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateStatus = async (req, res) => {
  try {
    const data = await vendorService.updateStatus(req.params.id, req.body.status);
    res.json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};
