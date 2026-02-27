const Redis = require('ioredis');
const subscriber = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
exports.subscribe = (events, handler) => {
  subscriber.subscribe(...events);
  subscriber.on('message', (channel, message) => {
    handler(channel, JSON.parse(message));
  });
};