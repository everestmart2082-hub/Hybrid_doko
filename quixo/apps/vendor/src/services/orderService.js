// Re-exported from vendorApi.js for backward compatibility
import { vendorOrderAPI } from './vendorApi';

export const getOrders = (filter) => vendorOrderAPI.getAll(filter);
export const getOrderById = (id) => vendorOrderAPI.getAll().then(res => {
  // new_server vendor order/all returns all orders; filter client-side by id
  const orders = res.data?.message || [];
  const order = orders.find(o => o._id === id);
  return { data: { data: order, success: true } };
});
export const updateOrder = (id, data) => vendorOrderAPI.setPrepared(id, data.time);
export const createOrder = (data) => Promise.resolve({ data: { success: true } });
export const deleteOrder = (id) => Promise.resolve({ data: { success: true } });
