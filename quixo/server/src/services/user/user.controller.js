const userService = require('./user.service');

exports.getProfile = async (req, res) => {
  try {
    const user = await userService.findById(req.user.id);
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, user });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.updateProfile = async (req, res) => {
  try {
    const user = await userService.updateProfile(req.user.id, req.body);
    res.json({ success: true, user });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.getAddresses = async (req, res) => {
  try {
    const user = await userService.findById(req.user.id);
    res.json({ success: true, addresses: user.addresses, defaultAddress: user.defaultAddress });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.addAddress = async (req, res) => {
  try {
    const user = await userService.addAddress(req.user.id, req.body);
    res.json({ success: true, addresses: user.addresses });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.updateAddress = async (req, res) => {
  try {
    const user = await userService.updateAddress(req.user.id, req.params.id, req.body);
    res.json({ success: true, addresses: user.addresses });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.deleteAddress = async (req, res) => {
  try {
    const user = await userService.deleteAddress(req.user.id, req.params.id);
    res.json({ success: true, addresses: user.addresses });
  } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};

exports.setDefaultAddress = async (req, res) => {
  try {
    const user = await userService.setDefaultAddress(req.user.id, req.params.id);
    res.json({ success: true, defaultAddress: user.defaultAddress });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

// Admin: list all users
exports.getAll = async (req, res) => {
  try {
    const data = await userService.findAll(req.query);
    res.json({ success: true, count: data.length, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
