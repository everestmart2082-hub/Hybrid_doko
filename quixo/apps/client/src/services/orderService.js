import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/orders',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/* ── Order API calls ── */
export const getOrders    = ()       => API.get('/');
export const getOrderById = (id)     => API.get(`/${id}`);
export const createOrder  = (data)   => API.post('/', data);
export const updateOrder  = (id, data) => API.put(`/${id}`, data);
export const deleteOrder  = (id)     => API.delete(`/${id}`);
