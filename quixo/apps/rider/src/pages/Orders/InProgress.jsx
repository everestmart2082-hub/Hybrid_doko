import React, { useState, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api';
const getToken = () => localStorage.getItem('rider_token');

const InProgress = () => {
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [otpInput, setOtpInput] = useState('');
  const [showOtp, setShowOtp] = useState(false);

  useEffect(() => {
    fetchActiveOrder();
  }, []);

  const fetchActiveOrder = async () => {
    try {
      // new_server doesn't have a rider order listing endpoint yet
      setOrder(null);
    } catch (err) {
      console.error('Failed to fetch active order:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (newStatus) => {
    if (!order) return;
    try {
      setUpdating(true);
      const payload = { status: newStatus };
      if (newStatus === 'delivered' && otpInput) payload.otp = otpInput;
      // Stub: order update not yet wired to new_server
      if (newStatus === 'delivered') {
        alert('🎉 Delivery completed! Earnings added to your wallet.');
        navigate('/');
      } else {
        fetchActiveOrder();
      }
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to update status');
    } finally {
      setUpdating(false);
    }
  };

  const step = order?.status === 'picked' ? 2 : order?.status === 'out_for_delivery' ? 3 : 1;

  if (loading) {
    return <div className="view-container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}>Loading...</div>;
  }

  if (!order) {
    return (
      <div className="view-container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}>
        <div style={{ fontSize: '2rem', marginBottom: '16px' }}>📦</div>
        <h3>No active delivery</h3>
        <p style={{ color: 'var(--text-secondary)' }}>Accept an order to start delivering.</p>
        <Link to="/orders/available"><button className="btn btn-primary" style={{ marginTop: '16px' }}>Find Orders</button></Link>
      </div>
    );
  }

  return (
    <div className="view-container animate-fade-in" style={{ paddingBottom: '120px' }}>
      {/* Map Header */}
      <div style={{ height: '250px', backgroundColor: '#e2e8f0', position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <Link to="/" style={{ position: 'absolute', top: '20px', left: '20px' }}>
          <button className="btn btn-outline" style={{ backgroundColor: 'white', border: 'none', boxShadow: 'var(--shadow-sm)', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>←</button>
        </Link>
        <span style={{ fontSize: '3rem', opacity: 0.5 }}>🗺️</span>
        <div style={{ position: 'absolute', bottom: '-20px', left: '50%', transform: 'translateX(-50%)', backgroundColor: 'var(--surface)', padding: '12px 24px', borderRadius: '100px', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '8px', zIndex: 10 }}>
          <div style={{ width: '10px', height: '10px', borderRadius: '50%', backgroundColor: 'var(--primary)' }}></div>
          <span style={{ fontWeight: 'bold', fontSize: '0.9rem' }}>
            {step === 2 ? 'Pick up order' : 'Deliver to customer'}
          </span>
        </div>
      </div>

      <div className="container" style={{ paddingTop: '40px' }}>
        {/* Pickup */}
        <div className="card" style={{ marginBottom: '20px', borderLeft: step === 2 ? '4px solid var(--primary)' : '1px solid var(--border)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <h3 style={{ fontSize: '1.1rem', margin: 0 }}>Pickup: {order.vendorId?.storeName || order.vendorId?.name || 'Store'}</h3>
            <span style={{ fontSize: '1.2rem' }}>🏪</span>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '16px' }}>{order.vendorId?.address || 'Vendor location'}</p>
          <Link to={`/orders/${order._id}`} style={{ flex: 1 }}>
            <button className="btn btn-outline" style={{ width: '100%', padding: '8px', fontSize: '0.85rem' }}>📋 View Order Items</button>
          </Link>
        </div>

        {/* Dropoff */}
        <div className="card" style={{ marginBottom: '20px', borderLeft: step === 3 ? '4px solid var(--primary)' : '1px solid var(--border)', opacity: step === 3 ? 1 : 0.6 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <h3 style={{ fontSize: '1.1rem', margin: 0 }}>Dropoff: {order.userId?.name || 'Customer'}</h3>
            <span style={{ fontSize: '1.2rem' }}>🏠</span>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '16px' }}>{order.address?.address || 'Customer address'}</p>
          {order.userId?.phone && (
            <a href={`tel:${order.userId.phone}`} className="btn btn-outline" style={{ padding: '8px', fontSize: '0.85rem' }}>📞 Call {order.userId.phone}</a>
          )}
        </div>

        {/* OTP Input */}
        {showOtp && (
          <div className="card" style={{ marginBottom: '20px', backgroundColor: '#fffbeb', borderColor: '#fde68a' }}>
            <h3 style={{ fontSize: '1rem', marginBottom: '12px', color: '#92400e' }}>🔐 Enter Delivery OTP</h3>
            <input
              type="text"
              value={otpInput}
              onChange={(e) => setOtpInput(e.target.value.replace(/\D/g, '').slice(0, 6))}
              placeholder="Enter OTP from customer"
              style={{ width: '100%', padding: '14px', borderRadius: 'var(--radius-sm)', border: '2px solid #f59e0b', fontSize: '1.2rem', textAlign: 'center', letterSpacing: '6px', fontWeight: '800', marginBottom: '12px' }}
            />
            <button
              className="btn btn-primary"
              style={{ width: '100%', padding: '14px', backgroundColor: '#10b981' }}
              onClick={() => handleStatusUpdate('delivered')}
              disabled={updating || otpInput.length < 4}
            >
              {updating ? 'Confirming...' : '✅ Confirm Delivery'}
            </button>
          </div>
        )}
      </div>

      {/* Bottom Action Bar */}
      {!showOtp && (
        <div style={{ position: 'fixed', bottom: '70px', left: '0', right: '0', padding: '20px', backgroundColor: 'var(--surface)', borderTop: '1px solid var(--border)', zIndex: 20 }}>
          <div style={{ maxWidth: '600px', margin: '0 auto', display: 'flex', gap: '12px' }}>
            <button className="btn btn-outline" style={{ color: 'var(--danger)', borderColor: 'var(--danger)', padding: '16px 20px' }}>⚠️</button>
            <button
              className="btn btn-primary"
              style={{ flex: 1, padding: '16px', fontSize: '1.1rem' }}
              onClick={() => {
                if (step === 2) handleStatusUpdate('out_for_delivery');
                else if (step === 3) setShowOtp(true);
              }}
              disabled={updating}
            >
              {updating ? 'Updating...' : step === 2 ? 'Confirm Pickup' : 'Mark Delivered'}
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default InProgress;
