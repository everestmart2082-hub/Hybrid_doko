const { getIO } = require('./socket');
exports.pushOTPEvent = (customerId, otp) => {
  const io = getIO();
  io?.to(`user:${customerId}`).emit('delivery:otp', { otp });
};