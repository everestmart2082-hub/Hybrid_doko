const jwt = require('jsonwebtoken');
const User = require('./auth.model');
const Vendor = require('../vendor/vendor.model');
const Rider = require('../rider/rider.model');

const signToken = (payload, secret, expiresIn = '7d') =>
  jwt.sign(payload, secret, { expiresIn });

/* ── REGISTER ── */
exports.register = async (req, res) => {
  try {
    const { name, email, phone, password, role = 'customer' } = req.body;

    const existing = await User.findOne({ email });
    if (existing) return res.status(400).json({ success: false, message: 'Email already registered' });

    const user = await User.create({ name, email, phone, password, role });

    // If vendor/rider → create their profile too
    if (role === 'vendor') await Vendor.create({ userId: user._id, storeName: `${name}'s Store`, ownerName: name });
    if (role === 'rider') await Rider.create({ userId: user._id, name, phone, email });

    const token = signToken({ id: user._id, role: user.role }, process.env.JWT_SECRET);

    res.status(201).json({
      success: true,
      token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

/* ── LOGIN ── */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email }).select('+password');
    if (!user) return res.status(401).json({ success: false, message: 'Invalid email or password' });

    if (user.blacklisted) return res.status(403).json({ success: false, message: 'Account suspended' });

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(401).json({ success: false, message: 'Invalid email or password' });

    const token = signToken({ id: user._id, role: user.role }, process.env.JWT_SECRET);

    res.json({
      success: true,
      token,
      user: { id: user._id, name: user.name, email: user.email, role: user.role }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

/* ── ADMIN LOGIN (separate secret) ── */
exports.adminLogin = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email, role: 'admin' }).select('+password');
    if (!user) return res.status(401).json({ success: false, message: 'Not authorized' });

    const isMatch = await user.comparePassword(password);
    if (!isMatch) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = signToken({ id: user._id, role: 'admin' }, process.env.JWT_ADMIN_SECRET);

    res.json({
      success: true,
      token,
      admin: { id: user._id, name: user.name, email: user.email }
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};

/* ── GET CURRENT USER (me) ── */
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, user });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
};
