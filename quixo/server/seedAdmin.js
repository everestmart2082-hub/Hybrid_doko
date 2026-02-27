require('dotenv').config();
const mongoose = require('mongoose');
const User = require('./src/services/auth/auth.model');

mongoose.connect(process.env.MONGO_URI).then(async () => {
    const exists = await User.findOne({ role: 'admin' });
    if (exists) { console.log('Admin already exists:', exists.email); process.exit(); }

    await User.create({
        name: 'Super Admin',
        email: 'admin@quixo.com',
        phone: '9800000000',
        password: 'Admin@1234',
        role: 'admin',
    });

    console.log('✅ Admin created → email: admin@quixo.com  password: Admin@1234');
    mongoose.disconnect();
});
