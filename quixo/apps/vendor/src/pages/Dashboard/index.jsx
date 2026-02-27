import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { getOrders, updateOrder } from '../../services/orderService';

const mockKPIs = [
  { title: 'Today\'s Sales', value: 'NPR 0', icon: '💰' },
  { title: 'Pending Orders', value: '0', icon: '⏳', actionRequire: true },
  { title: 'Completed Today', value: '0', icon: '✅' },
  { title: 'Total Products', value: '-', icon: '📦' }
];

const Dashboard = () => {
  const [orders, setOrders] = useState([]);
  const [kpis, setKpis] = useState(mockKPIs);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      const { data } = await getOrders();
      const allOrders = data.data || [];
      setOrders(allOrders);

      const today = new Date().toDateString();
      const todayOrders = allOrders.filter(o => new Date(o.createdAt).toDateString() === today);
      const pendingOrders = allOrders.filter(o => ['pending', 'confirmed', 'preparing'].includes(o.status));
      const completedToday = todayOrders.filter(o => o.status === 'delivered');
      const todaySales = completedToday.reduce((s, o) => s + (o.total || 0), 0);

      setKpis([
        { title: 'Today\'s Sales', value: `NPR ${todaySales.toLocaleString()}`, icon: '💰' },
        { title: 'Pending Orders', value: String(pendingOrders.length), icon: '⏳', actionRequire: pendingOrders.length > 0 },
        { title: 'Completed Today', value: String(completedToday.length), icon: '✅' },
        { title: 'Total Orders', value: String(allOrders.length), icon: '📦' }
      ]);
    } catch (err) {
      console.error('Failed to fetch dashboard data:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleAccept = async (orderId) => {
    try {
      await updateOrder(orderId, { status: 'confirmed' });
      fetchData();
    } catch (err) {
      alert(err.response?.data?.message || 'Failed to accept order');
    }
  };

  const recentOrders = orders
    .filter(o => ['pending', 'confirmed', 'preparing'].includes(o.status))
    .slice(0, 10);

  const statusBadge = (status) => {
    const map = { pending: 'badge-danger', confirmed: 'badge-info', preparing: 'badge-warning', picked: 'badge-info', delivered: 'badge-success' };
    return map[status] || 'badge-info';
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1400px', margin: '0 auto' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Store Overview</h1>
          <p className="text-secondary">Your daily summary at a glance.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px', alignItems: 'center' }}>
          <Link to="/products/add"><button className="btn btn-primary">+ Add Product</button></Link>
        </div>
      </div>

      {/* KPI Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(280px, 1fr))', gap: '24px', marginBottom: '40px' }}>
        {kpis.map((kpi, idx) => (
          <div key={idx} className="card" style={{ borderLeft: kpi.actionRequire ? '4px solid var(--warning)' : '4px solid var(--primary)', padding: '24px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '600' }}>{kpi.title}</span>
              <span style={{ fontSize: '1.3rem' }}>{kpi.icon}</span>
            </div>
            <div style={{ fontSize: '2rem', fontWeight: '800', color: 'var(--text-primary)' }}>{kpi.value}</div>
          </div>
        ))}
      </div>

      {/* Main Content */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
        <div className="card" style={{ minHeight: '400px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
            <h3 style={{ fontSize: '1.2rem', margin: 0 }}>Active Orders</h3>
            <Link to="/orders" style={{ color: 'var(--primary)', fontWeight: '600', textDecoration: 'none', fontSize: '0.9rem' }}>View All →</Link>
          </div>

          {loading ? (
            <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>Loading...</div>
          ) : recentOrders.length === 0 ? (
            <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
              <div style={{ fontSize: '2rem', marginBottom: '8px' }}>☕</div>
              No active orders right now
            </div>
          ) : (
            <table className="data-table">
              <thead>
                <tr><th>Order</th><th>Items</th><th>Total</th><th>Status</th><th>Action</th></tr>
              </thead>
              <tbody>
                {recentOrders.map(order => (
                  <tr key={order._id}>
                    <td style={{ fontWeight: '600' }}>#{order._id?.slice(-6).toUpperCase()}</td>
                    <td>{order.items?.length || 0} items</td>
                    <td style={{ fontWeight: '600' }}>NPR {order.total || 0}</td>
                    <td><span className={`badge ${statusBadge(order.status)}`} style={{ textTransform: 'capitalize' }}>{(order.status || '').replace(/_/g, ' ')}</span></td>
                    <td>
                      {order.status === 'pending' ? (
                        <button className="btn btn-success" style={{ padding: '4px 12px', fontSize: '0.8rem' }} onClick={() => handleAccept(order._id)}>Accept</button>
                      ) : (
                        <Link to={`/orders/${order._id}`}><button className="btn btn-outline" style={{ padding: '4px 12px', fontSize: '0.8rem' }}>View</button></Link>
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
          <div className="card">
            <h3 style={{ fontSize: '1.1rem', marginBottom: '20px' }}>Quick Actions</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              <Link to="/inventory"><button className="btn btn-outline" style={{ width: '100%', justifyContent: 'flex-start' }}>📦 Update Stock</button></Link>
              <Link to="/analytics"><button className="btn btn-outline" style={{ width: '100%', justifyContent: 'flex-start' }}>📊 View Analytics</button></Link>
              <Link to="/profile"><button className="btn btn-outline" style={{ width: '100%', justifyContent: 'flex-start' }}>🏪 Store Settings</button></Link>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
