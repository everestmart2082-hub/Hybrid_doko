const fs = require("fs");
const path = require("path");

const ROOT = path.join(process.cwd(), "quixo");

/* ─────────────── HELPERS ─────────────── */
const dir  = (p) => fs.mkdirSync(path.join(ROOT, p), { recursive: true });
const file = (p, content = "") => {
  const full = path.join(ROOT, p);
  fs.mkdirSync(path.dirname(full), { recursive: true });
  fs.writeFileSync(full, content, "utf8");
};

/* ─────────────── TEMPLATES ─────────────── */
const component = (name, extra = "") => `import React from 'react';
${extra}
const ${name} = () => {
  return (
    <div className="${name.toLowerCase()}-container">
      <h2>${name}</h2>
    </div>
  );
};

export default ${name};
`;

const page = (name) => `import React from 'react';

const ${name} = () => {
  return (
    <div className="page-wrapper">
      <h1>${name}</h1>
    </div>
  );
};

export default ${name};
`;

const reduxSlice = (name) => `import { createSlice } from '@reduxjs/toolkit';

const initialState = {
  data: [],
  loading: false,
  error: null,
};

const ${name}Slice = createSlice({
  name: '${name}',
  initialState,
  reducers: {
    setLoading: (state, action) => { state.loading = action.payload; },
    setError:   (state, action) => { state.error   = action.payload; },
    setData:    (state, action) => { state.data    = action.payload; },
    reset:      () => initialState,
  },
});

export const { setLoading, setError, setData, reset } = ${name}Slice.actions;
export default ${name}Slice.reducer;
`;

const axiosService = (name, baseURL) => `import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_API_URL + '/${baseURL}',
  withCredentials: true,
});

// Attach JWT token to every request
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers.Authorization = \`Bearer \${token}\`;
  return config;
});

/* ── ${name} API calls ── */
export const get${name}s    = ()       => API.get('/');
export const get${name}ById = (id)     => API.get(\`/\${id}\`);
export const create${name}  = (data)   => API.post('/', data);
export const update${name}  = (id, data) => API.put(\`/\${id}\`, data);
export const delete${name}  = (id)     => API.delete(\`/\${id}\`);
`;

const expressRoute = (name) => `const express  = require('express');
const router   = express.Router();
const ctrl     = require('./${name}.controller');
const { authGuard } = require('../../shared/middleware/authGuard');

router.get('/',        authGuard, ctrl.getAll);
router.get('/:id',     authGuard, ctrl.getById);
router.post('/',       authGuard, ctrl.create);
router.put('/:id',     authGuard, ctrl.update);
router.delete('/:id',  authGuard, ctrl.remove);

module.exports = router;
`;

const expressController = (name) => `const ${name}Service = require('./${name}.service');

exports.getAll  = async (req, res) => {
  try {
    const data = await ${name}Service.findAll(req.query);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getById = async (req, res) => {
  try {
    const data = await ${name}Service.findById(req.params.id);
    if (!data) return res.status(404).json({ success: false, message: 'Not found' });
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.create  = async (req, res) => {
  try {
    const data = await ${name}Service.create(req.body);
    res.status(201).json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};

exports.update  = async (req, res) => {
  try {
    const data = await ${name}Service.update(req.params.id, req.body);
    res.json({ success: true, data });
  } catch (err) { res.status(400).json({ success: false, message: err.message }); }
};

exports.remove  = async (req, res) => {
  try {
    await ${name}Service.remove(req.params.id);
    res.json({ success: true, message: 'Deleted successfully' });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
`;

const expressService = (name, modelName) => `const ${modelName} = require('./${name}.model');

exports.findAll  = (query = {})        => ${modelName}.find(query);
exports.findById = (id)                => ${modelName}.findById(id);
exports.create   = (data)              => ${modelName}.create(data);
exports.update   = (id, data)          => ${modelName}.findByIdAndUpdate(id, data, { new: true });
exports.remove   = (id)                => ${modelName}.findByIdAndDelete(id);
`;

const viteConfig = (port) => `import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    port: ${port},
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
      },
    },
  },
});
`;

const packageJson = (name, port) => JSON.stringify({
  name,
  version: "1.0.0",
  private: true,
  scripts: {
    dev: `vite --port ${port}`,
    build: "vite build",
    preview: "vite preview"
  },
  dependencies: {
    react: "^18.2.0",
    "react-dom": "^18.2.0",
    "react-router-dom": "^6.22.0",
    "@reduxjs/toolkit": "^2.2.0",
    "react-redux": "^9.1.0",
    axios: "^1.6.0",
    "socket.io-client": "^4.7.0",
  },
  devDependencies: {
    "@vitejs/plugin-react": "^4.2.0",
    vite: "^5.1.0"
  }
}, null, 2);

const serverPackageJson = () => JSON.stringify({
  name: "quixo-server",
  version: "1.0.0",
  main: "server.js",
  scripts: {
    start: "node server.js",
    dev: "nodemon server.js"
  },
  dependencies: {
    express: "^4.18.2",
    mongoose: "^8.1.0",
    cors: "^2.8.5",
    dotenv: "^16.4.1",
    bcryptjs: "^2.4.3",
    jsonwebtoken: "^9.0.2",
    "socket.io": "^4.7.0",
    ioredis: "^5.3.2",
    multer: "^1.4.5",
    cloudinary: "^2.0.0",
    "express-rate-limit": "^7.1.5",
    "express-validator": "^7.0.1",
    pdfkit: "^0.14.0",
    nodemailer: "^6.9.8",
    axios: "^1.6.0"
  },
  devDependencies: {
    nodemon: "^3.0.3"
  }
}, null, 2);

/* ─────────────────────────────────────────────────────────────
   1. CLIENT APP  (port 3000)
───────────────────────────────────────────────────────────── */
console.log("📦 Creating apps/client ...");
file("apps/client/package.json",  packageJson("quixo-client", 3000));
file("apps/client/vite.config.js", viteConfig(3000));
file("apps/client/.env", "VITE_API_URL=http://localhost:5000/api\n");
file("apps/client/index.html", `<!DOCTYPE html>
<html lang="en">
  <head><meta charset="UTF-8"/><title>Quixo</title></head>
  <body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body>
</html>`);
file("apps/client/src/main.jsx", `import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './store/index';
import App from './App';

ReactDOM.createRoot(document.getElementById('root')).render(
  <Provider store={store}>
    <BrowserRouter>
      <App />
    </BrowserRouter>
  </Provider>
);`);

file("apps/client/src/App.jsx", `import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Navbar from './components/common/Navbar/Navbar';
import Home       from './pages/Home/index';
import Login      from './pages/Auth/Login';
import Register   from './pages/Auth/Register';
import ProductList from './pages/Products/ProductList';
import ProductDetail from './pages/Products/ProductDetail';
import CartPage   from './pages/Cart/CartPage';
import WishlistPage from './pages/Wishlist/WishlistPage';
import CheckoutPage from './pages/Checkout/CheckoutPage';
import OrderHistory from './pages/Orders/OrderHistory';
import OrderTracking from './pages/Orders/OrderTracking';
import ProfilePage from './pages/Profile/ProfilePage';

const App = () => (
  <>
    <Navbar />
    <Routes>
      <Route path="/"              element={<Home />} />
      <Route path="/login"         element={<Login />} />
      <Route path="/register"      element={<Register />} />
      <Route path="/products"      element={<ProductList />} />
      <Route path="/products/:id"  element={<ProductDetail />} />
      <Route path="/cart"          element={<CartPage />} />
      <Route path="/wishlist"      element={<WishlistPage />} />
      <Route path="/checkout"      element={<CheckoutPage />} />
      <Route path="/orders"        element={<OrderHistory />} />
      <Route path="/orders/:id"    element={<OrderTracking />} />
      <Route path="/profile"       element={<ProfilePage />} />
    </Routes>
  </>
);

export default App;`);

// store
file("apps/client/src/store/index.js", `import { configureStore } from '@reduxjs/toolkit';
import cartReducer    from './cartSlice';
import authReducer    from './authSlice';
import productReducer from './productSlice';
import orderReducer   from './orderSlice';

export default configureStore({
  reducer: { cart: cartReducer, auth: authReducer, product: productReducer, order: orderReducer },
});`);
file("apps/client/src/store/cartSlice.js",    reduxSlice("cart"));
file("apps/client/src/store/authSlice.js",    reduxSlice("auth"));
file("apps/client/src/store/productSlice.js", reduxSlice("product"));
file("apps/client/src/store/orderSlice.js",   reduxSlice("order"));

// services
file("apps/client/src/services/authService.js",    axiosService("Auth",    "auth"));
file("apps/client/src/services/productService.js", axiosService("Product", "products"));
file("apps/client/src/services/orderService.js",   axiosService("Order",   "orders"));
file("apps/client/src/services/cartService.js",    axiosService("Cart",    "cart"));
file("apps/client/src/services/paymentService.js", axiosService("Payment", "payment"));

// hooks
file("apps/client/src/hooks/useAuth.js", `import { useSelector, useDispatch } from 'react-redux';
import { setData, reset } from '../store/authSlice';

export const useAuth = () => {
  const dispatch = useDispatch();
  const auth = useSelector((s) => s.auth);
  const logout = () => { localStorage.removeItem('token'); dispatch(reset()); };
  return { ...auth, logout };
};`);
file("apps/client/src/hooks/useCart.js",    `import { useSelector } from 'react-redux';
export const useCart = () => useSelector((s) => s.cart);`);
file("apps/client/src/hooks/useSocket.js", `import { useEffect, useRef } from 'react';
import { io } from 'socket.io-client';

export const useSocket = (event, handler) => {
  const socket = useRef(null);
  useEffect(() => {
    socket.current = io(import.meta.env.VITE_API_URL?.replace('/api','') || 'http://localhost:5000');
    socket.current.on(event, handler);
    return () => socket.current.disconnect();
  }, [event]);
  return socket;
};`);
file("apps/client/src/hooks/useProduct.js", `import { useSelector } from 'react-redux';
export const useProduct = () => useSelector((s) => s.product);`);

// utils
file("apps/client/src/utils/formatCurrency.js", `export const formatNPR = (amount) =>
  new Intl.NumberFormat('ne-NP', { style: 'currency', currency: 'NPR' }).format(amount);`);
file("apps/client/src/utils/calculateVAT.js", `export const addVAT = (price, rate = 0.13) => +(price * (1 + rate)).toFixed(2);
export const getVAT = (price, rate = 0.13) => +(price * rate).toFixed(2);`);
file("apps/client/src/utils/constants.js", `export const ORDER_STATUS = { PENDING: 'pending', PREPARING: 'preparing', PICKED: 'picked', DELIVERED: 'delivered' };
export const DELIVERY_TYPE = { QUICK: 'quick', ECOMMERCE: 'ecommerce' };
export const VAT_RATE = 0.13;`);

// components
file("apps/client/src/components/common/Navbar/Navbar.jsx", component("Navbar", `import { Link } from 'react-router-dom';`));
file("apps/client/src/components/common/Navbar/Navbar.module.css", `.navbar { display: flex; justify-content: space-between; padding: 1rem; }`);
file("apps/client/src/components/common/ProductCard/ProductCard.jsx", component("ProductCard", `import { useDispatch } from 'react-redux';`));
file("apps/client/src/components/common/ProductCard/ProductCard.module.css", `.productcard-container { border: 1px solid #eee; border-radius: 8px; padding: 1rem; }`);
file("apps/client/src/components/common/DiscountBadge/DiscountBadge.jsx", component("DiscountBadge"));
file("apps/client/src/components/common/QuantityButton/QuantityButton.jsx", component("QuantityButton"));
file("apps/client/src/components/common/HeartIcon/HeartIcon.jsx", component("HeartIcon"));
file("apps/client/src/components/common/StarRating/StarRating.jsx", component("StarRating"));
file("apps/client/src/components/common/OTPModal/OTPModal.jsx", component("OTPModal"));
file("apps/client/src/components/layout/Header.jsx", component("Header"));
file("apps/client/src/components/layout/Footer.jsx", component("Footer"));
file("apps/client/src/components/checkout/AddressForm.jsx", component("AddressForm"));
file("apps/client/src/components/checkout/PaymentOptions.jsx", component("PaymentOptions"));
file("apps/client/src/components/checkout/OrderSummary.jsx", component("OrderSummary"));

// pages
for (const [p, name] of [
  ["pages/Home/index.jsx", "Home"],
  ["pages/Home/HeroBanner.jsx", "HeroBanner"],
  ["pages/Home/CategoryExplore.jsx", "CategoryExplore"],
  ["pages/Home/FeaturedProducts.jsx", "FeaturedProducts"],
  ["pages/Home/RecentSearch.jsx", "RecentSearch"],
  ["pages/Home/Recommendations.jsx", "Recommendations"],
  ["pages/Auth/Login.jsx", "Login"],
  ["pages/Auth/Register.jsx", "Register"],
  ["pages/Products/ProductList.jsx", "ProductList"],
  ["pages/Products/ProductFilter.jsx", "ProductFilter"],
  ["pages/Products/ProductDetail.jsx", "ProductDetail"],
  ["pages/Cart/CartPage.jsx", "CartPage"],
  ["pages/Wishlist/WishlistPage.jsx", "WishlistPage"],
  ["pages/Checkout/CheckoutPage.jsx", "CheckoutPage"],
  ["pages/Orders/OrderHistory.jsx", "OrderHistory"],
  ["pages/Orders/OrderTracking.jsx", "OrderTracking"],
  ["pages/Profile/ProfilePage.jsx", "ProfilePage"],
]) file(`apps/client/src/${p}`, page(name));

/* ─────────────────────────────────────────────────────────────
   2. VENDOR APP  (port 3001)
───────────────────────────────────────────────────────────── */
console.log("📦 Creating apps/vendor ...");
file("apps/vendor/package.json",  packageJson("quixo-vendor", 3001));
file("apps/vendor/vite.config.js", viteConfig(3001));
file("apps/vendor/.env", "VITE_API_URL=http://localhost:5000/api\n");
file("apps/vendor/index.html", `<!DOCTYPE html><html><head><title>Quixo Vendor</title></head><body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body></html>`);

file("apps/vendor/src/main.jsx", `import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './store/index';
import App from './App';
ReactDOM.createRoot(document.getElementById('root')).render(<Provider store={store}><BrowserRouter><App /></BrowserRouter></Provider>);`);

file("apps/vendor/src/App.jsx", `import React from 'react';
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
export default App;`);

file("apps/vendor/src/store/index.js", `import { configureStore } from '@reduxjs/toolkit';
import vendorReducer  from './vendorSlice';
import productReducer from './productSlice';
import orderReducer   from './orderSlice';
export default configureStore({ reducer: { vendor: vendorReducer, product: productReducer, order: orderReducer } });`);
file("apps/vendor/src/store/vendorSlice.js",  reduxSlice("vendor"));
file("apps/vendor/src/store/productSlice.js", reduxSlice("product"));
file("apps/vendor/src/store/orderSlice.js",   reduxSlice("order"));

file("apps/vendor/src/services/vendorAuthService.js", axiosService("Vendor", "vendor/auth"));
file("apps/vendor/src/services/productService.js",    axiosService("Product","products"));
file("apps/vendor/src/services/orderService.js",      axiosService("Order",  "orders"));

file("apps/vendor/src/components/common/Sidebar.jsx",  component("Sidebar"));
file("apps/vendor/src/components/common/TopBar.jsx",   component("TopBar"));
file("apps/vendor/src/components/common/StatsCard.jsx",component("StatsCard"));
file("apps/vendor/src/components/products/ProductForm.jsx",  component("ProductForm"));
file("apps/vendor/src/components/products/ProductTable.jsx", component("ProductTable"));
file("apps/vendor/src/components/products/ProductFilter.jsx",component("ProductFilter"));
file("apps/vendor/src/components/charts/RevenueChart.jsx",   component("RevenueChart"));
file("apps/vendor/src/components/charts/OrderRunChart.jsx",  component("OrderRunChart"));

for (const [p, name] of [
  ["pages/Auth/VendorLogin.jsx", "VendorLogin"],
  ["pages/Auth/VendorRegister.jsx", "VendorRegister"],
  ["pages/Dashboard/index.jsx", "VendorDashboard"],
  ["pages/StoreSetup/StoreSetupPage.jsx", "StoreSetupPage"],
  ["pages/Products/ProductList.jsx", "ProductList"],
  ["pages/Products/AddProduct.jsx", "AddProduct"],
  ["pages/Products/EditProduct.jsx", "EditProduct"],
  ["pages/Orders/OrderList.jsx", "OrderList"],
  ["pages/Orders/OrderDetail.jsx", "OrderDetail"],
  ["pages/Inventory/InventoryPage.jsx", "InventoryPage"],
  ["pages/Invoices/InvoicePage.jsx", "InvoicePage"],
  ["pages/Analytics/AnalyticsPage.jsx", "AnalyticsPage"],
  ["pages/Profile/VendorProfile.jsx", "VendorProfile"],
]) file(`apps/vendor/src/${p}`, page(name));

/* ─────────────────────────────────────────────────────────────
   3. RIDER APP  (port 3002)
───────────────────────────────────────────────────────────── */
console.log("📦 Creating apps/rider ...");
file("apps/rider/package.json",   packageJson("quixo-rider", 3002));
file("apps/rider/vite.config.js", viteConfig(3002));
file("apps/rider/.env", "VITE_API_URL=http://localhost:5000/api\n");
file("apps/rider/index.html", `<!DOCTYPE html><html><head><title>Quixo Rider</title></head><body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body></html>`);

file("apps/rider/src/main.jsx", `import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './store/index';
import App from './App';
ReactDOM.createRoot(document.getElementById('root')).render(<Provider store={store}><BrowserRouter><App /></BrowserRouter></Provider>);`);

file("apps/rider/src/App.jsx", `import React from 'react';
import { Routes, Route } from 'react-router-dom';
import RiderLogin       from './pages/Auth/RiderLogin';
import RiderRegister    from './pages/Auth/RiderRegister';
import Dashboard        from './pages/Dashboard/index';
import AvailableOrders  from './pages/Orders/AvailableOrders';
import InProgress       from './pages/Orders/InProgress';
import OrderDetail      from './pages/Orders/OrderDetail';
import EarningsPage     from './pages/Earnings/EarningsPage';
import MapPage          from './pages/Map/MapPage';
import RiderProfile     from './pages/Profile/RiderProfile';

const App = () => (
  <Routes>
    <Route path="/login"    element={<RiderLogin />} />
    <Route path="/register" element={<RiderRegister />} />
    <Route path="/"         element={<Dashboard />} />
    <Route path="/orders/available" element={<AvailableOrders />} />
    <Route path="/orders/progress"  element={<InProgress />} />
    <Route path="/orders/:id"       element={<OrderDetail />} />
    <Route path="/earnings"         element={<EarningsPage />} />
    <Route path="/map"              element={<MapPage />} />
    <Route path="/profile"          element={<RiderProfile />} />
  </Routes>
);
export default App;`);

file("apps/rider/src/store/index.js", `import { configureStore } from '@reduxjs/toolkit';
import riderReducer from './riderSlice';
import orderReducer from './orderSlice';
export default configureStore({ reducer: { rider: riderReducer, order: orderReducer } });`);
file("apps/rider/src/store/riderSlice.js", reduxSlice("rider"));
file("apps/rider/src/store/orderSlice.js", reduxSlice("order"));

file("apps/rider/src/hooks/useSocket.js", `import { useEffect, useRef } from 'react';
import { io } from 'socket.io-client';
export const useSocket = (event, handler) => {
  const socket = useRef(null);
  useEffect(() => {
    socket.current = io(import.meta.env.VITE_API_URL?.replace('/api','') || 'http://localhost:5000');
    socket.current.on(event, handler);
    return () => socket.current.disconnect();
  }, [event]);
  return socket;
};`);
file("apps/rider/src/hooks/useLocation.js", `import { useState, useEffect } from 'react';
export const useLocation = () => {
  const [coords, setCoords] = useState(null);
  useEffect(() => {
    const id = navigator.geolocation.watchPosition(
      (pos) => setCoords({ lat: pos.coords.latitude, lng: pos.coords.longitude }),
      (err) => console.error(err)
    );
    return () => navigator.geolocation.clearWatch(id);
  }, []);
  return coords;
};`);

file("apps/rider/src/components/common/BottomNav.jsx", component("BottomNav"));
file("apps/rider/src/components/common/StatsCard.jsx", component("StatsCard"));
file("apps/rider/src/components/common/QRScanner.jsx", component("QRScanner"));
file("apps/rider/src/components/orders/AvailableOrders.jsx", component("AvailableOrders"));
file("apps/rider/src/components/orders/OrderCard.jsx", component("OrderCard"));
file("apps/rider/src/components/orders/DeliveryMap.jsx", component("DeliveryMap"));
file("apps/rider/src/components/earnings/EarningsCard.jsx", component("EarningsCard"));

for (const [p, name] of [
  ["pages/Auth/RiderLogin.jsx", "RiderLogin"],
  ["pages/Auth/RiderRegister.jsx", "RiderRegister"],
  ["pages/Dashboard/index.jsx", "RiderDashboard"],
  ["pages/Orders/AvailableOrders.jsx", "AvailableOrders"],
  ["pages/Orders/InProgress.jsx", "InProgress"],
  ["pages/Orders/OrderDetail.jsx", "OrderDetail"],
  ["pages/Earnings/EarningsPage.jsx", "EarningsPage"],
  ["pages/Map/MapPage.jsx", "MapPage"],
  ["pages/Profile/RiderProfile.jsx", "RiderProfile"],
]) file(`apps/rider/src/${p}`, page(name));

/* ─────────────────────────────────────────────────────────────
   4. ADMIN APP  (port 3003) — 100% SEPARATE
───────────────────────────────────────────────────────────── */
console.log("📦 Creating apps/admin ...");
file("apps/admin/package.json",   packageJson("quixo-admin", 3003));
file("apps/admin/vite.config.js", viteConfig(3003));
file("apps/admin/.env", "VITE_ADMIN_API_URL=http://localhost:5000/api/admin\n");
file("apps/admin/index.html", `<!DOCTYPE html><html><head><title>Quixo Admin</title></head><body><div id="root"></div><script type="module" src="/src/main.jsx"></script></body></html>`);

file("apps/admin/src/main.jsx", `import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter } from 'react-router-dom';
import { Provider } from 'react-redux';
import store from './store/index';
import App from './App';
ReactDOM.createRoot(document.getElementById('root')).render(<Provider store={store}><BrowserRouter><App /></BrowserRouter></Provider>);`);

file("apps/admin/src/App.jsx", `import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import AdminLogin        from './pages/Auth/AdminLogin';
import AdminRoute        from './guards/AdminRoute';
import Dashboard         from './pages/Dashboard/index';
import VendorApproval    from './pages/Approvals/VendorApproval';
import RiderApproval     from './pages/Approvals/RiderApproval';
import VendorList        from './pages/VendorManagement/VendorList';
import VendorDetail      from './pages/VendorManagement/VendorDetail';
import RiderList         from './pages/RiderManagement/RiderList';
import RiderDetail       from './pages/RiderManagement/RiderDetail';
import ClientList        from './pages/ClientManagement/ClientList';
import ClientDetail      from './pages/ClientManagement/ClientDetail';
import SuspendCustomer   from './pages/ClientManagement/SuspendCustomer';
import ProductApproval   from './pages/ProductManagement/ProductApproval';
import ProductList       from './pages/ProductManagement/ProductList';
import OrderList         from './pages/OrderManagement/OrderList';
import EmployeeList      from './pages/Employee/EmployeeList';
import AddEmployee       from './pages/Employee/AddEmployee';
import Payroll           from './pages/Employee/Payroll';
import AnalyticsPage     from './pages/Analytics/AnalyticsPage';
import InvoicePage       from './pages/Invoices/InvoicePage';
import CategoryList      from './pages/Categories/CategoryList';
import CreateCategory    from './pages/Categories/CreateCategory';

const App = () => (
  <Routes>
    <Route path="/login" element={<AdminLogin />} />
    <Route element={<AdminRoute />}>
      <Route path="/"                      element={<Dashboard />} />
      <Route path="/approvals/vendors"     element={<VendorApproval />} />
      <Route path="/approvals/riders"      element={<RiderApproval />} />
      <Route path="/vendors"               element={<VendorList />} />
      <Route path="/vendors/:id"           element={<VendorDetail />} />
      <Route path="/riders"                element={<RiderList />} />
      <Route path="/riders/:id"            element={<RiderDetail />} />
      <Route path="/clients"               element={<ClientList />} />
      <Route path="/clients/:id"           element={<ClientDetail />} />
      <Route path="/clients/:id/suspend"   element={<SuspendCustomer />} />
      <Route path="/products/approval"     element={<ProductApproval />} />
      <Route path="/products"              element={<ProductList />} />
      <Route path="/orders"                element={<OrderList />} />
      <Route path="/employees"             element={<EmployeeList />} />
      <Route path="/employees/add"         element={<AddEmployee />} />
      <Route path="/employees/payroll"     element={<Payroll />} />
      <Route path="/analytics"             element={<AnalyticsPage />} />
      <Route path="/invoices"              element={<InvoicePage />} />
      <Route path="/categories"            element={<CategoryList />} />
      <Route path="/categories/create"     element={<CreateCategory />} />
    </Route>
    <Route path="*" element={<Navigate to="/login" />} />
  </Routes>
);
export default App;`);

file("apps/admin/src/guards/AdminRoute.jsx", `import React from 'react';
import { Navigate, Outlet } from 'react-router-dom';

const AdminRoute = () => {
  const token = localStorage.getItem('adminToken');
  // TODO: also verify role === 'admin' from decoded JWT
  return token ? <Outlet /> : <Navigate to="/login" replace />;
};

export default AdminRoute;`);

file("apps/admin/src/store/index.js", `import { configureStore } from '@reduxjs/toolkit';
import adminReducer    from './adminSlice';
import vendorReducer   from './vendorSlice';
import riderReducer    from './riderSlice';
import clientReducer   from './clientSlice';
import employeeReducer from './employeeSlice';
export default configureStore({
  reducer: { admin: adminReducer, vendor: vendorReducer, rider: riderReducer, client: clientReducer, employee: employeeReducer }
});`);
for (const s of ["admin","vendor","rider","client","employee"])
  file(`apps/admin/src/store/${s}Slice.js`, reduxSlice(s));

file("apps/admin/src/services/adminService.js", `import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://localhost:5000/api/admin',
  withCredentials: true,
});

API.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) config.headers.Authorization = \`Bearer \${token}\`;
  return config;
});

export const adminLogin         = (credentials)  => API.post('/login', credentials);
export const getVendors         = ()             => API.get('/vendors');
export const approveVendor      = (id)           => API.put(\`/vendors/\${id}/approve\`);
export const suspendVendor      = (id)           => API.put(\`/vendors/\${id}/suspend\`);
export const getRiders          = ()             => API.get('/riders');
export const approveRider       = (id)           => API.put(\`/riders/\${id}/approve\`);
export const suspendRider       = (id)           => API.put(\`/riders/\${id}/suspend\`);
export const getClients         = ()             => API.get('/clients');
export const suspendClient      = (id)           => API.put(\`/clients/\${id}/suspend\`);
export const getOrders          = (params)       => API.get('/orders', { params });
export const getAnalytics       = (range)        => API.get(\`/analytics?range=\${range}\`);
export const getEmployees       = ()             => API.get('/employees');
export const addEmployee        = (data)         => API.post('/employees', data);
export const getPayroll         = ()             => API.get('/payroll');
export const getCategories      = ()             => API.get('/categories');
export const createCategory     = (data)         => API.post('/categories', data);
export const getPendingProducts = ()             => API.get('/products/pending');
export const approveProduct     = (id)           => API.put(\`/products/\${id}/approve\`);
export const generateInvoice    = (orderId)      => API.get(\`/invoices/\${orderId}\`, { responseType: 'blob' });
`);

file("apps/admin/src/components/common/Sidebar.jsx",  component("Sidebar"));
file("apps/admin/src/components/common/TopBar.jsx",   component("TopBar"));
file("apps/admin/src/components/common/StatsCard.jsx",component("StatsCard"));
file("apps/admin/src/components/common/DataTable.jsx",component("DataTable"));
file("apps/admin/src/components/approval/PaperVerify.jsx",  component("PaperVerify"));
file("apps/admin/src/components/approval/ApproveButton.jsx", component("ApproveButton"));
file("apps/admin/src/components/approval/SuspendModal.jsx",  component("SuspendModal"));
file("apps/admin/src/components/charts/RevenueChart.jsx",    component("RevenueChart"));
file("apps/admin/src/components/charts/OrderRunChart.jsx",   component("OrderRunChart"));
file("apps/admin/src/components/charts/CategoryChart.jsx",   component("CategoryChart"));
file("apps/admin/src/components/employee/PayrollCard.jsx",   component("PayrollCard"));

for (const [p, name] of [
  ["pages/Auth/AdminLogin.jsx","AdminLogin"],
  ["pages/Dashboard/index.jsx","AdminDashboard"],
  ["pages/Approvals/VendorApproval.jsx","VendorApproval"],
  ["pages/Approvals/RiderApproval.jsx","RiderApproval"],
  ["pages/VendorManagement/VendorList.jsx","VendorList"],
  ["pages/VendorManagement/VendorDetail.jsx","VendorDetail"],
  ["pages/RiderManagement/RiderList.jsx","RiderList"],
  ["pages/RiderManagement/RiderDetail.jsx","RiderDetail"],
  ["pages/ClientManagement/ClientList.jsx","ClientList"],
  ["pages/ClientManagement/ClientDetail.jsx","ClientDetail"],
  ["pages/ClientManagement/SuspendCustomer.jsx","SuspendCustomer"],
  ["pages/ProductManagement/ProductApproval.jsx","ProductApproval"],
  ["pages/ProductManagement/ProductList.jsx","ProductList"],
  ["pages/OrderManagement/OrderList.jsx","OrderList"],
  ["pages/Employee/EmployeeList.jsx","EmployeeList"],
  ["pages/Employee/AddEmployee.jsx","AddEmployee"],
  ["pages/Employee/Payroll.jsx","Payroll"],
  ["pages/Analytics/AnalyticsPage.jsx","AnalyticsPage"],
  ["pages/Invoices/InvoicePage.jsx","InvoicePage"],
  ["pages/Categories/CategoryList.jsx","CategoryList"],
  ["pages/Categories/CreateCategory.jsx","CreateCategory"],
]) file(`apps/admin/src/${p}`, page(name));

/* ─────────────────────────────────────────────────────────────
   5. SERVER (Modular Monolith)
───────────────────────────────────────────────────────────── */
console.log("📦 Creating server ...");
file("server/package.json", serverPackageJson());
file("server/.env", `PORT=5000
MONGO_URI=mongodb://localhost:27017/quixo
JWT_SECRET=your_jwt_secret_here
JWT_ADMIN_SECRET=your_admin_jwt_secret_here
REDIS_URL=redis://localhost:6379
CLOUDINARY_CLOUD_NAME=your_cloud_name
CLOUDINARY_API_KEY=your_api_key
CLOUDINARY_API_SECRET=your_api_secret
ESEWA_MERCHANT_ID=your_esewa_merchant_id
SPARROW_SMS_TOKEN=your_sparrow_token
GOOGLE_MAPS_API_KEY=your_maps_key
`);

file("server/server.js", `require('dotenv').config();
const http      = require('http');
const app       = require('./src/app');
const { initSocket } = require('./src/realtime/socket');
const connectDB = require('./src/config/db');

const PORT = process.env.PORT || 5000;
const server = http.createServer(app);

initSocket(server);
connectDB();

server.listen(PORT, () => console.log(\`🚀 Quixo server running on port \${PORT}\`));
`);

file("server/src/app.js", `const express  = require('express');
const cors     = require('cors');
const { errorHandler } = require('./shared/middleware/errorHandler');

const app = express();
app.use(cors({ origin: ['http://localhost:3000','http://localhost:3001','http://localhost:3002','http://localhost:3003'], credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Routes ──
app.use('/api/auth',         require('./services/auth/auth.routes'));
app.use('/api/users',        require('./services/user/user.routes'));
app.use('/api/products',     require('./services/product/product.routes'));
app.use('/api/orders',       require('./services/order/order.routes'));
app.use('/api/cart',         require('./services/cart/cart.routes'));
app.use('/api/riders',       require('./services/rider/rider.routes'));
app.use('/api/vendor',       require('./services/vendor/vendor.routes'));
app.use('/api/payment',      require('./services/payment/payment.routes'));
app.use('/api/notifications',require('./services/notification/notification.routes'));
app.use('/api/admin',        require('./services/admin/admin.routes'));
app.use('/api/analytics',    require('./services/analytics/analytics.routes'));
app.use('/api/inventory',    require('./services/inventory/inventory.routes'));
app.use('/api/location',     require('./services/location/location.routes'));

app.use(errorHandler);
module.exports = app;
`);

// Config
file("server/src/config/db.js", `const mongoose = require('mongoose');
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ MongoDB connected');
  } catch (err) {
    console.error('❌ MongoDB error:', err.message);
    process.exit(1);
  }
};
module.exports = connectDB;`);

file("server/src/config/redis.js", `const Redis = require('ioredis');
const redis = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
redis.on('connect', () => console.log('✅ Redis connected'));
redis.on('error',   (err) => console.error('❌ Redis error:', err));
module.exports = redis;`);

file("server/src/config/cloudinary.js", `const cloudinary = require('cloudinary').v2;
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key:    process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});
module.exports = cloudinary;`);

file("server/src/config/env.js", `module.exports = {
  PORT:           process.env.PORT           || 5000,
  MONGO_URI:      process.env.MONGO_URI,
  JWT_SECRET:     process.env.JWT_SECRET,
  JWT_ADMIN_SECRET: process.env.JWT_ADMIN_SECRET,
  REDIS_URL:      process.env.REDIS_URL,
  ESEWA_MERCHANT: process.env.ESEWA_MERCHANT_ID,
  SPARROW_TOKEN:  process.env.SPARROW_SMS_TOKEN,
  MAPS_KEY:       process.env.GOOGLE_MAPS_API_KEY,
};`);

// Shared middleware
file("server/src/shared/middleware/authGuard.js", `const jwt = require('jsonwebtoken');

const authGuard = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: 'No token provided' });
  try {
    req.user = jwt.verify(token, process.env.JWT_SECRET);
    next();
  } catch {
    res.status(401).json({ success: false, message: 'Invalid token' });
  }
};

module.exports = { authGuard };`);

file("server/src/shared/middleware/adminGuard.js", `const jwt = require('jsonwebtoken');

const adminGuard = (req, res, next) => {
  const token = req.headers.authorization?.split(' ')[1];
  if (!token) return res.status(401).json({ success: false, message: 'No token' });
  try {
    const decoded = jwt.verify(token, process.env.JWT_ADMIN_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ success: false, message: 'Forbidden' });
    req.admin = decoded;
    next();
  } catch {
    res.status(401).json({ success: false, message: 'Invalid admin token' });
  }
};

module.exports = { adminGuard };`);

file("server/src/shared/middleware/errorHandler.js", `const errorHandler = (err, req, res, next) => {
  console.error(err.stack);
  res.status(err.statusCode || 500).json({ success: false, message: err.message || 'Server Error' });
};
module.exports = { errorHandler };`);

file("server/src/shared/middleware/rateLimiter.js", `const rateLimit = require('express-rate-limit');
module.exports = rateLimit({ windowMs: 15 * 60 * 1000, max: 100, message: 'Too many requests' });`);

file("server/src/shared/middleware/upload.js", `const multer    = require('multer');
const cloudinary = require('../../config/cloudinary');
const { CloudinaryStorage } = require('multer-storage-cloudinary');

const storage = new CloudinaryStorage({ cloudinary, params: { folder: 'quixo', allowed_formats: ['jpg','png','webp'] } });
module.exports = multer({ storage });`);

file("server/src/shared/utils/generateOTP.js", `const redis = require('../../config/redis');
const crypto = require('crypto');

exports.generateOTP = async (key, ttl = 300) => {
  const otp = crypto.randomInt(100000, 999999).toString();
  await redis.setex(\`otp:\${key}\`, ttl, otp);
  return otp;
};

exports.verifyOTP = async (key, otp) => {
  const stored = await redis.get(\`otp:\${key}\`);
  if (stored === otp) { await redis.del(\`otp:\${key}\`); return true; }
  return false;
};`);

file("server/src/shared/utils/sendSMS.js", `const axios = require('axios');

exports.sendSMS = async (phone, message) => {
  try {
    await axios.post('https://apisms.sparrowsms.com/v2/sms/', {
      token:  process.env.SPARROW_SMS_TOKEN,
      from:   'Quixo',
      to:     phone,
      text:   message,
    });
  } catch (err) {
    console.error('SMS error:', err.message);
  }
};`);

file("server/src/shared/utils/generateInvoice.js", `const PDFDocument = require('pdfkit');

exports.generateInvoice = (order) => new Promise((resolve, reject) => {
  const doc    = new PDFDocument();
  const chunks = [];
  doc.on('data',  (c) => chunks.push(c));
  doc.on('end',   ()  => resolve(Buffer.concat(chunks)));
  doc.on('error', reject);
  doc.fontSize(20).text('Quixo Invoice', { align: 'center' });
  doc.moveDown();
  doc.fontSize(12).text(\`Order ID: \${order._id}\`);
  doc.text(\`Customer: \${order.customerId}\`);
  doc.text(\`Subtotal: NPR \${order.subTotal}\`);
  doc.text(\`VAT (13%): NPR \${order.vat}\`);
  doc.text(\`Delivery: NPR \${order.deliveryCharge}\`);
  doc.text(\`Total: NPR \${order.total}\`);
  doc.end();
});`);

file("server/src/shared/utils/calculateVAT.js", `exports.addVAT  = (price, rate = 0.13) => +(price * (1 + rate)).toFixed(2);
exports.getVAT  = (price, rate = 0.13) => +(price * rate).toFixed(2);`);

// Validators
file("server/src/shared/validators/userValidator.js", `const { body } = require('express-validator');
exports.registerValidator = [
  body('name').notEmpty().withMessage('Name required'),
  body('email').isEmail().withMessage('Valid email required'),
  body('phone').isMobilePhone().withMessage('Valid phone required'),
  body('password').isLength({ min: 6 }).withMessage('Min 6 chars'),
];`);

file("server/src/shared/validators/productValidator.js", `const { body } = require('express-validator');
exports.productValidator = [
  body('name').notEmpty(),
  body('price').isNumeric(),
  body('category').notEmpty(),
  body('deliveryType').isIn(['quick','ecommerce']),
  body('stock').isInt({ min: 0 }),
];`);

file("server/src/shared/validators/orderValidator.js", `const { body } = require('express-validator');
exports.orderValidator = [
  body('items').isArray({ min: 1 }),
  body('address').notEmpty(),
  body('paymentMethod').isIn(['esewa','cod']),
];`);

// Real-time
file("server/src/realtime/socket.js", `const { Server } = require('socket.io');
let io;
exports.initSocket = (server) => {
  io = new Server(server, { cors: { origin: '*' } });
  io.on('connection', (socket) => {
    console.log('Socket connected:', socket.id);
    socket.on('join:order', (orderId) => socket.join(\`order:\${orderId}\`));
    socket.on('join:rider',  (riderId) => socket.join(\`rider:\${riderId}\`));
    socket.on('disconnect', () => console.log('Socket disconnected:', socket.id));
  });
  return io;
};
exports.getIO = () => io;`);

file("server/src/realtime/orderSocket.js", `const { getIO } = require('./socket');
exports.pushOrderUpdate = (orderId, data) => {
  const io = getIO();
  io?.to(\`order:\${orderId}\`).emit('order:update', data);
};`);

file("server/src/realtime/riderSocket.js", `const { getIO } = require('./socket');
exports.pushNewOrder = (riderId, order) => {
  const io = getIO();
  io?.to(\`rider:\${riderId}\`).emit('order:new', order);
};`);

file("server/src/realtime/otpSocket.js", `const { getIO } = require('./socket');
exports.pushOTPEvent = (customerId, otp) => {
  const io = getIO();
  io?.to(\`user:\${customerId}\`).emit('delivery:otp', { otp });
};`);

// Events
file("server/src/events/eventTypes.js", `module.exports = {
  ORDER_PLACED:      'order.placed',
  ORDER_UPDATED:     'order.updated',
  PAYMENT_SUCCESS:   'payment.success',
  RIDER_ASSIGNED:    'rider.assigned',
  RIDER_PICKED:      'rider.picked',
  ORDER_DELIVERED:   'order.delivered',
  STOCK_UPDATED:     'stock.updated',
  VENDOR_APPROVED:   'vendor.approved',
  RIDER_APPROVED:    'rider.approved',
};`);

file("server/src/events/publisher.js", `const redis = require('../config/redis');
exports.publish = async (event, data) => {
  await redis.publish(event, JSON.stringify(data));
  console.log(\`📢 Event published: \${event}\`);
};`);

file("server/src/events/subscriber.js", `const Redis = require('ioredis');
const subscriber = new Redis(process.env.REDIS_URL || 'redis://localhost:6379');
exports.subscribe = (events, handler) => {
  subscriber.subscribe(...events);
  subscriber.on('message', (channel, message) => {
    handler(channel, JSON.parse(message));
  });
};`);

// Services — generate routes/controller/service/model for each domain
const services = [
  { name: "auth",         model: "User"         },
  { name: "user",         model: "User"         },
  { name: "product",      model: "Product"      },
  { name: "order",        model: "Order"        },
  { name: "cart",         model: "Cart"         },
  { name: "rider",        model: "Rider"        },
  { name: "vendor",       model: "Vendor"       },
  { name: "payment",      model: "Payment"      },
  { name: "notification", model: "Notification" },
  { name: "admin",        model: "Admin"        },
  { name: "analytics",    model: "Analytics"    },
  { name: "inventory",    model: "Inventory"    },
  { name: "location",     model: "Location"     },
];

for (const { name, model } of services) {
  file(`server/src/services/${name}/${name}.routes.js`,     expressRoute(name));
  file(`server/src/services/${name}/${name}.controller.js`, expressController(name));
  file(`server/src/services/${name}/${name}.service.js`,    expressService(name, model));
}

// Special: auth model with bcrypt + JWT
file("server/src/services/auth/auth.model.js", `const mongoose = require('mongoose');
const bcrypt   = require('bcryptjs');

const userSchema = new mongoose.Schema({
  name:      { type: String, required: true },
  email:     { type: String, required: true, unique: true },
  phone:     { type: String, required: true },
  password:  { type: String, required: true },
  role:      { type: String, enum: ['customer','vendor','rider','admin'], default: 'customer' },
  isActive:  { type: Boolean, default: true },
  blacklisted: { type: Boolean, default: false },
  addresses: [{ label: String, address: String, lat: Number, lng: Number }],
}, { timestamps: true });

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 12);
  next();
});
userSchema.methods.comparePassword = function (plain) { return bcrypt.compare(plain, this.password); };

module.exports = mongoose.model('User', userSchema);`);

// Order model with status enum
file("server/src/services/order/order.model.js", `const mongoose = require('mongoose');
const orderSchema = new mongoose.Schema({
  customerId:    { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
  vendorId:      { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  riderId:       { type: mongoose.Schema.Types.ObjectId, ref: 'Rider' },
  items:         [{ productId: mongoose.Schema.Types.ObjectId, name: String, price: Number, qty: Number }],
  status:        { type: String, enum: ['pending','preparing','picked','delivered','cancelled'], default: 'pending' },
  deliveryType:  { type: String, enum: ['quick','ecommerce'], required: true },
  address:       { type: String, required: true },
  subTotal:      Number,
  vat:           Number,
  deliveryCharge:Number,
  total:         Number,
  paymentMethod: { type: String, enum: ['esewa','cod'] },
  paymentStatus: { type: String, enum: ['pending','paid'], default: 'pending' },
  deliveryOTP:   String,
}, { timestamps: true });
module.exports = mongoose.model('Order', orderSchema);`);

// Product model
file("server/src/services/product/product.model.js", `const mongoose = require('mongoose');
const productSchema = new mongoose.Schema({
  vendorId:     { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor', required: true },
  name:         { type: String, required: true },
  description:  String,
  brand:        String,
  price:        { type: Number, required: true },
  discount:     { type: Number, default: 0 },
  category:     { type: String, required: true },
  deliveryType: { type: String, enum: ['quick','ecommerce'], required: true },
  stock:        { type: Number, default: 0 },
  images:       [String],
  specs:        { ram: String, storage: String, os: String, color: [String] },
  rating:       { type: Number, default: 0 },
  isHidden:     { type: Boolean, default: false },
  isApproved:   { type: Boolean, default: false },
}, { timestamps: true });
module.exports = mongoose.model('Product', productSchema);`);

// Rider model
file("server/src/services/rider/rider.model.js", `const mongoose = require('mongoose');
const riderSchema = new mongoose.Schema({
  userId:         { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  name:           String, phone: String, email: String,
  rcBook:         String,
  citizenship:    String,
  panCard:        String,
  address:        String,
  bikeDetails:    String,
  bikeInsurance:  String,
  status:         { type: String, enum: ['pending','approved','suspended'], default: 'pending' },
  isAvailable:    { type: Boolean, default: false },
  earnings:       { type: Number, default: 0 },
  deliveredOrders:{ type: Number, default: 0 },
  rating:         { type: Number, default: 0 },
  location:       { lat: Number, lng: Number },
  violationCount: { type: Number, default: 0 },
}, { timestamps: true });
module.exports = mongoose.model('Rider', riderSchema);`);

// Vendor model
file("server/src/services/vendor/vendor.model.js", `const mongoose = require('mongoose');
const vendorSchema = new mongoose.Schema({
  userId:       { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  storeName:    { type: String, required: true },
  ownerName:    String,
  pan:          String,
  address:      String,
  contact:      String,
  businessType: String,
  description:  String,
  logo:         String,
  status:       { type: String, enum: ['pending','approved','suspended'], default: 'pending' },
  revenue:      { type: Number, default: 0 },
  rating:       { type: Number, default: 0 },
  complaints:   [{ message: String, date: Date }],
  violationCount: { type: Number, default: 0 },
}, { timestamps: true });
module.exports = mongoose.model('Vendor', vendorSchema);`);

// Payment model
file("server/src/services/payment/payment.model.js", `const mongoose = require('mongoose');
const paymentSchema = new mongoose.Schema({
  orderId:      { type: mongoose.Schema.Types.ObjectId, ref: 'Order' },
  customerId:   { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  vendorId:     { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor' },
  transactionId:String,
  method:       { type: String, enum: ['esewa','cod'] },
  subTotal:     Number, vat: Number, deliveryCharge: Number, total: Number,
  status:       { type: String, enum: ['pending','success','failed'], default: 'pending' },
}, { timestamps: true });
module.exports = mongoose.model('Payment', paymentSchema);`);

// eSewa handler
file("server/src/services/payment/esewa.js", `const axios = require('axios');

exports.initiateEsewa = (order) => {
  const params = new URLSearchParams({
    amt:          order.subTotal,
    txAmt:        0,
    psc:          0,
    pdc:          order.deliveryCharge,
    tAmt:         order.total,
    pid:          order._id.toString(),
    scd:          process.env.ESEWA_MERCHANT_ID,
    su:           'http://localhost:3000/payment/success',
    fu:           'http://localhost:3000/payment/failed',
  });
  return \`https://uat.esewa.com.np/epay/main?\${params.toString()}\`;
};

exports.verifyEsewa = async (oid, amt) => {
  const res = await axios.post('https://uat.esewa.com.np/epay/transrec', null, {
    params: { amt, rid: '', pid: oid, scd: process.env.ESEWA_MERCHANT_ID }
  });
  return res.data.includes('Success');
};`);

// Order events
file("server/src/services/order/order.events.js", `const { publish }          = require('../../events/publisher');
const { pushOrderUpdate }  = require('../../realtime/orderSocket');
const { pushNewOrder }     = require('../../realtime/riderSocket');
const { pushOTPEvent }     = require('../../realtime/otpSocket');
const EVENTS               = require('../../events/eventTypes');

exports.onOrderPlaced = async (order) => {
  await publish(EVENTS.ORDER_PLACED, order);
  pushOrderUpdate(order._id, { status: 'pending' });
};

exports.onRiderAssigned = async (order, riderId) => {
  await publish(EVENTS.RIDER_ASSIGNED, { orderId: order._id, riderId });
  pushNewOrder(riderId, order);
};

exports.onOrderDelivered = async (order) => {
  await publish(EVENTS.ORDER_DELIVERED, order);
  pushOTPEvent(order.customerId, order.deliveryOTP);
};`);

// Admin model
file("server/src/services/admin/admin.model.js", `const mongoose = require('mongoose');
const adminSchema = new mongoose.Schema({
  name:     String,
  email:    { type: String, unique: true },
  password: String,
  role:     { type: String, default: 'admin' },
}, { timestamps: true });
module.exports = mongoose.model('Admin', adminSchema);`);

// Remaining simple models
for (const [name, schema] of [
  ["cart", `{ userId: { type: mongoose.Schema.Types.ObjectId, ref:'User' }, items: [{ productId: mongoose.Schema.Types.ObjectId, qty: Number, price: Number }] }`],
  ["notification", `{ userId: mongoose.Schema.Types.ObjectId, type: String, message: String, isRead: { type: Boolean, default: false } }`],
  ["inventory", `{ productId: { type: mongoose.Schema.Types.ObjectId, ref:'Product' }, stock: Number, lastUpdated: Date }`],
]) {
  const Model = name.charAt(0).toUpperCase() + name.slice(1);
  file(`server/src/services/${name}/${name}.model.js`,
    `const mongoose = require('mongoose');\nconst schema = new mongoose.Schema(${schema}, { timestamps: true });\nmodule.exports = mongoose.model('${Model}', schema);`);
}

/* ─────────────────────────────────────────────────────────────
   6. NGINX
───────────────────────────────────────────────────────────── */
file("nginx/nginx.conf", `events {}
http {
  upstream quixo_api {
    server localhost:5000;
  }
  server {
    listen 80;
    location /api/ {
      proxy_pass http://quixo_api;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection 'upgrade';
      proxy_set_header Host $host;
    }
    location /socket.io/ {
      proxy_pass http://quixo_api;
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection 'upgrade';
    }
  }
}`);

/* ─────────────────────────────────────────────────────────────
   7. DOCKER
───────────────────────────────────────────────────────────── */
const dockerfile = (app, port) => `FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE ${port}
CMD ["npm", "run", "dev"]`;

file("docker/Dockerfile.client",  dockerfile("client", 3000));
file("docker/Dockerfile.vendor",  dockerfile("vendor", 3001));
file("docker/Dockerfile.rider",   dockerfile("rider",  3002));
file("docker/Dockerfile.admin",   dockerfile("admin",  3003));
file("docker/Dockerfile.server",  `FROM node:20-alpine\nWORKDIR /app\nCOPY package*.json ./\nRUN npm install\nCOPY . .\nEXPOSE 5000\nCMD ["node","server.js"]`);

file("docker/docker-compose.yml", `version: '3.8'
services:
  mongo:
    image: mongo:7
    ports: ["27017:27017"]
    volumes: [mongo_data:/data/db]

  redis:
    image: redis:7-alpine
    ports: ["6379:6379"]

  server:
    build: { context: ../server, dockerfile: ../docker/Dockerfile.server }
    ports: ["5000:5000"]
    env_file: ../server/.env
    depends_on: [mongo, redis]

  client:
    build: { context: ../apps/client, dockerfile: ../docker/Dockerfile.client }
    ports: ["3000:3000"]

  vendor:
    build: { context: ../apps/vendor, dockerfile: ../docker/Dockerfile.vendor }
    ports: ["3001:3001"]

  rider:
    build: { context: ../apps/rider, dockerfile: ../docker/Dockerfile.rider }
    ports: ["3002:3002"]

  admin:
    build: { context: ../apps/admin, dockerfile: ../docker/Dockerfile.admin }
    ports: ["3003:3003"]

volumes:
  mongo_data:
`);

/* ─────────────────────────────────────────────────────────────
   8. ROOT FILES
───────────────────────────────────────────────────────────── */
file(".gitignore", `node_modules/\n.env\ndist/\n.DS_Store\n*.log\n`);
file(".env.example", `# Server\nPORT=5000\nMONGO_URI=mongodb://localhost:27017/quixo\nJWT_SECRET=\nJWT_ADMIN_SECRET=\nREDIS_URL=redis://localhost:6379\nCLOUDINARY_CLOUD_NAME=\nCLOUDINARY_API_KEY=\nCLOUDINARY_API_SECRET=\nESEWA_MERCHANT_ID=\nSPARROW_SMS_TOKEN=\nGOOGLE_MAPS_API_KEY=\n`);
file("README.md", `# Quixo — Hybrid Quick-Commerce + E-Commerce Platform

## Apps
| App | Port | Run |
|-----|------|-----|
| Customer | 3000 | \`cd apps/client && npm install && npm run dev\` |
| Vendor   | 3001 | \`cd apps/vendor && npm install && npm run dev\` |
| Rider    | 3002 | \`cd apps/rider  && npm install && npm run dev\` |
| Admin    | 3003 | \`cd apps/admin  && npm install && npm run dev\` |
| Server   | 5000 | \`cd server       && npm install && npm run dev\` |

## Quick Start
\`\`\`bash
node setup.js       # run this once to scaffold
cd server && npm install && npm run dev
cd apps/client && npm install && npm run dev
\`\`\`
`);
file("package.json", JSON.stringify({
  name: "quixo-monorepo",
  private: true,
  workspaces: ["apps/*", "server"],
  scripts: {
    "dev:client":  "cd apps/client && npm run dev",
    "dev:vendor":  "cd apps/vendor && npm run dev",
    "dev:rider":   "cd apps/rider  && npm run dev",
    "dev:admin":   "cd apps/admin  && npm run dev",
    "dev:server":  "cd server && npm run dev",
    "docker:up":   "docker-compose -f docker/docker-compose.yml up --build"
  }
}, null, 2));

console.log("\n✅ Quixo project structure created successfully!");
console.log("📁 Folder: ./quixo\n");
console.log("Next steps:");
console.log("  1.  cd quixo/server       && npm install && npm run dev");
console.log("  2.  cd quixo/apps/client  && npm install && npm run dev");
console.log("  3.  cd quixo/apps/vendor  && npm install && npm run dev");
console.log("  4.  cd quixo/apps/rider   && npm install && npm run dev");
console.log("  5.  cd quixo/apps/admin   && npm install && npm run dev");
console.log("\n🔑 Fill in your .env values in server/.env before starting!\n");
