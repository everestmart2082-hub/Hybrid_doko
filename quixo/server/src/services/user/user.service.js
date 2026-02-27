const User = require('../auth/auth.model');

exports.findAll = (query = {}) => {
    const filter = {};
    if (query.role) filter.role = query.role;
    if (query.search) {
        filter.$or = [
            { name: { $regex: query.search, $options: 'i' } },
            { email: { $regex: query.search, $options: 'i' } },
            { phone: { $regex: query.search, $options: 'i' } }
        ];
    }
    const page = parseInt(query.page) || 1;
    const limit = parseInt(query.limit) || 20;
    return User.find(filter).select('-password').sort('-createdAt').skip((page - 1) * limit).limit(limit);
};

exports.findById = (id) => User.findById(id).select('-password');

exports.updateProfile = async (id, data) => {
    const allowed = ['name', 'email', 'phone', 'profileImage'];
    const update = {};
    allowed.forEach(k => { if (data[k] !== undefined) update[k] = data[k]; });
    return User.findByIdAndUpdate(id, update, { new: true, runValidators: true }).select('-password');
};

exports.addAddress = async (userId, address) => {
    const user = await User.findById(userId);
    if (!user) throw Object.assign(new Error('User not found'), { statusCode: 404 });
    user.addresses.push(address);
    if (user.addresses.length === 1) user.defaultAddress = user.addresses[0]._id;
    return user.save();
};

exports.updateAddress = async (userId, addressId, data) => {
    const user = await User.findById(userId);
    if (!user) throw Object.assign(new Error('User not found'), { statusCode: 404 });
    const addr = user.addresses.id(addressId);
    if (!addr) throw Object.assign(new Error('Address not found'), { statusCode: 404 });
    Object.assign(addr, data);
    return user.save();
};

exports.deleteAddress = async (userId, addressId) => {
    const user = await User.findById(userId);
    if (!user) throw Object.assign(new Error('User not found'), { statusCode: 404 });
    user.addresses = user.addresses.filter(a => a._id.toString() !== addressId);
    return user.save();
};

exports.setDefaultAddress = async (userId, addressId) => {
    return User.findByIdAndUpdate(userId, { defaultAddress: addressId }, { new: true }).select('-password');
};
