const Vendor = require('./vendor.model');

exports.findAll = (query = {}) => {
    const filter = {};
    if (query.status) filter.status = query.status;
    if (query.search) {
        filter.$or = [
            { storeName: { $regex: query.search, $options: 'i' } },
            { ownerName: { $regex: query.search, $options: 'i' } }
        ];
    }
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    return Vendor.find(filter).populate('userId', 'name email phone').sort('-createdAt').skip((page - 1) * limit).limit(limit);
};

exports.findById = (id) => Vendor.findById(id).populate('userId', 'name email phone');

exports.findByUserId = (userId) => Vendor.findOne({ userId }).populate('userId', 'name email phone');

exports.update = async (id, data) => {
    const allowed = ['storeName', 'ownerName', 'pan', 'address', 'contact', 'businessType', 'description', 'logo'];
    const update = {};
    allowed.forEach(k => { if (data[k] !== undefined) update[k] = data[k]; });
    return Vendor.findByIdAndUpdate(id, update, { new: true, runValidators: true });
};

exports.updateStatus = (id, status) => Vendor.findByIdAndUpdate(id, { status }, { new: true });

exports.getDashboard = async (vendorId) => {
    const Order = require('../order/order.model');
    const Product = require('../product/product.model');
    const [totalProducts, totalOrders, pendingOrders, vendor] = await Promise.all([
        Product.countDocuments({ vendorId, isHidden: false }),
        Order.countDocuments({ vendorId }),
        Order.countDocuments({ vendorId, status: 'pending' }),
        Vendor.findById(vendorId)
    ]);
    return { totalProducts, totalOrders, pendingOrders, revenue: vendor?.revenue || 0, rating: vendor?.rating || 0 };
};
