const express = require('express');
const router = express.Router();

const {
    registerVendor, loginVendor, verifyVendorRegistrationOtp, verifyVendorLoginOtp, getVendorProfile, updateVendorProfile, deleteVendorProfile, verifyVendorProfileOtp,
    addVendorProduct, editVendorProduct, deleteVendorProduct,
    getAllVendorOrders, setOrderPrepared,
    getVendorChart, getAllVendors
} = require('../controllers/vendor.controller');

// Auth & OTP
router.post('/registration', registerVendor);
router.post('/login', loginVendor);
router.post('/registration/otp', verifyVendorRegistrationOtp);
router.post('/login/otp', verifyVendorLoginOtp);

// Profile
router.post('/profile/get', getVendorProfile);
router.post('/profile/update', updateVendorProfile);
router.post('/profile/otp', verifyVendorProfileOtp);
router.delete('/profile/delete', deleteVendorProfile);

// Product Management
router.post('/product/add', addVendorProduct);
router.post('/product/edit', editVendorProduct);
router.delete('/product/delete', deleteVendorProduct);

// Orders
router.post('/order/all', (req, res) => res.json({ success: true, message: "Route reached" }));
router.post('/order/prepared', (req, res) => res.json({ success: true, message: "Route reached" }));

// All Vendors (Admin?)
router.get('/all', (req, res) => res.json({ success: true, message: "Route reached" }));

// Chart
router.get('/chart', (req, res) => res.json({ success: true, message: "Route reached" }));

module.exports = router;
