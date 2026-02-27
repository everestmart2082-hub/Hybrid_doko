const User = require('./auth.model');

exports.findAll  = (query = {})        => User.find(query);
exports.findById = (id)                => User.findById(id);
exports.create   = (data)              => User.create(data);
exports.update   = (id, data)          => User.findByIdAndUpdate(id, data, { new: true });
exports.remove   = (id)                => User.findByIdAndDelete(id);
