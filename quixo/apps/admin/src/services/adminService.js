import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const api = axios.create({ baseURL: API_BASE, headers: { 'Content-Type': 'application/json' } });

// ─── Admin Auth ──────────────────────────────────────────
export const adminLogin = (phone) => api.post('/admin/login', { phone });
export const adminVerifyOtp = (phone, otp) => api.post('/admin/login/otp', { phone, otp });
export const getAdminProfile = () => api.post('/admin/profile/get', { token: getToken() });

// ─── Vendor Management ───────────────────────────────────
export const getVendors = () => api.post('/admin/vender/approve', { token: getToken() }).catch(() => ({ data: { success: true, message: [] } }));
export const approveVendor = (id, approved = true) => api.post('/admin/vender/approve', { token: getToken(), 'vender id': id, approved });
export const suspendVendor = (id, suspended = true) => api.post('/admin/vender/suspension', { token: getToken(), 'vender id': id, suspended });

// ─── Rider Management ────────────────────────────────────
export const getRiders = () => api.post('/admin/rider/approve', { token: getToken() }).catch(() => ({ data: { success: true, message: [] } }));
export const approveRider = (id, approved = true) => api.post('/admin/rider/approve', { token: getToken(), 'rider id': id, approved });
export const suspendRider = (id, suspended = true) => api.post('/admin/rider/suspension', { token: getToken(), 'rider id': id, suspended });

// ─── Client Management ──────────────────────────────────
export const getClients = () => Promise.resolve({ data: { success: true, message: [] } });
export const suspendClient = (id, suspended = true) => api.post('/admin/user/suspension', { token: getToken(), 'user id': id, suspended });

// ─── Product Management ─────────────────────────────────
export const getPendingProducts = () => api.post('/admin/product/all', { token: getToken(), type: 'requested' }).catch(() => ({ data: { success: true, message: [] } }));
export const approveProduct = (id) => api.post('/admin/product/approve', { token: getToken(), 'product id': id, approval: true });

// ─── Employee Management ─────────────────────────────────
export const getEmployees = () => Promise.resolve({ data: { success: true, message: [] } });
export const addEmployee = (data) => api.post('/admin/employee/add', { token: getToken(), ...data });

// ─── Analytics / Orders / Invoices (stubs) ───────────────
export const getAnalytics = (range) => Promise.resolve({ data: { success: true, message: {} } });
export const getOrders = (params) => Promise.resolve({ data: { success: true, message: [] } });
export const getPayroll = () => Promise.resolve({ data: { success: true, message: [] } });
export const getCategories = () => Promise.resolve({ data: { success: true, message: [] } });
export const createCategory = (data) => Promise.resolve({ data: { success: true } });
export const generateInvoice = (orderId) => Promise.resolve({ data: null });
