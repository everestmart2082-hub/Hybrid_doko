// Seed an admin user into the database
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });
const mongoose = require('mongoose');
const Admin = require('./models/Admin.model');

async function seed() {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    const exists = await Admin.findOne({ phone: '9800000000' });
    if (exists) {
        console.log('Admin already exists:', exists.name, exists.phone);
    } else {
        const admin = new Admin({ name: 'Super Admin', phone: '9800000000', email: 'admin@doko.com' });
        await admin.save();
        console.log('Admin created:', admin.name, admin.phone);
    }

    await mongoose.disconnect();
    console.log('Done');
}

seed().catch(err => { console.error(err); process.exit(1); });
