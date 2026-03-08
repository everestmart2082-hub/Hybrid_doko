import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('token');

const api = axios.create({
    baseURL: API_BASE,
    headers: { 'Content-Type': 'application/json' }
});

// ─── Unified Auth APIs (phone+OTP for all roles) ────────────────────────

export const authAPI = {
    // Customer
    login: (phone) => api.post('/user/login', { phone }),
    verifyLoginOtp: (phone, otp) => api.post('/user/login/otp', { phone, otp }),
    register: (data) => api.post('/user/registration', { phone: data.phone, name: data.name }),
    verifyRegistrationOtp: (phone, otp) => api.post('/user/registration/otp', { phone, otp }),
    getProfile: () => api.post('/user/profile/get', { token: getToken() }),
    updateProfile: (data) => api.post('/user/profile/update', { token: getToken(), ...data }),

    // Vendor
    vendorLogin: (phone) => api.post('/vender/login', { phone }),
    vendorVerifyLoginOtp: (phone, otp) => api.post('/vender/login/otp', { phone, otp }),
    vendorRegister: (data) => api.post('/vender/registration', data),
    vendorVerifyRegistrationOtp: (phone, otp) => api.post('/vender/registration/otp', { phone, otp }),

    // Rider
    riderLogin: (phone) => api.post('/rider/login', { phone }),
    riderVerifyLoginOtp: (phone, otp) => api.post('/rider/login/otp', { phone, otp }),
    riderRegister: (data) => api.post('/rider/registration', data),
    riderVerifyRegistrationOtp: (phone, otp) => api.post('/rider/registration/otp', { phone, otp }),
};

// Product APIs
export const productAPI = {
    getAll: (params) => api.get('/product/all', { params }),
    getById: (id) => api.get('/product/id', { params: { id } }),
    getRecommended: () => api.get('/product/recommended'),
};

// Cart APIs (token in body per new_server spec)
export const cartAPI = {
    add: (productId, number = 1) => api.post('/user/cart/add', { token: getToken(), product: productId, number }),
    remove: (productId) => api.delete('/user/cart/remove', { data: { token: getToken(), product: productId } }),
    get: () => api.post('/user/cart/get', { token: getToken() }),
};

// Order APIs (token in body)
export const orderAPI = {
    create: (data) => api.post('/user/checkout', { token: getToken(), ...data }),
    getAll: (filter) => api.post('/user/order/all', { token: getToken(), filter }),
    cancel: (orderId) => api.delete('/user/order/cancel', { data: { token: getToken(), 'order id': orderId } }),
    reorder: (orderId) => api.delete('/orders/reorder', { data: { token: getToken(), 'order id': orderId } }),
    setDelivered: (orderId, otp) => api.post('/user/order/delievered', { token: getToken(), 'order id': orderId, otp }),
};

// Review APIs
export const reviewAPI = {
    create: (data) => api.post('/user/review', { token: getToken(), ...data }),
    rateProduct: (productId, rating) => api.post('/user/product/rating', { token: getToken(), 'product id': productId, ratting: rating }),
    rateRider: (riderId, rating) => api.post('/user/rider/rating', { token: getToken(), 'rider id': riderId, ratting: rating }),
};

// Wishlist APIs (now connected to real backend)
export const wishlistAPI = {
    get: () => api.post('/user/wishlist/get', { token: getToken() }),
    add: (productId) => api.post('/user/wishlist/add', { token: getToken(), productId }),
    remove: (wishlistId) => api.post('/user/wishlist/remove', { token: getToken(), wishlistId }),
};

// Address APIs (token in body)
export const addressAPI = {
    getAll: () => api.post('/user/address/all', { token: getToken() }),
    add: (data) => api.post('/user/address/add', { token: getToken(), ...data }),
    update: (id, data) => api.post('/user/address/update', { token: getToken(), addressId: id, ...data }),
    delete: (id) => api.delete('/user/address/delete', { data: { token: getToken(), addressId: id } }),
    setDefault: (id) => api.post('/user/address/update', { token: getToken(), addressId: id, isDefault: true }),
};

// Notification API
export const notificationAPI = {
    get: () => api.post('/user/notification', { token: getToken() }),
};

export default api;
