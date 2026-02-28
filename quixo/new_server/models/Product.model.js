const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
    name: { type: String, required: true },
    brand: { type: String },
    shortDescriptions: { type: String },
    description: { type: String },
    pricePerUnit: { type: Number, required: true },
    unit: { type: String }, // kg, pc, etc.
    discount: { type: Number, default: 0 },
    productCategory: { type: mongoose.Schema.Types.ObjectId, ref: 'Category' },
    deliveryCategory: { type: String, enum: ['quick', 'ecommerce'] },
    stock: { type: Number, default: 0 },
    photos: [{ type: String }],
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
    rating: { type: Number, default: 0 },
    approved: { type: Boolean, default: false },
    hidden: { type: Boolean, default: false }
}, { timestamps: true });

module.exports = mongoose.model('Product', productSchema);
