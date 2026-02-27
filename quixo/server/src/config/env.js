module.exports = {
  PORT:           process.env.PORT           || 5000,
  MONGO_URI:      process.env.MONGO_URI,
  JWT_SECRET:     process.env.JWT_SECRET,
  JWT_ADMIN_SECRET: process.env.JWT_ADMIN_SECRET,
  REDIS_URL:      process.env.REDIS_URL,
  ESEWA_MERCHANT: process.env.ESEWA_MERCHANT_ID,
  SPARROW_TOKEN:  process.env.SPARROW_SMS_TOKEN,
  MAPS_KEY:       process.env.GOOGLE_MAPS_API_KEY,
};