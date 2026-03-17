const mongoose = require('mongoose');

const orderSchema = new mongoose.Schema({
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor' },
    customerId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
    riderId: { type: mongoose.Schema.Types.ObjectId, ref: 'Rider' },
    products: [{
        productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
        number: { type: Number, default: 1 },
        pricePerUnit: { type: Number }, // Snapshot at purchase (after discount)
        status: {
            type: String,
            enum: ['preparing', 'prepared', 'cancelled'],
            default: 'preparing'
        }
    }],
    status: {
        type: String,
        enum: ['preparing', 'prepared', 'pending', 'delivered', 'cancelled', 'returned'],
        default: 'preparing'
    },
    deliveryCategory: { type: String, enum: ['quick', 'ecommerce'] },
    dateOfOrder: { type: Date, default: Date.now },
    dateOfDelivery: { type: Date },
    deliveryCharge: { type: Number, default: 0 },
    subTotal: { type: Number, default: 0 },
    tax: { type: Number, default: 0 },
    total: { type: Number, default: 0 },
    otp: { type: String },
    deliveryAddress: {
        address: String,
        city: String,
        landmark: String,
        phone: String
    },
    paymentMethod: { type: String, enum: ['esewa', 'khalti', 'fonepay', 'cash on delivary'] }
}, { timestamps: true });

module.exports = mongoose.model('Order', orderSchema);
