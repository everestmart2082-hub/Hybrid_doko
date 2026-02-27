import React, { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { orderAPI } from '../../services/api';

const STATUS_STEPS = [
  { key: 'pending', name: 'Order Placed' },
  { key: 'confirmed', name: 'Order Confirmed' },
  { key: 'preparing', name: 'Preparing' },
  { key: 'picked', name: 'Picked Up' },
  { key: 'out_for_delivery', name: 'Out for Delivery' },
  { key: 'delivered', name: 'Delivered' },
];

const OrderTracking = () => {
  const { id } = useParams();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      const { data } = await orderAPI.getById(id);
      setOrder(data.data || data);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to load order');
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}><p>Loading order...</p></div>;
  }

  if (error || !order) {
    return <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}><h2>{error || 'Order not found'}</h2><Link to="/orders"><button className="btn btn-primary" style={{ marginTop: '20px' }}>Back to Orders</button></Link></div>;
  }

  const currentIndex = STATUS_STEPS.findIndex(s => s.key === order.status);
  const isCancelled = order.status === 'cancelled';

  const steps = STATUS_STEPS.map((step, idx) => ({
    ...step,
    status: isCancelled ? 'cancelled' : idx < currentIndex ? 'completed' : idx === currentIndex ? 'active' : 'pending',
    time: order.statusHistory?.find(h => h.status === step.key)?.timestamp
      ? new Date(order.statusHistory.find(h => h.status === step.key).timestamp).toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit' })
      : 'Pending'
  }));

  return (
    <div className="container animate-fade-in" style={styles.page}>
      <div style={styles.header}>
        <h1 style={styles.title}>Track Order</h1>
        <div style={styles.orderId}>Order #{order._id?.slice(-6).toUpperCase()}</div>
      </div>

      <div style={styles.content}>
        {/* Map Section */}
        <div style={styles.mapSection}>
          <div style={styles.mapPlaceholder}>
            <span style={{ fontSize: '4rem', marginBottom: '16px' }}>🗺️</span>
            <div style={{ fontWeight: '600', color: 'var(--text-secondary)' }}>Live Tracking Map</div>
            {order.status === 'out_for_delivery' && (
              <div style={styles.etaBadge}>🛵 Rider is on the way!</div>
            )}
            {order.status === 'delivered' && (
              <div style={styles.etaBadge}>✅ Delivered!</div>
            )}
          </div>
          {/* Order Items */}
          <div style={{ marginTop: '20px', backgroundColor: 'var(--surface)', padding: '24px', borderRadius: 'var(--radius-lg)', border: '1px solid var(--border)' }}>
            <h3 style={{ fontSize: '1.1rem', marginBottom: '16px' }}>Order Items</h3>
            {order.items?.map((item, idx) => (
              <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 0', borderBottom: idx < order.items.length - 1 ? '1px solid var(--border)' : 'none' }}>
                <span>{item.name || 'Product'} × {item.qty || 1}</span>
                <span style={{ fontWeight: '600' }}>Rs. {((item.price || 0) * (item.qty || 1)).toFixed(0)}</span>
              </div>
            ))}
            <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: '16px', paddingTop: '12px', borderTop: '2px solid var(--border)', fontWeight: '700', fontSize: '1.1rem' }}>
              <span>Total</span>
              <span>Rs. {order.total || 0}</span>
            </div>
          </div>
        </div>

        {/* Timeline Section */}
        <div style={styles.timelineSection}>
          <h3 style={{ fontSize: '1.4rem', marginBottom: '30px' }}>
            {isCancelled ? '❌ Order Cancelled' : 'Delivery Status'}
          </h3>

          {!isCancelled && (
            <div style={styles.timeline}>
              {steps.map((step, index) => (
                <div key={step.key} style={styles.step}>
                  <div style={styles.stepIndicator}>
                    <div style={styles.stepDot(step.status)}>
                      {step.status === 'completed' && '✓'}
                    </div>
                    {index < steps.length - 1 && (
                      <div style={styles.stepLine(step.status === 'completed')}></div>
                    )}
                  </div>
                  <div style={styles.stepContent}>
                    <div style={styles.stepName(step.status)}>{step.name}</div>
                    <div style={styles.stepTime}>{step.time}</div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Rider Info */}
          {order.riderId && (
            <div style={styles.riderCard}>
              <div style={styles.riderAvatar}>👨‍🚀</div>
              <div style={{ flex: '1' }}>
                <h4 style={{ fontSize: '1.1rem', marginBottom: '4px' }}>{order.riderId?.name || 'Rider'}</h4>
                <div style={{ fontSize: '0.9rem', color: 'var(--text-secondary)' }}>Doko Rider • {order.riderId?.phone || ''}</div>
              </div>
            </div>
          )}

          {/* Delivery OTP */}
          {order.deliveryOTP && ['picked', 'out_for_delivery'].includes(order.status) && (
            <div style={{ marginTop: '24px', padding: '20px', backgroundColor: '#fffbeb', borderRadius: 'var(--radius-md)', border: '1px solid #fde68a' }}>
              <h4 style={{ fontSize: '1rem', marginBottom: '8px', color: '#92400e' }}>🔐 Delivery OTP</h4>
              <p style={{ fontSize: '0.9rem', color: '#78350f', marginBottom: '12px' }}>Share this code with your rider to confirm delivery:</p>
              <div style={{ display: 'flex', gap: '8px', justifyContent: 'center' }}>
                {String(order.deliveryOTP).split('').map((digit, i) => (
                  <div key={i} style={{ width: '48px', height: '56px', backgroundColor: 'white', border: '2px solid #f59e0b', borderRadius: 'var(--radius-sm)', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '1.5rem', fontWeight: '800', color: '#92400e' }}>{digit}</div>
                ))}
              </div>
            </div>
          )}

          {/* Payment Info */}
          <div style={{ marginTop: '24px', padding: '16px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Payment</span>
              <span style={{ fontWeight: '600', textTransform: 'capitalize' }}>{(order.paymentMethod || '').replace(/([A-Z])/g, ' $1')}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Payment Status</span>
              <span style={{ fontWeight: '600', color: order.paymentStatus === 'paid' ? 'var(--primary)' : '#f59e0b' }}>{order.paymentStatus || 'pending'}</span>
            </div>
          </div>

          <Link to="/orders" style={{ display: 'block', textDecoration: 'none', marginTop: '30px' }}>
            <button className="btn" style={{ width: '100%', border: '1px solid var(--border)' }}>Back to Orders</button>
          </Link>
        </div>
      </div>
    </div>
  );
};

const styles = {
  page: { padding: '40px 20px', minHeight: 'calc(100vh - 70px)' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '30px' },
  title: { fontSize: '2.5rem' },
  orderId: { fontSize: '1.2rem', color: 'var(--text-secondary)', fontWeight: '600' },
  content: { display: 'flex', gap: '40px', alignItems: 'stretch' },
  mapSection: { flex: '2' },
  mapPlaceholder: { height: '350px', backgroundColor: '#f1f5f9', borderRadius: 'var(--radius-lg)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', border: '2px dashed #cbd5e1', position: 'relative' },
  etaBadge: { position: 'absolute', top: '30px', left: '50%', transform: 'translateX(-50%)', backgroundColor: 'var(--surface)', padding: '12px 24px', borderRadius: '100px', boxShadow: 'var(--shadow-md)', fontWeight: '700', color: 'var(--primary-dark)', fontSize: '1.1rem' },
  timelineSection: { flex: '1', minWidth: '350px', backgroundColor: 'var(--surface)', padding: '30px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' },
  timeline: { display: 'flex', flexDirection: 'column', gap: '0' },
  step: { display: 'flex', gap: '20px' },
  stepIndicator: { display: 'flex', flexDirection: 'column', alignItems: 'center', width: '32px' },
  stepDot: (status) => ({ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: status === 'completed' ? 'var(--primary)' : status === 'active' ? '#ecfdf5' : '#f1f5f9', border: `2px solid ${status === 'pending' ? '#cbd5e1' : 'var(--primary)'}`, display: 'flex', justifyContent: 'center', alignItems: 'center', color: 'white', fontSize: '0.9rem', fontWeight: '700', zIndex: '2' }),
  stepLine: (isCompleted) => ({ width: '2px', height: '50px', backgroundColor: isCompleted ? 'var(--primary)' : '#cbd5e1', margin: '-4px 0', zIndex: '1' }),
  stepContent: { paddingBottom: '40px', paddingTop: '4px' },
  stepName: (status) => ({ fontSize: '1.1rem', fontWeight: status === 'active' ? '700' : '500', color: status === 'pending' ? 'var(--text-secondary)' : 'var(--text-primary)', marginBottom: '4px' }),
  stepTime: { fontSize: '0.9rem', color: 'var(--text-secondary)' },
  riderCard: { marginTop: '20px', padding: '20px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-md)', display: 'flex', alignItems: 'center', gap: '16px', border: '1px solid var(--border)' },
  riderAvatar: { width: '48px', height: '48px', borderRadius: '50%', backgroundColor: '#e2e8f0', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '1.5rem' }
};

export default OrderTracking;
