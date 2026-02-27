const redis = require('../config/redis');
exports.publish = async (event, data) => {
  await redis.publish(event, JSON.stringify(data));
  console.log(`📢 Event published: ${event}`);
};