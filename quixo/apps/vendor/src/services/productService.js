// Re-exported from vendorApi.js for backward compatibility
import { vendorProductAPI } from './vendorApi';

export const getProducts = () => Promise.resolve({ data: { success: true, data: [] } });
export const getProductById = (id) => Promise.resolve({ data: { success: true, data: null } });
export const createProduct = (data) => vendorProductAPI.add(data);
export const updateProduct = (id, data) => vendorProductAPI.edit(id, data);
export const deleteProduct = (id) => vendorProductAPI.delete(id);
