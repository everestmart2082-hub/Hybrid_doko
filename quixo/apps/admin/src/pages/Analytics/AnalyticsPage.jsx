import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://localhost:5000/api/admin',
});
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

const AnalyticsPage = () => {
  const [dashboard, setDashboard] = useState(null);
  const [sales, setSales] = useState([]);
  const [topProducts, setTopProducts] = useState([]);
  const [vendorRevenue, setVendorRevenue] = useState([]);
  const [orderStats, setOrderStats] = useState([]);
  const [paymentStats, setPaymentStats] = useState([]);
  const [loading, setLoading] = useState(true);
  const [salesDays, setSalesDays] = useState(30);

  useEffect(() => {
    loadAll();
  }, [salesDays]);

  const loadAll = async () => {
    setLoading(true);
    try {
      const [dashRes, salesRes, topRes, vendorRes, orderRes, payRes] = await Promise.allSettled([
        API.get('/analytics/dashboard'),
        API.get(`/analytics/sales?days=${salesDays}`),
        API.get('/analytics/top-products?limit=10'),
        API.get('/analytics/vendor-revenue'),
        API.get('/analytics/order-stats'),
        API.get('/analytics/payment-stats'),
      ]);
      if (dashRes.status === 'fulfilled') setDashboard(dashRes.value.data.data);
      if (salesRes.status === 'fulfilled') setSales(salesRes.value.data.data || []);
      if (topRes.status === 'fulfilled') setTopProducts(topRes.value.data.data || []);
      if (vendorRes.status === 'fulfilled') setVendorRevenue(vendorRes.value.data.data || []);
      if (orderRes.status === 'fulfilled') setOrderStats(orderRes.value.data.data || []);
      if (payRes.status === 'fulfilled') setPaymentStats(payRes.value.data.data || []);
    } catch (err) {
      console.error('Analytics load error:', err);
    } finally {
      setLoading(false);
    }
  };

  const maxSale = Math.max(...sales.map(s => s.revenue || 0), 1);

  if (loading) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 40px', textAlign: 'center' }}>
        <div style={{ fontSize: '2rem', marginBottom: '16px' }}>📊</div>
        <p>Loading analytics...</p>
      </div>
    );
  }

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ marginBottom: '40px' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Platform Analytics</h1>
        <p className="text-secondary">In-depth insights into platform performance and user behavior.</p>
      </div>

      {/* KPI Summary */}
      {dashboard && (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '20px', marginBottom: '30px' }}>
          {[
            { label: 'Revenue', value: `NPR ${(dashboard.totalRevenue || 0).toLocaleString()}`, icon: '💰' },
            { label: 'Orders', value: dashboard.totalOrders || 0, icon: '📦' },
            { label: 'Users', value: dashboard.totalUsers || 0, icon: '👥' },
            { label: 'Vendors', value: dashboard.totalVendors || 0, icon: '🏪' },
            { label: 'Products', value: dashboard.totalProducts || 0, icon: '🏷️' },
          ].map((k, i) => (
            <div key={i} className="card" style={{ textAlign: 'center', padding: '20px' }}>
              <div style={{ fontSize: '1.5rem', marginBottom: '8px' }}>{k.icon}</div>
              <div style={{ fontSize: '1.6rem', fontWeight: '800' }}>{k.value}</div>
              <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginTop: '4px' }}>{k.label}</div>
            </div>
          ))}
        </div>
      )}

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px', marginBottom: '30px' }}>

        {/* Sales Chart (Bar Visualization) */}
        <div className="card">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>
            <h3 style={{ fontSize: '1.2rem', margin: 0 }}>Revenue Trends</h3>
            <select value={salesDays} onChange={e => setSalesDays(Number(e.target.value))} className="form-input" style={{ width: 'auto', padding: '4px 10px' }}>
              <option value={7}>7 days</option>
              <option value={14}>14 days</option>
              <option value={30}>30 days</option>
            </select>
          </div>
          {sales.length === 0 ? (
            <div style={{ height: '200px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)' }}>No sales data</div>
          ) : (
            <div style={{ display: 'flex', alignItems: 'flex-end', gap: '4px', height: '200px', padding: '0 8px' }}>
              {sales.map((day, i) => (
                <div key={i} style={{ flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'flex-end', height: '100%' }}>
                  <div style={{ width: '100%', maxWidth: '24px', backgroundColor: 'var(--primary)', borderRadius: '4px 4px 0 0', height: `${Math.max((day.revenue / maxSale) * 100, 3)}%`, transition: 'height 0.3s', opacity: 0.85 }} title={`NPR ${(day.revenue || 0).toLocaleString()}`}></div>
                  {sales.length <= 14 && <div style={{ fontSize: '0.65rem', color: 'var(--text-secondary)', marginTop: '4px', transform: 'rotate(-45deg)', whiteSpace: 'nowrap' }}>{day._id?.slice(5) || ''}</div>}
                </div>
              ))}
            </div>
          )}
          <div style={{ textAlign: 'center', marginTop: '12px', fontSize: '0.8rem', color: 'var(--text-secondary)' }}>
            Total: NPR {sales.reduce((s, d) => s + (d.revenue || 0), 0).toLocaleString()} • {sales.reduce((s, d) => s + (d.count || 0), 0)} orders
          </div>
        </div>

        {/* Order Status Distribution */}
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Order Status Distribution</h3>
          {orderStats.length === 0 ? (
            <div style={{ height: '200px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)' }}>No data</div>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {orderStats.map((stat, i) => {
                const total = orderStats.reduce((s, st) => s + st.count, 0);
                const pct = total > 0 ? ((stat.count / total) * 100).toFixed(1) : 0;
                const colors = { pending: '#f59e0b', confirmed: '#3b82f6', preparing: '#8b5cf6', picked: '#ec4899', out_for_delivery: '#06b6d4', delivered: '#10b981', cancelled: '#ef4444' };
                return (
                  <div key={i}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                      <span style={{ fontWeight: '500', textTransform: 'capitalize' }}>{(stat._id || '').replace(/_/g, ' ')}</span>
                      <span style={{ fontWeight: '600' }}>{stat.count} ({pct}%)</span>
                    </div>
                    <div style={{ height: '8px', backgroundColor: '#f1f5f9', borderRadius: '4px', overflow: 'hidden' }}>
                      <div style={{ height: '100%', width: `${pct}%`, backgroundColor: colors[stat._id] || '#94a3b8', borderRadius: '4px', transition: 'width 0.5s' }}></div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px', marginBottom: '30px' }}>
        {/* Payment Method Stats */}
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Payment Methods</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            {paymentStats.map((pm, i) => {
              const icons = { khalti: '💜', esewa: '💚', fonepay: '🔵', cashOnDelivery: '💵' };
              return (
                <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px 16px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-sm)' }}>
                  <span style={{ fontWeight: '600' }}>{icons[pm._id] || '💳'} {(pm._id || 'unknown').replace(/([A-Z])/g, ' $1')}</span>
                  <div style={{ textAlign: 'right' }}>
                    <div style={{ fontWeight: '700' }}>NPR {(pm.totalAmount || 0).toLocaleString()}</div>
                    <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{pm.count} payments</div>
                  </div>
                </div>
              );
            })}
            {paymentStats.length === 0 && <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '20px' }}>No payment data</div>}
          </div>
        </div>

        {/* Top Products */}
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Top Selling Products</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {topProducts.slice(0, 5).map((p, i) => (
              <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 14px', backgroundColor: i < 3 ? '#fefce8' : '#f8fafc', borderRadius: 'var(--radius-sm)', border: i === 0 ? '1px solid #fde68a' : 'none' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <span style={{ fontWeight: '800', color: i < 3 ? '#f59e0b' : 'var(--text-secondary)' }}>#{i + 1}</span>
                  <span style={{ fontWeight: '600' }}>{p.name || 'Product'}</span>
                </div>
                <div style={{ textAlign: 'right' }}>
                  <div style={{ fontWeight: '700', color: 'var(--success)' }}>NPR {(p.totalRevenue || 0).toLocaleString()}</div>
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{p.totalQty || 0} sold</div>
                </div>
              </div>
            ))}
            {topProducts.length === 0 && <div style={{ color: 'var(--text-secondary)', textAlign: 'center', padding: '20px' }}>No sales data yet</div>}
          </div>
        </div>
      </div>

      {/* Vendor Revenue Table */}
      <div className="card">
        <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Vendor Revenue</h3>
        <table className="data-table">
          <thead>
            <tr>
              <th>Rank</th>
              <th>Vendor</th>
              <th>Total Orders</th>
              <th>Total Revenue</th>
            </tr>
          </thead>
          <tbody>
            {vendorRevenue.slice(0, 10).map((v, i) => (
              <tr key={i}>
                <td><span className="badge" style={{ backgroundColor: i === 0 ? '#fbbf24' : i === 1 ? '#94a3b8' : i === 2 ? '#b45309' : '#e2e8f0', color: i < 3 ? '#fff' : '#333', fontWeight: '700' }}>#{i + 1}</span></td>
                <td style={{ fontWeight: '600' }}>{v.vendorName || v._id || 'Unknown'}</td>
                <td>{v.totalOrders || 0}</td>
                <td style={{ color: 'var(--success)', fontWeight: '600' }}>NPR {(v.totalRevenue || 0).toLocaleString()}</td>
              </tr>
            ))}
            {vendorRevenue.length === 0 && (
              <tr><td colSpan="4" style={{ textAlign: 'center', color: 'var(--text-secondary)' }}>No vendor data</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default AnalyticsPage;
