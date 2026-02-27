const { getIO } = require('./socket');
exports.pushNewOrder = (riderId, order) => {
  const io = getIO();
  io?.to(`user:${riderId}`).emit('order:new', order);
};