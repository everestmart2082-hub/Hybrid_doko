const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
require('dotenv').config();

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

// Health Check
app.get('/', (req, res) => {
    res.json({ message: "Welcome to Quixo Server API" });
});

// Database connection
const PORT = process.env.PORT || 5000;
const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/quixo-new';

mongoose.connect(MONGODB_URI)
    .then(() => {
        console.log("Connected to MongoDB successfully");
        app.listen(PORT, () => {
            console.log(`Server is running on port ${PORT}`);
        });
    })
    .catch(err => {
        console.error("MongoDB connection error: ", err);
    });
