const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  name: { type: String, required: [true, 'Product name is required'], trim: true },
  shortDescription: { type: String, maxlength: 200 },
  description: { type: String },
  brand: { type: String, trim: true },
  price: { type: Number, required: [true, 'Price is required'], min: 0 },
  discount: { type: Number, default: 0, min: 0, max: 100 },
  unit: { type: String, default: 'pcs' },    // pcs, kg, litre, dozen
  category: { type: String, required: [true, 'Category is required'] },
  deliveryType: { type: String, enum: ['quick', 'ecommerce'], required: true },
  stock: { type: Number, default: 0, min: 0 },
  images: [String],
  tags: [String],
  specs: {
    ram: String,
    storage: String,
    os: String,
    color: [String],
    weight: String,
    size: String
  },
  rating: {
    average: { type: Number, default: 0 },
    count: { type: Number, default: 0 }
  },
  isHidden: { type: Boolean, default: false },
  isApproved: { type: Boolean, default: false },
}, { timestamps: true });

// Text index for search
productSchema.index({ name: 'text', description: 'text', tags: 'text', brand: 'text' });
// Compound indexes for filtering
productSchema.index({ category: 1, deliveryType: 1 });
productSchema.index({ vendorId: 1, isApproved: 1 });
productSchema.index({ price: 1 });

// Virtual: final price after discount
productSchema.virtual('finalPrice').get(function () {
  return this.price - (this.price * this.discount / 100);
});

productSchema.set('toJSON', { virtuals: true });

module.exports = mongoose.model('Product', productSchema);