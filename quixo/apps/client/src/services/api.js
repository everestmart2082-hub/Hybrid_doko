import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: { 'Content-Type': 'application/json' }
});

// Inject auth token into every request
api.interceptors.request.use((config) => {
    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
}, (error) => Promise.reject(error));

// Global error handler — redirect to login on 401
api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (error.response?.status === 401) {
            localStorage.removeItem('token');
            window.location.href = '/login';
        }
        return Promise.reject(error);
    }
);

// Auth APIs
export const authAPI = {
    register: (data) => api.post('/auth/user/register', data),
    verifyOTP: (data) => api.post('/auth/user/verify-otp', data),
    login: (data) => api.post('/auth/user/login', data),
    verifyLoginOTP: (data) => api.post('/auth/user/login/verify-otp', data),
};

// Product APIs
export const productAPI = {
    getAll: (params) => api.get('/product/all', { params }),
    getById: (id) => api.get(`/product/${id}`),
};

// Cart APIs
export const cartAPI = {
    get: () => api.get('/cart'),
    add: (data) => api.post('/cart/add', data),
    update: (id, data) => api.put(`/cart/${id}`, data),
    remove: (id) => api.delete(`/cart/${id}`),
    clear: () => api.delete('/cart/clear'),
};

// Order APIs
export const orderAPI = {
    create: (data) => api.post('/order', data),
    getAll: (params) => api.get('/order/all', { params }),
    getById: (id) => api.get(`/order/${id}`),
    cancel: (id) => api.post(`/order/${id}/cancel`),
};

// Review APIs
export const reviewAPI = {
    getByProduct: (productId) => api.get(`/review/product/${productId}`),
    create: (data) => api.post('/review', data),
};

// Wishlist APIs
export const wishlistAPI = {
    get: () => api.get('/wishlist'),
    add: (productId) => api.post('/wishlist/add', { productId }),
    remove: (productId) => api.delete(`/wishlist/${productId}`),
};

// Address APIs
export const addressAPI = {
    getAll: () => api.get('/user/addresses'),
    add: (data) => api.post('/user/address', data),
    update: (id, data) => api.put(`/user/address/${id}`, data),
    delete: (id) => api.delete(`/user/address/${id}`),
    setDefault: (id) => api.put(`/user/address/${id}/default`),
};

export default api;
