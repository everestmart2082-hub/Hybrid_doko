const express = require('express');
const router = express.Router();

const {
    registerRider, loginRider, verifyRiderRegistrationOtp, verifyRiderLoginOtp, getRiderProfile, updateRiderProfile, deleteRiderProfile, verifyRiderProfileOtp,
    getRiderDashboard, getRiderNotifications, getAllRiders
} = require('../controllers/rider.controller');
const { generateOTP } = require('../controllers/auth.helper');

// Auth & OTP
router.post('/registration', registerRider);
router.post('/login', loginRider);
router.post('/registration/otp', verifyRiderRegistrationOtp);
router.post('/login/otp', verifyRiderLoginOtp);
router.post('/generate_otp', (req, res) => res.json({ success: true, message: generateOTP() }));

// Profile
router.post('/profile/get', getRiderProfile);
router.post('/profile/update', updateRiderProfile);
router.post('/profile/otp', verifyRiderProfileOtp);
router.delete('/profile/delete', deleteRiderProfile);

// Dashboard & Notifications
router.post('/dashboard', getRiderDashboard);
router.post('/notification', getRiderNotifications);

// All Riders
router.get('/all', getAllRiders);

module.exports = router;
