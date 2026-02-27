const { getIO } = require('./socket');
exports.pushOrderUpdate = (orderId, data) => {
  const io = getIO();
  io?.to(`order:${orderId}`).emit('order:update', data);
};