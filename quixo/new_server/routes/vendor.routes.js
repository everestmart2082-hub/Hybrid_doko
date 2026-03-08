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
router.get('/orders', getAllVendorOrders);
router.post('/order/all', getAllVendorOrders); // keeping both given payload ambiguity
router.post('/order/prepared', setOrderPrepared);

// All Vendors
router.get('/all', getAllVendors);

// Chart
router.get('/chart', getVendorChart);

module.exports = router;
