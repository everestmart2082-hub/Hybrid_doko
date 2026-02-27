const mongoose = require('mongoose');
const inventorySchema = new mongoose.Schema({
  productId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Product', unique: true },
  stock:       { type: Number, default: 0 },
  reserved:    { type: Number, default: 0 },
  lastUpdated: { type: Date, default: Date.now },
}, { timestamps: true });
module.exports = mongoose.model('Inventory', inventorySchema);
