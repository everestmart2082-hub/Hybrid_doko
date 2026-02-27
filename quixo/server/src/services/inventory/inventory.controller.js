const inventoryService = require('./inventory.service');

exports.getAll = async (req, res) => {
  try {
    const result = await inventoryService.findAll(req.query);
    res.json({ success: true, ...result });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await inventoryService.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.create = async (req, res) => {
  try {
    const data = await inventoryService.create(req.body);
    res.status(201).json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.update = async (req, res) => {
  try {
    const data = await inventoryService.update(req.params.id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.remove = async (req, res) => {
  try {
    await inventoryService.remove(req.params.id);
    res.json({ success: true, message: 'Deleted successfully' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getLowStock = async (req, res) => {
  try {
    const data = await inventoryService.getLowStock(req.query);
    res.json({ success: true, count: data.length, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
