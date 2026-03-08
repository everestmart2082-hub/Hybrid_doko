import React, { useState, useEffect } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import axios from 'axios';

const API_BASE = import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api';
const getToken = () => localStorage.getItem('rider_token');

const OrderDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [otpInput, setOtpInput] = useState('');
  const [showOtp, setShowOtp] = useState(false);

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      // new_server doesn't have a rider order detail endpoint yet
      setOrder(null);
    } catch (err) {
      console.error('Failed to fetch order:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (newStatus) => {
    try {
      setUpdating(true);
      const payload = { status: newStatus };
      if (newStatus === 'delivered' && otpInput) {
        payload.otp = otpInput;
      }
      // Stub: order update not yet wired to new_server
      fetchOrder();
      if (newStatus === 'delivered') {
        alert('🎉 Delivery completed! Earnings added.');
        navigate('/');
      }
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to update status');
    } finally {
      setUpdating(false);
    }
  };

  if (loading) {
    return <div className="view-container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}>Loading order details...</div>;
  }

  if (!order) {
    return (
      <div className="view-container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}>
        <h2>Order not found</h2>
        <Link to="/orders/available"><button className="btn btn-primary" style={{ marginTop: '16px' }}>Back to Orders</button></Link>
      </div>
    );
  }

  const statusColors = { pending: '#f59e0b', confirmed: '#3b82f6', preparing: '#8b5cf6', picked: '#ec4899', out_for_delivery: '#06b6d4', delivered: '#10b981', cancelled: '#ef4444' };

  const getActionButton = () => {
    switch (order.status) {
      case 'preparing':
        return { label: '📦 Confirm Pickup', next: 'picked' };
      case 'picked':
        return { label: '🛵 Start Delivery', next: 'out_for_delivery' };
      case 'out_for_delivery':
        return { label: '✅ Mark Delivered', next: 'delivered', needsOtp: true };
      default:
        return null;
    }
  };

  const action = getActionButton();

  return (
    <div className="view-container animate-fade-in" style={{ paddingBottom: '140px' }}>
      {/* Header */}
      <div style={{ padding: '20px', backgroundColor: 'var(--surface)', boxShadow: 'var(--shadow-sm)', display: 'flex', alignItems: 'center', gap: '16px' }}>
        <Link to="/orders/available">
          <button className="btn btn-outline" style={{ width: '36px', height: '36px', padding: 0, borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>←</button>
        </Link>
        <div style={{ flex: 1 }}>
          <h2 style={{ fontSize: '1.2rem', margin: 0 }}>Order #{order._id?.slice(-6).toUpperCase()}</h2>
          <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
            {order.createdAt ? new Date(order.createdAt).toLocaleString() : ''}
          </span>
        </div>
        <span style={{ padding: '6px 14px', borderRadius: '100px', fontWeight: '600', fontSize: '0.8rem', backgroundColor: `${statusColors[order.status] || '#94a3b8'}20`, color: statusColors[order.status] || '#94a3b8', textTransform: 'capitalize' }}>
          {(order.status || '').replace(/_/g, ' ')}
        </span>
      </div>

      <div className="container" style={{ paddingTop: '20px' }}>
        {/* Pickup Location */}
        <div className="card" style={{ marginBottom: '16px', borderLeft: ['preparing', 'confirmed'].includes(order.status) ? '4px solid var(--primary)' : '1px solid var(--border)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <h3 style={{ fontSize: '1.1rem', margin: 0 }}>🏪 Pickup</h3>
          </div>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '8px' }}>
            {order.vendorId?.storeName || order.vendorId?.name || 'Vendor Store'}
          </p>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
            {order.vendorId?.address || 'Vendor address'}
          </p>
        </div>

        {/* Dropoff Location */}
        <div className="card" style={{ marginBottom: '16px', borderLeft: ['picked', 'out_for_delivery'].includes(order.status) ? '4px solid var(--primary)' : '1px solid var(--border)', opacity: ['picked', 'out_for_delivery'].includes(order.status) ? 1 : 0.7 }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
            <h3 style={{ fontSize: '1.1rem', margin: 0 }}>🏠 Dropoff</h3>
          </div>
          <p style={{ fontWeight: '600', fontSize: '0.95rem', marginBottom: '4px' }}>
            {order.userId?.name || 'Customer'}
          </p>
          <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '8px' }}>
            {order.address?.address || order.deliveryAddress || 'Customer address'}
          </p>
          {order.userId?.phone && (
            <a href={`tel:${order.userId.phone}`} className="btn btn-outline" style={{ padding: '6px 14px', fontSize: '0.85rem', display: 'inline-flex', gap: '6px' }}>
              📞 {order.userId.phone}
            </a>
          )}
        </div>

        {/* Order Items */}
        <div className="card" style={{ marginBottom: '16px' }}>
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>
            📋 Items ({order.items?.length || 0})
          </h3>
          {(order.items || []).map((item, idx) => (
            <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 0', borderBottom: idx < order.items.length - 1 ? '1px solid var(--border)' : 'none', alignItems: 'center' }}>
              <div>
                <div style={{ fontWeight: '600' }}>{item.name || 'Product'}</div>
                <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>× {item.qty || 1}</div>
              </div>
              <span style={{ fontWeight: '600' }}>NPR {((item.price || 0) * (item.qty || 1)).toLocaleString()}</span>
            </div>
          ))}
          <div style={{ display: 'flex', justifyContent: 'space-between', paddingTop: '12px', marginTop: '12px', borderTop: '2px solid var(--border)', fontWeight: '800', fontSize: '1.1rem' }}>
            <span>Total</span>
            <span>NPR {(order.total || 0).toLocaleString()}</span>
          </div>
        </div>

        {/* Payment Info */}
        <div className="card" style={{ marginBottom: '16px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <span style={{ color: 'var(--text-secondary)' }}>Payment</span>
            <span style={{ fontWeight: '600', textTransform: 'capitalize' }}>{(order.paymentMethod || '').replace(/([A-Z])/g, ' $1')}</span>
          </div>
        </div>

        {/* OTP Input for Delivery */}
        {showOtp && (
          <div className="card" style={{ marginBottom: '16px', backgroundColor: '#fffbeb', borderColor: '#fde68a' }}>
            <h3 style={{ fontSize: '1rem', marginBottom: '12px', color: '#92400e' }}>🔐 Enter Delivery OTP</h3>
            <p style={{ fontSize: '0.85rem', color: '#78350f', marginBottom: '12px' }}>Ask the customer for their delivery verification code.</p>
            <div style={{ display: 'flex', gap: '8px' }}>
              <input
                type="text"
                value={otpInput}
                onChange={(e) => setOtpInput(e.target.value.replace(/\D/g, '').slice(0, 6))}
                placeholder="Enter OTP"
                style={{ flex: 1, padding: '14px', borderRadius: 'var(--radius-sm)', border: '2px solid #f59e0b', fontSize: '1.2rem', textAlign: 'center', letterSpacing: '6px', fontWeight: '800' }}
              />
            </div>
            <button
              className="btn btn-primary"
              style={{ width: '100%', marginTop: '12px', padding: '14px', backgroundColor: '#10b981' }}
              onClick={() => handleStatusUpdate('delivered')}
              disabled={updating || otpInput.length < 4}
            >
              {updating ? 'Confirming...' : '✅ Confirm Delivery'}
            </button>
          </div>
        )}
      </div>

      {/* Bottom Action Bar */}
      {action && !showOtp && (
        <div style={{ position: 'fixed', bottom: '70px', left: 0, right: 0, padding: '20px', backgroundColor: 'var(--surface)', borderTop: '1px solid var(--border)', zIndex: 20 }}>
          <div style={{ maxWidth: '600px', margin: '0 auto', display: 'flex', gap: '12px' }}>
            <button
              className="btn btn-primary"
              style={{ flex: 1, padding: '16px', fontSize: '1.1rem' }}
              onClick={() => action.needsOtp ? setShowOtp(true) : handleStatusUpdate(action.next)}
              disabled={updating}
            >
              {updating ? 'Updating...' : action.label}
            </button>
          </div>
        </div>
      )}
    </div>
  );
};

export default OrderDetail;
