const Order = require('./order.model');
const Product = require('../product/product.model');
const { emitOrderUpdate, emitToUser } = require('../../realtime/socket');

/**
 * Build filter query based on user role and query params
 */
const buildQuery = (query, user) => {
    const filter = {};

    // Role-based filtering
    if (user?.role === 'customer') filter.customerId = user.id;
    if (user?.role === 'vendor') filter.vendorId = user.id;
    if (user?.role === 'rider') filter.riderId = user.id;

    // Optional filters
    if (query.status) filter.status = query.status;
    if (query.deliveryType) filter.deliveryType = query.deliveryType;

    return filter;
};

exports.findAll = async (query = {}, user) => {
    const filter = buildQuery(query, user);
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
        Order.find(filter)
            .populate('customerId', 'name phone email')
            .populate('vendorId', 'storeName')
            .populate('riderId', 'name phone')
            .sort('-createdAt')
            .skip(skip)
            .limit(limit),
        Order.countDocuments(filter)
    ]);

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
};

exports.findById = (id) => {
    return Order.findById(id)
        .populate('customerId', 'name phone email addresses')
        .populate('vendorId', 'storeName address contact')
        .populate('riderId', 'name phone location');
};

exports.create = async (data) => {
    // ── Validate stock availability and deduct ──
    for (const item of data.items) {
        const product = await Product.findById(item.productId);
        if (!product) {
            throw Object.assign(new Error(`Product ${item.productId} not found`), { statusCode: 404 });
        }
        if (product.stock < item.qty) {
            throw Object.assign(
                new Error(`Insufficient stock for "${product.name}". Available: ${product.stock}, Requested: ${item.qty}`),
                { statusCode: 400 }
            );
        }
    }

    // Deduct stock atomically
    for (const item of data.items) {
        const result = await Product.findOneAndUpdate(
            { _id: item.productId, stock: { $gte: item.qty } },
            { $inc: { stock: -item.qty } },
            { new: true }
        );
        if (!result) {
            // Rollback previously deducted items
            for (const prev of data.items) {
                if (prev.productId === item.productId) break;
                await Product.findByIdAndUpdate(prev.productId, { $inc: { stock: prev.qty } });
            }
            throw Object.assign(new Error(`Stock changed for product. Please try again.`), { statusCode: 409 });
        }
    }

    // Generate delivery OTP for quick orders
    if (data.deliveryType === 'quick') {
        data.deliveryOTP = String(Math.floor(1000 + Math.random() * 9000));
    }

    // Add initial status to history
    data.statusHistory = [{ status: 'pending', note: 'Order placed' }];

    const order = await Order.create(data);

    // Notify vendor via socket
    try {
        emitToUser(data.vendorId, 'newOrder', {
            orderId: order._id,
            deliveryType: order.deliveryType,
            total: order.total
        });
    } catch (e) { /* socket may not be initialized in tests */ }

    return order;
};

/**
 * Status transition rules by role
 */
const ALLOWED_TRANSITIONS = {
    vendor: { pending: 'confirmed', confirmed: 'preparing' },
    rider: { preparing: 'picked', picked: 'out_for_delivery', out_for_delivery: 'delivered' },
    admin: null, // admin can set any status
};

exports.update = async (id, data, user) => {
    const order = await Order.findById(id);
    if (!order) throw Object.assign(new Error('Order not found'), { statusCode: 404 });

    // Push to status history if status changed
    if (data.status && data.status !== order.status) {
        // Role-based authorization for status changes
        if (user && user.role !== 'admin') {
            const transitions = ALLOWED_TRANSITIONS[user.role];
            if (!transitions) {
                throw Object.assign(new Error(`Role '${user.role}' cannot update order status`), { statusCode: 403 });
            }
            const allowedNext = transitions[order.status];
            if (allowedNext !== data.status) {
                throw Object.assign(
                    new Error(`Cannot transition from '${order.status}' to '${data.status}' as ${user.role}`),
                    { statusCode: 403 }
                );
            }
            // Vendor can only update their own orders
            if (user.role === 'vendor' && order.vendorId.toString() !== user.id) {
                throw Object.assign(new Error('Not your order'), { statusCode: 403 });
            }
            // Rider can only update orders assigned to them
            if (user.role === 'rider' && order.riderId?.toString() !== user.id) {
                throw Object.assign(new Error('Not your delivery'), { statusCode: 403 });
            }
        }

        order.statusHistory.push({ status: data.status, note: data.statusNote || '' });
        order.status = data.status;

        // If delivered, mark payment as paid for COD
        if (data.status === 'delivered' && order.paymentMethod === 'cashOnDelivery') {
            order.paymentStatus = 'paid';
        }

        // Emit real-time update
        try {
            emitOrderUpdate(id, { orderId: id, status: data.status });
            emitToUser(order.customerId.toString(), 'orderStatusChanged', { orderId: id, status: data.status });
        } catch (e) { /* socket may not be initialized */ }
    }

    // Update other fields (rider assignment, notes, etc.)
    const safeFields = ['riderId', 'notes', 'estimatedDelivery'];
    safeFields.forEach(key => {
        if (data[key] !== undefined) order[key] = data[key];
    });

    return order.save();
};

exports.cancel = async (id, userId) => {
    const order = await Order.findById(id);
    if (!order) throw Object.assign(new Error('Order not found'), { statusCode: 404 });
    if (order.customerId.toString() !== userId) throw Object.assign(new Error('Not your order'), { statusCode: 403 });
    if (['delivered', 'cancelled'].includes(order.status)) {
        throw Object.assign(new Error(`Cannot cancel an order that is ${order.status}`), { statusCode: 400 });
    }

    order.status = 'cancelled';
    order.statusHistory.push({ status: 'cancelled', note: 'Cancelled by customer' });

    // Restore stock for cancelled items
    for (const item of order.items) {
        await Product.findByIdAndUpdate(item.productId, { $inc: { stock: item.qty } });
    }

    // Emit real-time update
    try {
        emitOrderUpdate(id, { orderId: id, status: 'cancelled' });
        emitToUser(order.vendorId.toString(), 'orderCancelled', { orderId: id });
    } catch (e) { }

    return order.save();
};

exports.remove = (id) => Order.findByIdAndDelete(id);
