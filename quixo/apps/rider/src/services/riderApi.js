import axios from 'axios';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api';

const api = axios.create({
    baseURL: API_BASE_URL,
    headers: { 'Content-Type': 'application/json' }
});

// Helper: get token from localStorage
const getToken = () => localStorage.getItem('rider_token');

// Auth APIs — phone+OTP flow
export const riderAuthAPI = {
    login: (phone) => api.post('/rider/login', { phone }),
    verifyLoginOtp: (phone, otp) => api.post('/rider/login/otp', { phone, otp }),
    register: (data) => api.post('/rider/registration', data),
    verifyRegistrationOtp: (phone, otp) => api.post('/rider/registration/otp', { phone, otp }),
    getProfile: () => api.post('/rider/profile/get', { token: getToken() }),
    updateProfile: (data) => api.post('/rider/profile/update', { token: getToken(), ...data }),
    deleteProfile: (data) => api.delete('/rider/profile/delete', { data: { token: getToken(), ...data } }),
};

// Dashboard & Notifications
export const riderDashboardAPI = {
    get: () => api.post('/rider/dashboard', { token: getToken() }),
    getNotifications: () => api.post('/rider/notification', { token: getToken() }),
};

export default api;
