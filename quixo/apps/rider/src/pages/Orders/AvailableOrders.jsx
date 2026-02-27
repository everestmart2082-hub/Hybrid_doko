import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({
  baseURL: (import.meta.env.VITE_API_URL || 'http://localhost:5000/api/v1') + '/orders',
});
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('riderToken') || localStorage.getItem('token');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

const AvailableOrders = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const navigate = useNavigate();

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      const { data } = await API.get('/');
      // Show orders that need a rider (preparing status, ready for pickup)
      const available = (data.data || []).filter(o =>
        ['confirmed', 'preparing'].includes(o.status)
      );
      setOrders(available);
    } catch (err) {
      console.error('Failed to fetch orders:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAccept = async (orderId) => {
    try {
      await API.put(`/${orderId}`, { status: 'picked' });
      navigate(`/orders/${orderId}`);
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to accept order');
    }
  };

  return (
    <div className="view-container animate-fade-in">
      <div style={{ padding: '20px', backgroundColor: 'var(--surface)', position: 'sticky', top: 0, zIndex: 10, boxShadow: 'var(--shadow-sm)' }}>
        <h1 style={{ fontSize: '1.5rem', margin: 0 }}>Available Deliveries</h1>
        <p className="text-secondary" style={{ fontSize: '0.85rem', marginTop: '4px' }}>
          {loading ? 'Searching...' : `Found ${orders.length} order(s) near you`}
        </p>
      </div>

      <div className="container" style={{ paddingTop: '20px', paddingBottom: '100px' }}>
        {loading ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-secondary)' }}>
            <div style={{ fontSize: '2rem', marginBottom: '12px' }}>🔍</div>
            Searching for orders...
          </div>
        ) : orders.length === 0 ? (
          <div style={{ textAlign: 'center', padding: '60px 20px', color: 'var(--text-secondary)' }}>
            <div style={{ fontSize: '2rem', marginBottom: '12px' }}>☕</div>
            <h3>No available orders right now</h3>
            <p style={{ fontSize: '0.9rem' }}>Check back in a few minutes or move to a busier area.</p>
          </div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {orders.map((order) => (
              <div key={order._id} className="card" style={{ padding: '0', overflow: 'hidden', border: '1px solid var(--primary-light)' }}>
                <div style={{ padding: '16px', borderBottom: '1px solid var(--border)', backgroundColor: 'var(--surface)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                    <div>
                      <h3 style={{ fontSize: '1.1rem', margin: 0, color: 'var(--text-primary)' }}>
                        {order.vendorId?.storeName || order.vendorId?.name || 'Store'}
                      </h3>
                      <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginTop: '4px' }}>
                        Order #{order._id?.slice(-6).toUpperCase()} • {order.items?.length || 0} items
                      </p>
                    </div>
                    <div style={{ textAlign: 'right' }}>
                      <div style={{ fontSize: '1.2rem', fontWeight: '800', color: 'var(--success)' }}>NPR {order.total || 0}</div>
                      <div className="badge badge-warning" style={{ marginTop: '4px', fontSize: '0.7rem', textTransform: 'capitalize' }}>
                        {(order.status || '').replace(/_/g, ' ')}
                      </div>
                    </div>
                  </div>

                  <div style={{ display: 'flex', alignItems: 'center', gap: '8px', padding: '12px', backgroundColor: 'var(--bg-color)', borderRadius: 'var(--radius-sm)' }}>
                    <span style={{ fontSize: '1.2rem' }}>🎯</span>
                    <div>
                      <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', fontWeight: 'bold', textTransform: 'uppercase' }}>Delivery To</div>
                      <div style={{ fontSize: '0.95rem', fontWeight: '600' }}>
                        {order.address?.address || order.userId?.name || 'Customer'}
                      </div>
                    </div>
                  </div>
                </div>

                <div style={{ display: 'flex' }}>
                  <button className="btn btn-outline" style={{ flex: 1, borderRadius: 0, border: 'none', borderRight: '1px solid var(--border)' }}>Skip</button>
                  <button
                    className="btn"
                    style={{ flex: 1, borderRadius: 0, border: 'none', backgroundColor: 'var(--primary)', color: 'white' }}
                    onClick={() => handleAccept(order._id)}
                  >
                    Accept Order
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default AvailableOrders;
