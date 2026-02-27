import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Navbar from './components/common/Navbar/Navbar';
import Footer from './components/common/Footer';
import Home from './pages/Home/index';
import Login from './pages/Auth/Login';
import Register from './pages/Auth/Register';
import ProductList from './pages/Products/ProductList';
import ProductDetail from './pages/Products/ProductDetail';
import CartPage from './pages/Cart/CartPage';
import WishlistPage from './pages/Wishlist/WishlistPage';
import CheckoutPage from './pages/Checkout/CheckoutPage';
import OrderHistory from './pages/Orders/OrderHistory';
import OrderTracking from './pages/Orders/OrderTracking';
import ProfilePage from './pages/Profile/ProfilePage';

const App = () => (
  <>
    <Navbar />
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/login" element={<Login />} />
      <Route path="/register" element={<Register />} />
      <Route path="/products" element={<ProductList />} />
      <Route path="/products/:id" element={<ProductDetail />} />
      <Route path="/cart" element={<CartPage />} />
      <Route path="/wishlist" element={<WishlistPage />} />
      <Route path="/checkout" element={<CheckoutPage />} />
      <Route path="/orders" element={<OrderHistory />} />
      <Route path="/orders/:id" element={<OrderTracking />} />
      <Route path="/profile" element={<ProfilePage />} />
    </Routes>
    <Footer />
  </>
);

export default App;