const cartService = require('./cart.service');

exports.get = async (req, res) => {
  try {
    const cart = await cartService.getByUser(req.user.id);
    res.json({ success: true, cart });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.addItem = async (req, res) => {
  try {
    const cart = await cartService.addItem(req.user.id, req.body.productId, req.body.quantity);
    res.json({ success: true, cart });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.updateItem = async (req, res) => {
  try {
    const cart = await cartService.updateItem(req.user.id, req.params.id, req.body.qty);
    res.json({ success: true, cart });
  } catch (err) { res.status(err.statusCode || 400).json({ success: false, message: err.message }); }
};

exports.removeItem = async (req, res) => {
  try {
    const cart = await cartService.removeItem(req.user.id, req.params.id);
    res.json({ success: true, cart });
  } catch (err) { res.status(err.statusCode || 500).json({ success: false, message: err.message }); }
};

exports.clear = async (req, res) => {
  try {
    await cartService.clear(req.user.id);
    res.json({ success: true, message: 'Cart cleared' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
