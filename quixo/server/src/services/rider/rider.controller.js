const riderService = require('./rider.service');

exports.getProfile = async (req, res) => {
  try {
    const data = await riderService.findByUserId(req.user.id);
    if (!data) return res.status(404).json({ success: false, message: 'Rider profile not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateProfile = async (req, res) => {
  try {
    const rider = await riderService.findByUserId(req.user.id);
    if (!rider) return res.status(404).json({ success: false, message: 'Rider not found' });
    const data = await riderService.update(rider._id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.toggleAvailability = async (req, res) => {
  try {
    const data = await riderService.toggleAvailability(req.user.id);
    res.json({ success: true, isAvailable: data.isAvailable });
  } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};

exports.updateLocation = async (req, res) => {
  try {
    const data = await riderService.updateLocation(req.user.id, req.body);
    res.json({ success: true, location: data.location });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getDashboard = async (req, res) => {
  try {
    const rider = await riderService.findByUserId(req.user.id);
    if (!rider) return res.status(404).json({ success: false, message: 'Rider not found' });
    const data = await riderService.getDashboard(rider._id);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getAll = async (req, res) => {
  try {
    const data = await riderService.findAll(req.query);
    res.json({ success: true, count: data.length, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await riderService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
