import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/cart',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/* ── Cart API calls ── */
export const getCarts    = ()       => API.get('/');
export const getCartById = (id)     => API.get(`/${id}`);
export const createCart  = (data)   => API.post('/', data);
export const updateCart  = (id, data) => API.put(`/${id}`, data);
export const deleteCart  = (id)     => API.delete(`/${id}`);
