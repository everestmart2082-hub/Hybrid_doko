const analyticsService = require('./analytics.service');

exports.getDashboard = async (req, res) => {
  try {
    const data = await analyticsService.getDashboard();
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getSalesOverTime = async (req, res) => {
  try {
    const data = await analyticsService.getSalesOverTime(req.query);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getTopProducts = async (req, res) => {
  try {
    const data = await analyticsService.getTopProducts(req.query);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getOrderStats = async (req, res) => {
  try {
    const data = await analyticsService.getOrderStats();
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getRevenueByVendor = async (req, res) => {
  try {
    const data = await analyticsService.getRevenueByVendor(req.query);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getPaymentStats = async (req, res) => {
  try {
    const data = await analyticsService.getPaymentStats();
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
