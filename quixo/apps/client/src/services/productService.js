import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/products',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/* ── Product API calls ── */
export const getProducts    = ()       => API.get('/');
export const getProductById = (id)     => API.get(`/${id}`);
export const createProduct  = (data)   => API.post('/', data);
export const updateProduct  = (id, data) => API.put(`/${id}`, data);
export const deleteProduct  = (id)     => API.delete(`/${id}`);
