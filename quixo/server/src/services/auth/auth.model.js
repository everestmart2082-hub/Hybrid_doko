const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const addressSchema = new mongoose.Schema({
  label: { type: String, default: 'Home' },      // Home, Work, Other
  address: { type: String, required: true },
  city: String,
  lat: Number,
  lng: Number,
  isDefault: { type: Boolean, default: false }
}, { _id: true });

const userSchema = new mongoose.Schema({
  name: { type: String, required: [true, 'Name is required'], trim: true },
  email: { type: String, required: [true, 'Email is required'], unique: true, lowercase: true, trim: true },
  phone: { type: String, required: [true, 'Phone is required'], trim: true },
  password: { type: String, required: [true, 'Password is required'], minlength: 6, select: false },
  role: { type: String, enum: ['customer', 'vendor', 'rider', 'admin'], default: 'customer' },
  isActive: { type: Boolean, default: true },
  blacklisted: { type: Boolean, default: false },
  addresses: [addressSchema],
  otp: { code: String, expiresAt: Date },   // OTP for verification
  violations: [{ reason: String, date: { type: Date, default: Date.now } }],
  profileImage: String,
  defaultAddress: { type: mongoose.Schema.Types.ObjectId },
}, { timestamps: true });

// Index for fast lookups
userSchema.index({ email: 1 });
userSchema.index({ phone: 1 });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});

userSchema.methods.comparePassword = function (plain) {
  return bcrypt.compare(plain, this.password);
};

module.exports = mongoose.model('User', userSchema);