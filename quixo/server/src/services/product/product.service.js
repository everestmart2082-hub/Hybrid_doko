const Product = require('./product.model');

/**
 * Find all products with filtering, searching, sorting, and pagination.
 * Returns data + pagination metadata for frontend.
 */
exports.findAll = async (query = {}) => {
    const filter = { isHidden: false, isApproved: true };

    // Category filter
    if (query.category) filter.category = query.category;
    // Delivery type filter
    if (query.deliveryType) filter.deliveryType = query.deliveryType;
    // Price range
    if (query.minPrice || query.maxPrice) {
        filter.price = {};
        if (query.minPrice) filter.price.$gte = Number(query.minPrice);
        if (query.maxPrice) filter.price.$lte = Number(query.maxPrice);
    }
    // Rating filter
    if (query.rating) filter['rating.average'] = { $gte: Number(query.rating) };
    // In stock
    if (query.inStock === 'true') filter.stock = { $gt: 0 };
    // Vendor filter
    if (query.vendorId) filter.vendorId = query.vendorId;
    // Brand filter
    if (query.brand) filter.brand = query.brand;

    // Text search
    if (query.search) {
        filter.$text = { $search: query.search };
    }

    // Pagination
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    const skip = (page - 1) * limit;

    // Sort
    let sort = '-createdAt';
    if (query.sort === 'price_asc') sort = 'price';
    if (query.sort === 'price_desc') sort = '-price';
    if (query.sort === 'rating') sort = '-rating.average';
    if (query.sort === 'name') sort = 'name';
    if (query.sort === 'popular') sort = '-rating.count';

    const [data, total] = await Promise.all([
        Product.find(filter)
            .populate('vendorId', 'storeName rating')
            .sort(sort)
            .skip(skip)
            .limit(limit),
        Product.countDocuments(filter)
    ]);

    return { data, total, page, limit, totalPages: Math.ceil(total / limit) };
};

exports.findById = (id) => {
    return Product.findById(id)
        .populate('vendorId', 'storeName address rating ownerName');
};

exports.create = (data) => Product.create(data);

exports.update = (id, data) => {
    return Product.findByIdAndUpdate(id, data, { new: true, runValidators: true });
};

exports.remove = (id) => Product.findByIdAndDelete(id);
