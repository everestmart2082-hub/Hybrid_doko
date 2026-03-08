const express = require('express');
const router = express.Router();

const {
    registerUser, loginUser, verifyRegistrationOtp, verifyLoginOtp, getUserProfile, updateUserProfile, deleteUserProfile, verifyUserProfileOtp,
    addToCart, removeFromCart, getCart, checkoutCart, getPaymentLink, getAllUserOrders, cancelUserOrder, reorderUserOrder, setOrderDeliveredUser,
    getAllAddresses, addUserAddress, deleteUserAddress, updateUserAddress,
    addToWishlist, removeFromWishlist, getWishlist,
    getUserNotifications, submitReview, rateProduct, rateRider, getAllUsers
} = require('../controllers/user.controller');

// Auth & OTP
router.post('/registration', registerUser);
router.post('/login', loginUser);
router.post('/registration/otp', verifyRegistrationOtp);
router.post('/login/otp', verifyLoginOtp);

// Profile
router.post('/profile/get', getUserProfile);
router.post('/profile/update', updateUserProfile);
router.post('/profile/otp', verifyUserProfileOtp);
router.delete('/profile/delete', deleteUserProfile);

// Notifications
router.post('/notification', getUserNotifications);

// Reviews & Ratings
router.post('/review', submitReview);
router.post('/product/rating', rateProduct);
router.post('/rider/rating', rateRider);

// Cart & Checkout & Orders
router.post('/cart/add', addToCart);
router.post('/cart/get', getCart);
router.delete('/cart/remove', removeFromCart);
router.post('/checkout', checkoutCart);
router.get('/payment', getPaymentLink);

router.get('/order/all', getAllUserOrders);
router.post('/order/all', getAllUserOrders); // for search/filters
router.post('/order/delievered', setOrderDeliveredUser);
router.delete('/order/cancel', cancelUserOrder);
router.delete('/orders/reorder', reorderUserOrder);

// Wishlist
router.post('/wishlist/add', addToWishlist);
router.post('/wishlist/remove', removeFromWishlist);
router.post('/wishlist/get', getWishlist);

// Address
router.post('/address/all', getAllAddresses);
router.post('/address/add', addUserAddress);
router.delete('/address/delete', deleteUserAddress);
router.post('/address/update', updateUserAddress);

// All Users
router.get('/all', getAllUsers);

module.exports = router;
