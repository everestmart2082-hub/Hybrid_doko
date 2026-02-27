import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/vendor/auth',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/* ── Vendor API calls ── */
export const getVendors    = ()       => API.get('/');
export const getVendorById = (id)     => API.get(`/${id}`);
export const createVendor  = (data)   => API.post('/', data);
export const updateVendor  = (id, data) => API.put(`/${id}`, data);
export const deleteVendor  = (id)     => API.delete(`/${id}`);
