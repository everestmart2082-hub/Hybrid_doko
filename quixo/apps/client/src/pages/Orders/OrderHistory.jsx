import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { orderAPI } from '../../services/api';

const OrderHistory = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [cancelling, setCancelling] = useState(null);

  useEffect(() => {
    fetchOrders();
  }, []);

  const fetchOrders = async () => {
    try {
      setLoading(true);
      const { data } = await orderAPI.getAll();
      setOrders(data.data || []);
    } catch (err) {
      console.error('Failed to fetch orders:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleCancel = async (orderId) => {
    if (!window.confirm('Are you sure you want to cancel this order?')) return;
    try {
      setCancelling(orderId);
      await orderAPI.cancel(orderId);
      fetchOrders();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to cancel order');
    } finally {
      setCancelling(null);
    }
  };

  const getStatusColor = (status) => {
    const colors = {
      pending: { bg: '#fef3c7', color: '#92400e' },
      confirmed: { bg: '#dbeafe', color: '#1e40af' },
      preparing: { bg: '#e0e7ff', color: '#3730a3' },
      picked: { bg: '#fae8ff', color: '#86198f' },
      out_for_delivery: { bg: '#ecfdf5', color: '#065f46' },
      delivered: { bg: '#ecfdf5', color: 'var(--primary-dark)' },
      cancelled: { bg: '#fee2e2', color: '#dc2626' },
    };
    return colors[status] || { bg: '#f1f5f9', color: '#475569' };
  };

  const canCancel = (status) => !['delivered', 'cancelled', 'out_for_delivery'].includes(status);

  const formatDate = (dateStr) => {
    try {
      return new Date(dateStr).toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' });
    } catch { return dateStr; }
  };

  if (loading) {
    return (
      <div className="container animate-fade-in" style={{ ...styles.page, textAlign: 'center', paddingTop: '100px' }}>
        <div style={{ fontSize: '2rem', marginBottom: '16px' }}>⏳</div>
        <p>Loading your orders...</p>
      </div>
    );
  }

  return (
    <div className="container animate-fade-in" style={styles.page}>
      <h1 style={styles.title}>My Orders</h1>

      {orders.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '60px 20px' }}>
          <div style={{ fontSize: '3rem', marginBottom: '16px' }}>📦</div>
          <h3>No orders yet</h3>
          <p style={{ color: 'var(--text-secondary)', marginBottom: '20px' }}>Start shopping to see your orders here!</p>
          <Link to="/products"><button className="btn btn-primary">Browse Products</button></Link>
        </div>
      ) : (
        <div style={styles.orderList}>
          {orders.map(order => {
            const statusStyle = getStatusColor(order.status);
            return (
              <div key={order._id} style={styles.orderCard}>
                <div style={styles.orderHeader}>
                  <div>
                    <h3 style={{ fontSize: '1.2rem' }}>Order #{order._id?.slice(-6).toUpperCase()}</h3>
                    <div style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginTop: '4px' }}>
                      Placed on {formatDate(order.createdAt)} • {order.items?.length || 0} Items
                    </div>
                  </div>
                  <div style={{ ...styles.statusBadge, backgroundColor: statusStyle.bg, color: statusStyle.color }}>
                    {(order.status || 'pending').replace(/_/g, ' ')}
                  </div>
                </div>

                <div style={styles.orderFooter}>
                  <div style={{ fontWeight: '700', fontSize: '1.1rem' }}>Total: Rs. {order.total || 0}</div>
                  <div style={{ display: 'flex', gap: '10px' }}>
                    {canCancel(order.status) && (
                      <button
                        className="btn"
                        style={{ ...styles.trackBtn, color: '#dc2626', borderColor: '#dc2626' }}
                        onClick={() => handleCancel(order._id)}
                        disabled={cancelling === order._id}
                      >
                        {cancelling === order._id ? 'Cancelling...' : 'Cancel'}
                      </button>
                    )}
                    <Link to={`/orders/${order._id}`}>
                      <button className="btn" style={styles.trackBtn}>
                        {order.status === 'delivered' ? 'View Details' : 'Track Order'}
                      </button>
                    </Link>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

const styles = {
  page: { padding: '40px 20px', maxWidth: '800px', margin: '0 auto', minHeight: 'calc(100vh - 70px)' },
  title: { fontSize: '2.5rem', marginBottom: '30px' },
  orderList: { display: 'flex', flexDirection: 'column', gap: '20px' },
  orderCard: { backgroundColor: 'var(--surface)', padding: '24px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' },
  orderHeader: { display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '20px' },
  statusBadge: { padding: '6px 12px', borderRadius: '100px', fontWeight: '600', fontSize: '0.85rem', textTransform: 'capitalize' },
  orderFooter: { display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  trackBtn: { border: '1px solid var(--border)', backgroundColor: 'transparent', fontWeight: '600', padding: '8px 20px' }
};

export default OrderHistory;
