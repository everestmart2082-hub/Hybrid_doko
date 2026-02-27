import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://localhost:5000/api/admin',
  withCredentials: true,
});

API.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

export const adminLogin         = (credentials)  => API.post('/login', credentials);
export const getVendors         = ()             => API.get('/vendors');
export const approveVendor      = (id)           => API.put(`/vendors/${id}/approve`);
export const suspendVendor      = (id)           => API.put(`/vendors/${id}/suspend`);
export const getRiders          = ()             => API.get('/riders');
export const approveRider       = (id)           => API.put(`/riders/${id}/approve`);
export const suspendRider       = (id)           => API.put(`/riders/${id}/suspend`);
export const getClients         = ()             => API.get('/clients');
export const suspendClient      = (id)           => API.put(`/clients/${id}/suspend`);
export const getOrders          = (params)       => API.get('/orders', { params });
export const getAnalytics       = (range)        => API.get(`/analytics?range=${range}`);
export const getEmployees       = ()             => API.get('/employees');
export const addEmployee        = (data)         => API.post('/employees', data);
export const getPayroll         = ()             => API.get('/payroll');
export const getCategories      = ()             => API.get('/categories');
export const createCategory     = (data)         => API.post('/categories', data);
export const getPendingProducts = ()             => API.get('/products/pending');
export const approveProduct     = (id)           => API.put(`/products/${id}/approve`);
export const generateInvoice    = (orderId)      => API.get(`/invoices/${orderId}`, { responseType: 'blob' });
