import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';

const AdminRoute = () => {
  const token = localStorage.getItem('adminToken');
  // TODO: also verify role === 'admin' from decoded JWT
  return token ? <Outlet /> : <Navigate to="/login" replace />;
};

export default AdminRoute;