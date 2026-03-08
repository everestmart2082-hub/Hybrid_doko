const express = require('express');
const router = express.Router();



const {
    adminLogin, addAdminOtp, verifyAdminOtp, getAdminProfile, updateAdminProfile, addAdminProfile, deleteAdminProfile,
    setRiderApproval, setRiderSuspension, setRiderBlacklist,
    setUserApproval, setUserSuspension, setUserBlacklist,
    setVendorApproval, setVendorSuspension, setVendorBlacklist,
    addEmployee, updateEmployee, deleteEmployee,
    updateVendorViolations, updateUserViolations, updateRiderViolations, updateEmployeeViolations,
    getAdminProductsOptions, getAdminProductById, setAdminProductApproval, setAdminProductHidden
} = require('../controllers/admin.controller');

// Auth
router.post('/login', adminLogin);
router.post('/login/otp', verifyAdminOtp);

// Profile
router.post('/profile/get', getAdminProfile);
router.post('/profile/update', updateAdminProfile);
router.post('/profile/add', addAdminProfile);
router.delete('/profile/delete', deleteAdminProfile);
router.post('/profile/otp', verifyAdminOtp);
router.post('/profile/add/otp', addAdminOtp);

// Approvals & Suspensions
router.post('/rider/approve', setRiderApproval);
router.post('/rider/suspension', setRiderSuspension);
router.post('/rider/blacklist', setRiderBlacklist);

router.post('/user/approve', setUserApproval);
router.post('/user/suspension', setUserSuspension);
router.post('/user/blacklist', setUserBlacklist);

router.post('/vender/approve', setVendorApproval);
router.post('/vender/suspension', setVendorSuspension);
router.post('/vender/blacklist', setVendorBlacklist);

// Product Management
router.get('/product/all', getAdminProductsOptions);
router.get('/product/id', getAdminProductById);
router.post('/product/approve', setAdminProductApproval);
router.post('/product/hide', setAdminProductHidden);

// Employee Management
router.post('/employee/add', addEmployee);
router.post('/employee/update', updateEmployee);
router.delete('/employee/delete', deleteEmployee);

// Vender, Rider, User Violations
router.post('/vender/violations/update', updateVendorViolations);
router.post('/user/violations/update', updateUserViolations);
router.post('/rider/violations/update', updateRiderViolations);
router.post('/employee/violations/update', updateEmployeeViolations); // Moved next to violations for clarity

// Notifications (Direct stubs for pure pings based on prompt specification where payload usually manages message)
router.post('/vender/notification', (req, res) => res.json({ success: true, message: "success" }));
router.post('/rider/notification', (req, res) => res.json({ success: true, message: "success" }));
router.post('/user/notification', (req, res) => res.json({ success: true, message: "success" }));

module.exports = router;
