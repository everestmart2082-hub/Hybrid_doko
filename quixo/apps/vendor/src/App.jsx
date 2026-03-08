import React, { useEffect } from 'react';
import { Routes, Route } from 'react-router-dom';
import VendorLogin from './pages/Auth/VendorLogin';
import VendorRegister from './pages/Auth/VendorRegister';
import Dashboard from './pages/Dashboard/index';
import StoreSetupPage from './pages/StoreSetup/StoreSetupPage';
import ProductList from './pages/Products/ProductList';
import AddProduct from './pages/Products/AddProduct';
import EditProduct from './pages/Products/EditProduct';
import OrderList from './pages/Orders/OrderList';
import OrderDetail from './pages/Orders/OrderDetail';
import InventoryPage from './pages/Inventory/InventoryPage';
import InvoicePage from './pages/Invoices/InvoicePage';
import AnalyticsPage from './pages/Analytics/AnalyticsPage';
import VendorProfile from './pages/Profile/VendorProfile';
import B2BMarketplace from './pages/B2B/B2BMarketplace';
import B2BOrderForm from './pages/B2B/B2BOrderForm';
import B2BMyOrders from './pages/B2B/B2BMyOrders';

const App = () => {
  // Receive token from unified login redirect (http://localhost:3001/?token=xxx)
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');
    if (token) {
      localStorage.setItem('vendor_token', token);
      window.history.replaceState({}, '', '/');
    }
  }, []);

  return (
    <Routes>
      <Route path="/login" element={<VendorLogin />} />
      <Route path="/register" element={<VendorRegister />} />
      <Route path="/" element={<Dashboard />} />
      <Route path="/store-setup" element={<StoreSetupPage />} />
      <Route path="/products" element={<ProductList />} />
      <Route path="/products/add" element={<AddProduct />} />
      <Route path="/products/:id" element={<EditProduct />} />
      <Route path="/orders" element={<OrderList />} />
      <Route path="/orders/:id" element={<OrderDetail />} />
      <Route path="/inventory" element={<InventoryPage />} />
      <Route path="/invoices" element={<InvoicePage />} />
      <Route path="/analytics" element={<AnalyticsPage />} />
      <Route path="/profile" element={<VendorProfile />} />
      <Route path="/b2b/marketplace" element={<B2BMarketplace />} />
      <Route path="/b2b/order" element={<B2BOrderForm />} />
      <Route path="/b2b/my-orders" element={<B2BMyOrders />} />
    </Routes>
  );
};
export default App;