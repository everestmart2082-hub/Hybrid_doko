import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: { 'Content-Type': 'application/json' }
});

// Helper: get token from localStorage
const getToken = () => localStorage.getItem('vendor_token');

// Auth APIs — phone+OTP flow
export const vendorAuthAPI = {
    login: (phone) => api.post('/vender/login', { phone }),
    verifyLoginOtp: (phone, otp) => api.post('/vender/login/otp', { phone, otp }),
    register: (data) => api.post('/vender/registration', data),
    verifyRegistrationOtp: (phone, otp) => api.post('/vender/registration/otp', { phone, otp }),
    getProfile: () => api.post('/vender/profile/get', { token: getToken() }),
    updateProfile: (data) => api.post('/vender/profile/update', { token: getToken(), ...data }),
    deleteProfile: (data) => api.delete('/vender/profile/delete', { data: { token: getToken(), ...data } }),
};

// Product APIs
export const vendorProductAPI = {
    add: (productData) => api.post('/vender/product/add', { token: getToken(), ...productData }),
    edit: (productId, productData) => api.post('/vender/product/edit', { token: getToken(), 'product id': productId, ...productData }),
    delete: (productId) => api.delete('/vender/product/delete', { data: { token: getToken(), 'product id': productId } }),
};

// Order APIs
export const vendorOrderAPI = {
    getAll: (filter) => api.post('/vender/order/all', { token: getToken(), filter }),
    setPrepared: (orderId, time) => api.post('/vender/order/prepared', { token: getToken(), 'order id': orderId, time }),
};

// Chart / Analytics
export const vendorChartAPI = {
    get: () => api.get('/vender/chart'),
};

export default api;
