const redis = require('../../config/redis');
const crypto = require('crypto');

exports.generateOTP = async (key, ttl = 300) => {
  const otp = crypto.randomInt(100000, 999999).toString();
  await redis.setex(`otp:${key}`, ttl, otp);
  return otp;
};

exports.verifyOTP = async (key, otp) => {
  const stored = await redis.get(`otp:${key}`);
  if (stored === otp) { await redis.del(`otp:${key}`); return true; }
  return false;
};