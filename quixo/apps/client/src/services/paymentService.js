import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/payment',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/* ── Payment API calls ── */
export const getPayments    = ()       => API.get('/');
export const getPaymentById = (id)     => API.get(`/${id}`);
export const createPayment  = (data)   => API.post('/', data);
export const updatePayment  = (id, data) => API.put(`/${id}`, data);
export const deletePayment  = (id)     => API.delete(`/${id}`);
