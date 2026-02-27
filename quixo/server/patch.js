const fs = require("fs");
const path = require("path");

// Run this from inside quixo/server  OR  from quixo root
const SERVER = fs.existsSync("src") ? "." : "server";
const base = (p) => path.join(SERVER, p);
const write = (p, content) => {
    fs.mkdirSync(path.dirname(base(p)), { recursive: true });
    fs.writeFileSync(base(p), content, "utf8");
    console.log("  ✅ fixed:", p);
};

console.log("\n🔧 Quixo Server — Patch Script\n");

/* ── 1. user.model.js → reuse User from auth ── */
write("src/services/user/user.model.js",
    `// User model lives in auth service — re-exported here for user service
module.exports = require('../auth/auth.model');
`);

/* ── 2. analytics has no mongoose model — replace service with aggregation stub ── */
write("src/services/analytics/analytics.model.js",
    `// Analytics uses aggregation pipelines on Order/Product/User collections
// No standalone mongoose model needed — this file is intentionally a stub
module.exports = null;
`);

write("src/services/analytics/analytics.service.js",
    `const mongoose = require('mongoose');

exports.findAll = async (query = {}) => {
  // placeholder — will use Order.aggregate() once Order model is loaded
  return { message: 'Analytics aggregation will go here', query };
};
exports.findById = async (id) => ({ id });
exports.create   = async (data) => data;
exports.update   = async (id, data) => data;
exports.remove   = async (id) => ({ id });
`);

/* ── 3. location has no mongoose model — replace service with Maps stub ── */
write("src/services/location/location.model.js",
    `// Location uses Google Maps API — no mongoose model needed
module.exports = null;
`);

write("src/services/location/location.service.js",
    `const axios = require('axios');

exports.findAll  = async () => [];
exports.findById = async (id) => ({ id });
exports.create   = async (data) => data;
exports.update   = async (id, data) => data;
exports.remove   = async (id) => ({ id });

exports.getDistance = async (origin, destination) => {
  try {
    const key = process.env.GOOGLE_MAPS_API_KEY;
    const url = \`https://maps.googleapis.com/maps/api/distancematrix/json\` +
                \`?origins=\${origin}&destinations=\${destination}&key=\${key}\`;
    const res = await axios.get(url);
    return res.data.rows[0]?.elements[0] || null;
  } catch (err) {
    console.error('Maps error:', err.message);
    return null;
  }
};
`);

/* ── 4. notification model was created inline but service references wrong model name ── */
write("src/services/notification/notification.model.js",
    `const mongoose = require('mongoose');
const notificationSchema = new mongoose.Schema({
  userId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  type:      { type: String, enum: ['order','payment','delivery','system'], default: 'system' },
  title:     { type: String, required: true },
  message:   { type: String, required: true },
  isRead:    { type: Boolean, default: false },
  orderId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
}, { timestamps: true });
module.exports = mongoose.model('Notification', notificationSchema);
`);

/* ── 5. cart model ── */
write("src/services/cart/cart.model.js",
    `const mongoose = require('mongoose');
const cartSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  items: [{
    productId: { type: mongoose.Schema.Types.ObjectId, ref: 'Product' },
    name:  String,
    image: String,
    price: Number,
    qty:   { type: Number, default: 1 },
  }],
}, { timestamps: true });
module.exports = mongoose.model('Cart', cartSchema);
`);

/* ── 6. inventory model ── */
write("src/services/inventory/inventory.model.js",
    `const mongoose = require('mongoose');
const inventorySchema = new mongoose.Schema({
  productId:   { type: mongoose.Schema.Types.ObjectId, ref: 'Product', unique: true },
  stock:       { type: Number, default: 0 },
  reserved:    { type: Number, default: 0 },
  lastUpdated: { type: Date, default: Date.now },
}, { timestamps: true });
module.exports = mongoose.model('Inventory', inventorySchema);
`);

/* ── 7. upload.js — local disk (no multer-storage-cloudinary needed) ── */
write("src/shared/middleware/upload.js",
    `const multer = require('multer');
const path   = require('path');
const fs     = require('fs');

const uploadsDir = path.join(__dirname, '../../../uploads');
if (!fs.existsSync(uploadsDir)) fs.mkdirSync(uploadsDir, { recursive: true });

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, uploadsDir),
  filename:    (req, file, cb) => cb(null, Date.now() + '-' + file.originalname.replace(/\\s/g, '_')),
});

const fileFilter = (req, file, cb) => {
  const allowed = /jpeg|jpg|png|webp|pdf/;
  cb(null, allowed.test(path.extname(file.originalname).toLowerCase()));
};

module.exports = multer({ storage, fileFilter, limits: { fileSize: 5 * 1024 * 1024 } });
`);

/* ── 8. remove multer-storage-cloudinary from package.json ── */
const pkgPath = base("package.json");
const pkg = JSON.parse(fs.readFileSync(pkgPath, "utf8"));
delete pkg.dependencies["multer-storage-cloudinary"];
pkg.dependencies["multer"] = "^1.4.5-lts.1";
fs.writeFileSync(pkgPath, JSON.stringify(pkg, null, 2), "utf8");
console.log("  ✅ fixed: package.json (removed multer-storage-cloudinary)");

/* ── 9. create uploads folder ── */
const uploadsPath = base("uploads");
if (!fs.existsSync(uploadsPath)) {
    fs.mkdirSync(uploadsPath, { recursive: true });
    console.log("  ✅ created: uploads/");
}

// .gitignore uploads
const gi = base(".gitignore");
const giContent = fs.existsSync(gi) ? fs.readFileSync(gi, "utf8") : "";
if (!giContent.includes("uploads/")) {
    fs.appendFileSync(gi, "\nuploads/\n");
    console.log("  ✅ added uploads/ to .gitignore");
}

console.log(`
✅ All patches applied!

Now run:
  npm install
  npm run dev

You should see:
  🚀 Quixo server running on port 5000
  ✅ MongoDB connected
  ✅ Redis connected
`);