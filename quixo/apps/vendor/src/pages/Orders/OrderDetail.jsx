import React, { useState, useEffect } from 'react';
import { Link, useParams, useNavigate } from 'react-router-dom';
import { getOrderById, updateOrder } from '../../services/orderService';

const OrderDetail = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [order, setOrder] = useState(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    fetchOrder();
  }, [id]);

  const fetchOrder = async () => {
    try {
      setLoading(true);
      const { data } = await getOrderById(id);
      setOrder(data.data || data);
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to load order');
    } finally {
      setLoading(false);
    }
  };

  const handleStatusUpdate = async (newStatus) => {
    try {
      setUpdating(true);
      await updateOrder(id, { status: newStatus });
      fetchOrder();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to update status');
    } finally {
      setUpdating(false);
    }
  };

  if (loading) return <div className="container animate-fade-in" style={{ padding: '80px', textAlign: 'center' }}>Loading order...</div>;
  if (error || !order) return <div className="container animate-fade-in" style={{ padding: '80px', textAlign: 'center' }}><h2>{error || 'Order not found'}</h2></div>;

  const statusActions = {
    pending: { label: 'Accept & Confirm', next: 'confirmed', color: 'var(--primary)' },
    confirmed: { label: 'Start Preparing', next: 'preparing', color: 'var(--primary)' },
    preparing: { label: 'Mark as Ready for Pickup', next: 'ready', color: 'var(--success)' },
  };

  const action = statusActions[order.status];
  const statusColors = { pending: '#f59e0b', confirmed: '#3b82f6', preparing: '#8b5cf6', picked: '#ec4899', out_for_delivery: '#06b6d4', delivered: '#10b981', cancelled: '#ef4444' };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1000px', margin: '0 auto' }}>
      {/* Header */}
      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px', alignItems: 'center' }}>
        <Link to="/orders">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>←</button>
        </Link>
        <div style={{ flex: 1 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
            <h1 style={{ fontSize: '2rem', margin: 0 }}>Order #{order._id?.slice(-6).toUpperCase()}</h1>
            <span style={{ padding: '6px 14px', borderRadius: '100px', fontWeight: '600', fontSize: '0.9rem', backgroundColor: `${statusColors[order.status] || '#94a3b8'}20`, color: statusColors[order.status] || '#94a3b8', textTransform: 'capitalize' }}>
              {(order.status || '').replace(/_/g, ' ')}
            </span>
          </div>
          <p className="text-secondary" style={{ marginTop: '8px' }}>
            {order.createdAt ? new Date(order.createdAt).toLocaleString() : ''}
          </p>
        </div>
        <div style={{ display: 'flex', gap: '12px' }}>
          {action && (
            <button
              className="btn btn-primary"
              style={{ padding: '10px 24px', backgroundColor: action.color }}
              onClick={() => handleStatusUpdate(action.next)}
              disabled={updating}
            >
              {updating ? 'Updating...' : action.label}
            </button>
          )}
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
        {/* Left: Items */}
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>
            Ordered Items ({order.items?.length || 0})
          </h3>
          <table className="data-table" style={{ marginBottom: '24px' }}>
            <thead>
              <tr><th>Item</th><th>Qty</th><th>Price</th><th style={{ textAlign: 'right' }}>Total</th></tr>
            </thead>
            <tbody>
              {(order.items || []).map((item, idx) => (
                <tr key={idx}>
                  <td style={{ fontWeight: '600' }}>{item.name || item.productId?.name || 'Product'}</td>
                  <td>{item.qty || 1}</td>
                  <td>NPR {item.price || 0}</td>
                  <td style={{ textAlign: 'right', fontWeight: '600' }}>NPR {((item.price || 0) * (item.qty || 1)).toLocaleString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'flex-end', gap: '8px', paddingRight: '24px' }}>
            <div style={{ display: 'flex', width: '250px', justifyContent: 'space-between', color: 'var(--text-secondary)' }}>
              <span>Subtotal:</span><span>NPR {order.subTotal || order.total || 0}</span>
            </div>
            <div style={{ display: 'flex', width: '250px', justifyContent: 'space-between', color: 'var(--text-secondary)' }}>
              <span>Delivery:</span><span>NPR {order.deliveryCharge || 0}</span>
            </div>
            <div style={{ display: 'flex', width: '250px', justifyContent: 'space-between', fontSize: '1.2rem', fontWeight: '800', marginTop: '8px', paddingTop: '8px', borderTop: '2px solid var(--border)' }}>
              <span>Total:</span><span>NPR {order.total || 0}</span>
            </div>
          </div>
        </div>

        {/* Right: Info cards */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div className="card">
            <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>Customer Details</h3>
            <p style={{ fontWeight: '600', marginBottom: '4px' }}>{order.userId?.name || order.customer || 'Customer'}</p>
            <p style={{ color: 'var(--text-secondary)', marginBottom: '12px' }}>{order.userId?.phone || ''}</p>
            <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>{order.address?.address || order.deliveryAddress || 'No address'}</p>
          </div>

          <div className="card">
            <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>Payment</h3>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Method:</span>
              <span style={{ fontWeight: '600', textTransform: 'capitalize' }}>{(order.paymentMethod || '').replace(/([A-Z])/g, ' $1')}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Status:</span>
              <span style={{ fontWeight: '600', color: order.paymentStatus === 'paid' ? 'var(--success)' : '#f59e0b' }}>{order.paymentStatus || 'pending'}</span>
            </div>
          </div>

          {order.riderId && (
            <div className="card">
              <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>Assigned Rider</h3>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ width: '40px', height: '40px', borderRadius: '50%', backgroundColor: 'var(--primary-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.2rem' }}>🛵</div>
                <div>
                  <p style={{ fontWeight: '600', margin: 0 }}>{order.riderId?.name || 'Rider'}</p>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', margin: 0 }}>{order.riderId?.phone || ''}</p>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default OrderDetail;
