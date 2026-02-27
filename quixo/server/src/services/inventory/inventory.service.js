const Inventory = require('./inventory.model');
const Product = require('../product/product.model');

/**
 * Get all inventory records with filtering and pagination.
 */
exports.findAll = async (query = {}) => {
    const filter = {};
    if (query.productId) filter.productId = query.productId;

    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
        Inventory.find(filter)
            .populate('productId', 'name category stock price images')
            .sort('-lastUpdated')
            .skip(skip)
            .limit(limit),
        Inventory.countDocuments(filter)
    ]);

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
};

exports.findById = (id) => Inventory.findById(id).populate('productId', 'name category stock price');

/**
 * Create/sync inventory record for a product.
 */
exports.create = async (data) => {
    const product = await Product.findById(data.productId);
    if (!product) throw Object.assign(new Error('Product not found'), { statusCode: 404 });

    const existing = await Inventory.findOne({ productId: data.productId });
    if (existing) throw Object.assign(new Error('Inventory record already exists for this product'), { statusCode: 400 });

    return Inventory.create({
        productId: data.productId,
        stock: data.stock || product.stock,
        reserved: data.reserved || 0,
        lastUpdated: new Date()
    });
};

/**
 * Update inventory (adjust stock, reserved count).
 */
exports.update = async (id, data) => {
    const update = { lastUpdated: new Date() };
    if (data.stock !== undefined) update.stock = data.stock;
    if (data.reserved !== undefined) update.reserved = data.reserved;

    const inventory = await Inventory.findByIdAndUpdate(id, update, { new: true, runValidators: true });
    if (!inventory) throw Object.assign(new Error('Inventory record not found'), { statusCode: 404 });

    // Sync product stock
    if (data.stock !== undefined) {
        await Product.findByIdAndUpdate(inventory.productId, { stock: data.stock });
    }

    return inventory;
};

exports.remove = (id) => Inventory.findByIdAndDelete(id);

/**
 * Get low-stock items (stock <= threshold).
 */
exports.getLowStock = async (query = {}) => {
    const threshold = parseInt(query.threshold) || 10;

    const lowStockProducts = await Product.find({
        stock: { $lte: threshold, $gte: 0 },
        isHidden: false,
        isApproved: true
    })
        .select('name category stock price vendorId images')
        .populate('vendorId', 'storeName')
        .sort('stock')
        .limit(50);

    return lowStockProducts;
};

/**
 * Reserve stock for an order (called during order creation).
 */
exports.reserveStock = async (productId, qty) => {
    const inventory = await Inventory.findOne({ productId });
    if (!inventory) return; // If no inventory record, product.stock is the source of truth

    if (inventory.stock - inventory.reserved < qty) {
        throw Object.assign(new Error('Insufficient available stock'), { statusCode: 400 });
    }

    inventory.reserved += qty;
    inventory.lastUpdated = new Date();
    return inventory.save();
};

/**
 * Release reserved stock (called during order cancellation).
 */
exports.releaseStock = async (productId, qty) => {
    const inventory = await Inventory.findOne({ productId });
    if (!inventory) return;

    inventory.reserved = Math.max(0, inventory.reserved - qty);
    inventory.lastUpdated = new Date();
    return inventory.save();
};
