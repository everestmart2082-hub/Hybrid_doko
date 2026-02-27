import React from 'react';
import { Routes, Route } from 'react-router-dom';
import VendorLogin     from './pages/Auth/VendorLogin';
import VendorRegister  from './pages/Auth/VendorRegister';
import Dashboard       from './pages/Dashboard/index';
import StoreSetupPage  from './pages/StoreSetup/StoreSetupPage';
import ProductList     from './pages/Products/ProductList';
import AddProduct      from './pages/Products/AddProduct';
import EditProduct     from './pages/Products/EditProduct';
import OrderList       from './pages/Orders/OrderList';
import OrderDetail     from './pages/Orders/OrderDetail';
import InventoryPage   from './pages/Inventory/InventoryPage';
import InvoicePage     from './pages/Invoices/InvoicePage';
import AnalyticsPage   from './pages/Analytics/AnalyticsPage';
import VendorProfile   from './pages/Profile/VendorProfile';

const App = () => (
  <Routes>
    <Route path="/login"        element={<VendorLogin />} />
    <Route path="/register"     element={<VendorRegister />} />
    <Route path="/"             element={<Dashboard />} />
    <Route path="/store-setup"  element={<StoreSetupPage />} />
    <Route path="/products"     element={<ProductList />} />
    <Route path="/products/add" element={<AddProduct />} />
    <Route path="/products/:id" element={<EditProduct />} />
    <Route path="/orders"       element={<OrderList />} />
    <Route path="/orders/:id"   element={<OrderDetail />} />
    <Route path="/inventory"    element={<InventoryPage />} />
    <Route path="/invoices"     element={<InvoicePage />} />
    <Route path="/analytics"    element={<AnalyticsPage />} />
    <Route path="/profile"      element={<VendorProfile />} />
  </Routes>
);
export default App;