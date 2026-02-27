const Rider = require('./rider.model');

exports.findAll = (query = {}) => {
    const filter = {};
    if (query.status) filter.status = query.status;
    if (query.isAvailable === 'true') filter.isAvailable = true;
    if (query.search) {
        filter.$or = [
            { name: { $regex: query.search, $options: 'i' } },
            { phone: { $regex: query.search, $options: 'i' } }
        ];
    }
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    return Rider.find(filter).populate('userId', 'name email phone').sort('-createdAt').skip((page - 1) * limit).limit(limit);
};

exports.findById = (id) => Rider.findById(id).populate('userId', 'name email phone');

exports.findByUserId = (userId) => Rider.findOne({ userId }).populate('userId', 'name email phone');

exports.update = async (id, data) => {
    return Rider.findByIdAndUpdate(id, data, { new: true, runValidators: true });
};

exports.toggleAvailability = async (userId) => {
    const rider = await Rider.findOne({ userId });
    if (!rider) throw Object.assign(new Error('Rider not found'), { statusCode: 404 });
    rider.isAvailable = !rider.isAvailable;
    return rider.save();
};

exports.updateLocation = async (userId, location) => {
    return Rider.findOneAndUpdate({ userId }, { location }, { new: true });
};

exports.getDashboard = async (riderId) => {
    const Order = require('../order/order.model');
    const [activeOrders, deliveredOrders, rider] = await Promise.all([
        Order.countDocuments({ riderId, status: { $in: ['picked', 'out_for_delivery'] } }),
        Order.countDocuments({ riderId, status: 'delivered' }),
        Rider.findById(riderId)
    ]);
    return { activeOrders, deliveredOrders, earnings: rider?.earnings || 0, rating: rider?.rating || 0 };
};
