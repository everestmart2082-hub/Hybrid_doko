import React, { useEffect } from 'react';
import { Routes, Route } from 'react-router-dom';
import RiderLogin from './pages/Auth/RiderLogin';
import RiderRegister from './pages/Auth/RiderRegister';
import Dashboard from './pages/Dashboard/index';
import AvailableOrders from './pages/Orders/AvailableOrders';
import InProgress from './pages/Orders/InProgress';
import OrderDetail from './pages/Orders/OrderDetail';
import EarningsPage from './pages/Earnings/EarningsPage';
import MapPage from './pages/Map/MapPage';
import RiderProfile from './pages/Profile/RiderProfile';
import BottomNav from './components/BottomNav';

const App = () => {
  // Receive token from unified login redirect (http://localhost:3002/?token=xxx)
  useEffect(() => {
    const params = new URLSearchParams(window.location.search);
    const token = params.get('token');
    if (token) {
      localStorage.setItem('rider_token', token);
      window.history.replaceState({}, '', '/');
    }
  }, []);

  return (
    <>
      <Routes>
        <Route path="/login" element={<RiderLogin />} />
        <Route path="/register" element={<RiderRegister />} />
        <Route path="/" element={<Dashboard />} />
        <Route path="/orders/available" element={<AvailableOrders />} />
        <Route path="/orders/progress" element={<InProgress />} />
        <Route path="/orders/:id" element={<OrderDetail />} />
        <Route path="/earnings" element={<EarningsPage />} />
        <Route path="/map" element={<MapPage />} />
        <Route path="/profile" element={<RiderProfile />} />
      </Routes>
      <BottomNav />
    </>
  );
};
export default App;