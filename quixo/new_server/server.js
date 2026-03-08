const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '.env') });

const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
const userRoutes = require('./routes/user.routes');
const vendorRoutes = require('./routes/vendor.routes');
const riderRoutes = require('./routes/rider.routes');
const adminRoutes = require('./routes/admin.routes');
const productRoutes = require('./routes/product.routes');

app.use('/api/user', userRoutes);
app.use('/api/vender', vendorRoutes);
app.use('/api/rider', riderRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/product', productRoutes);

// Database connection
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://127.0.0.1:27017/quixo-new';

mongoose.connect(MONGODB_URI)
    .then(() => {
        console.log("Connected to MongoDB successfully for new_server");
        app.listen(PORT, '0.0.0.0', () => {
            console.log(`🚀 Quixo new_server running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error("MongoDB connection error: ", err);
    });
