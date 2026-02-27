const jwt = require('jsonwebtoken');
const User = require('../../services/auth/auth.model');

/**
 * Core auth guard — verifies JWT, loads user from DB, checks suspension.
 */
const authGuard = async (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id).select('-password');
    if (!user) return res.status(401).json({ success: false, message: 'User no longer exists' });
    if (user.blacklisted) return res.status(403).json({ success: false, message: 'Account suspended. Contact support.' });

    req.user = { id: user._id, role: user.role, name: user.name, email: user.email };
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError')
      return res.status(401).json({ success: false, message: 'Token expired' });
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

/**
 * Role-based guard factories
 * Usage:  router.post('/', authGuard, isVendor, ctrl.create)
 */
const authorize = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user.role)) {
    return res.status(403).json({ success: false, message: `Role '${req.user.role}' not authorized for this route` });
  }
  next();
};

const isAdmin = authorize('admin');
const isVendor = authorize('vendor');
const isRider = authorize('rider');
const isUser = authorize('customer');

module.exports = { authGuard, authorize, isAdmin, isVendor, isRider, isUser };