const productService = require('./product.service');
const Vendor = require('../vendor/vendor.model');

exports.getAll = async (req, res) => {
  try {
    const result = await productService.findAll(req.query);
    res.json({ success: true, ...result });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await productService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.create = async (req, res) => {
  try {
    // Look up vendor profile and inject vendorId from server side
    const vendor = await Vendor.findOne({ userId: req.user.id });
    if (!vendor) return res.status(404).json({ success: false, message: 'Vendor profile not found' });
    if (vendor.status !== 'approved') {
      return res.status(403).json({ success: false, message: 'Vendor not approved yet' });
    }

    const data = await productService.create({ ...req.body, vendorId: vendor._id });
    res.status(201).json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};

exports.update = async (req, res) => {
  try {
    // Verify vendor ownership
    const product = await productService.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });

    const vendor = await Vendor.findOne({ userId: req.user.id });
    if (!vendor || product.vendorId._id.toString() !== vendor._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not your product' });
    }

    const data = await productService.update(req.params.id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};

exports.remove = async (req, res) => {
  try {
    // Verify vendor ownership
    const product = await productService.findById(req.params.id);
    if (!product) return res.status(404).json({ success: false, message: 'Product not found' });

    const vendor = await Vendor.findOne({ userId: req.user.id });
    if (!vendor || product.vendorId._id.toString() !== vendor._id.toString()) {
      return res.status(403).json({ success: false, message: 'Not your product' });
    }

    await productService.remove(req.params.id);
    res.json({ success: true, message: 'Deleted successfully' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
