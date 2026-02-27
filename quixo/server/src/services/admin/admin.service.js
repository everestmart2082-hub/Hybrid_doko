const Admin = require('./admin.model');

exports.findAll  = (query = {})        => Admin.find(query);
exports.findById = (id)                => Admin.findById(id);
exports.create   = (data)              => Admin.create(data);
exports.update   = (id, data)          => Admin.findByIdAndUpdate(id, data, { new: true });
exports.remove   = (id)                => Admin.findByIdAndDelete(id);
