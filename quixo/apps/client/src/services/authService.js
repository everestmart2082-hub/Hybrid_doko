import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/auth',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

/* ── Auth API calls ── */
export const getAuths    = ()       => API.get('/');
export const getAuthById = (id)     => API.get(`/${id}`);
export const createAuth  = (data)   => API.post('/', data);
export const updateAuth  = (id, data) => API.put(`/${id}`, data);
export const deleteAuth  = (id)     => API.delete(`/${id}`);
