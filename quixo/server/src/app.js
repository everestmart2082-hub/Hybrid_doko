const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const { errorHandler } = require('./shared/middleware/errorHandler');

const app = express();

// ── Security & Logging ──
app.use(helmet());
app.use(morgan('dev'));
app.use(cors({
    origin: ['http://localhost:3000', 'http://localhost:3001', 'http://localhost:3002', 'http://localhost:3003'],
    credentials: true
}));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// ── Static files (product images, uploads) ──
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// ── Health Check ──
app.get('/health', (req, res) => {
    res.json({ status: 'ok', uptime: process.uptime(), timestamp: new Date().toISOString() });
});

// ── API Routes ──
app.use('/api/auth', require('./services/auth/auth.routes'));
app.use('/api/users', require('./services/user/user.routes'));
app.use('/api/products', require('./services/product/product.routes'));
app.use('/api/orders', require('./services/order/order.routes'));
app.use('/api/cart', require('./services/cart/cart.routes'));
app.use('/api/riders', require('./services/rider/rider.routes'));
app.use('/api/vendor', require('./services/vendor/vendor.routes'));
app.use('/api/payment', require('./services/payment/payment.routes'));
app.use('/api/notifications', require('./services/notification/notification.routes'));
app.use('/api/admin', require('./services/admin/admin.routes'));
app.use('/api/analytics', require('./services/analytics/analytics.routes'));
app.use('/api/inventory', require('./services/inventory/inventory.routes'));
app.use('/api/location', require('./services/location/location.routes'));
app.use('/api/reviews', require('./services/review/review.routes'));
app.use('/api/wishlist', require('./services/wishlist/wishlist.routes'));

// ── 404 Handler ──
app.use('*', (req, res) => {
    res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// ── Global Error Handler ──
app.use(errorHandler);

module.exports = app;
