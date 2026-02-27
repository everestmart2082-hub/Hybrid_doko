import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({
  baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://localhost:5000/api/admin',
});
API.interceptors.request.use((config) => {
  const token = localStorage.getItem('adminToken');
  if (token) config.headers.Authorization = `Bearer ${token}`;
  return config;
});

const AdminDashboard = () => {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    API.get('/analytics/dashboard').then(res => {
      setStats(res.data.data);
    }).catch(err => console.error('Dashboard fetch failed:', err))
      .finally(() => setLoading(false));
  }, []);

  const kpis = stats ? [
    { title: 'Total Revenue', value: `NPR ${(stats.totalRevenue || 0).toLocaleString()}`, icon: '💰' },
    { title: 'Total Orders', value: String(stats.totalOrders || 0), icon: '📦' },
    { title: 'Registered Vendors', value: String(stats.totalVendors || 0), icon: '🏪' },
    { title: 'Total Users', value: String(stats.totalUsers || 0), icon: '👥' },
    { title: 'Total Products', value: String(stats.totalProducts || 0), icon: '🏷️' },
  ] : [];

  return (
    <div className="container animate-fade-in" style={styles.page}>
      <div style={styles.header}>
        <div>
          <h1 style={styles.pageTitle}>Dashboard Overview</h1>
          <p style={{ color: 'var(--text-secondary)' }}>Welcome back, Admin. Here's what's happening today.</p>
        </div>
        <div style={styles.headerActions}>
          <Link to="/analytics"><button className="btn btn-outline">View Analytics</button></Link>
        </div>
      </div>

      {/* KPI Cards */}
      <div style={styles.kpiGrid}>
        {loading ? (
          [1, 2, 3, 4, 5].map(i => (
            <div key={i} className="card" style={{ ...styles.kpiCard(false), opacity: 0.5 }}>
              <div style={{ height: '80px', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-secondary)' }}>Loading...</div>
            </div>
          ))
        ) : (
          kpis.map((kpi, idx) => (
            <div key={idx} className="card" style={styles.kpiCard(false)}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '600' }}>{kpi.title}</span>
                <span style={{ fontSize: '1.5rem' }}>{kpi.icon}</span>
              </div>
              <div style={{ fontSize: '2rem', fontWeight: '800', color: 'var(--text-primary)' }}>{kpi.value}</div>
            </div>
          ))
        )}
      </div>

      {/* Main Content Area */}
      <div style={styles.mainGrid}>
        {/* Quick Links */}
        <div className="card" style={styles.chartSection}>
          <h3 style={{ fontSize: '1.2rem', marginBottom: '24px' }}>Quick Actions</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            {[
              { label: 'Vendor Approvals', to: '/approvals/vendors', icon: '✅', color: '#10b981' },
              { label: 'Rider Approvals', to: '/approvals/riders', icon: '🛵', color: '#3b82f6' },
              { label: 'Product Review', to: '/products/approval', icon: '🏷️', color: '#f59e0b' },
              { label: 'Order Management', to: '/orders', icon: '📋', color: '#8b5cf6' },
              { label: 'Analytics', to: '/analytics', icon: '📊', color: '#ef4444' },
              { label: 'Categories', to: '/categories', icon: '📁', color: '#06b6d4' },
            ].map(item => (
              <Link key={item.to} to={item.to} style={{ textDecoration: 'none' }}>
                <div style={{ padding: '20px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-md)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '14px', cursor: 'pointer', transition: 'var(--transition)' }}>
                  <div style={{ width: '44px', height: '44px', borderRadius: '12px', backgroundColor: `${item.color}15`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.3rem' }}>{item.icon}</div>
                  <span style={{ fontWeight: '600', color: 'var(--text-primary)' }}>{item.label}</span>
                </div>
              </Link>
            ))}
          </div>
        </div>

        {/* Right Column: Links */}
        <div style={styles.sideGrid}>
          <div className="card" style={{ padding: '0' }}>
            <div style={{ padding: '20px', borderBottom: '1px solid var(--border)', display: 'flex', justifyContent: 'space-between' }}>
              <h3 style={{ fontSize: '1.1rem', margin: 0 }}>Pending Approvals</h3>
              <span className="badge badge-warning">Action Required</span>
            </div>
            <div style={{ padding: '20px', display: 'flex', flexDirection: 'column', gap: '12px' }}>
              {[
                { label: 'Vendors', to: '/approvals/vendors' },
                { label: 'Riders', to: '/approvals/riders' },
                { label: 'Products', to: '/products/approval' },
              ].map(item => (
                <div key={item.to} style={styles.approvalRow}>
                  <span style={{ fontWeight: '500' }}>{item.label}</span>
                  <Link to={item.to} className="btn btn-outline" style={{ padding: '4px 12px', fontSize: '0.85rem' }}>Review</Link>
                </div>
              ))}
            </div>
          </div>

          <div className="card">
            <h3 style={{ fontSize: '1.1rem', marginBottom: '16px' }}>Management</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {[
                { label: 'All Vendors', to: '/vendors' },
                { label: 'All Riders', to: '/riders' },
                { label: 'All Clients', to: '/clients' },
                { label: 'All Products', to: '/products' },
                { label: 'Employees', to: '/employees' },
              ].map(item => (
                <Link key={item.to} to={item.to} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '10px 14px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-sm)', textDecoration: 'none', color: 'var(--text-primary)', fontWeight: '500' }}>
                  <span>{item.label}</span>
                  <span style={{ color: 'var(--text-secondary)' }}>→</span>
                </Link>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const styles = {
  page: { padding: '40px', maxWidth: '1400px', margin: '0 auto' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' },
  pageTitle: { fontSize: '2rem', marginBottom: '8px' },
  headerActions: { display: 'flex', gap: '16px' },
  kpiGrid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '24px', marginBottom: '40px' },
  kpiCard: (isWarning) => ({ borderLeft: isWarning ? '4px solid var(--danger)' : '4px solid var(--primary)', padding: '24px' }),
  mainGrid: { display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' },
  chartSection: { minHeight: '400px' },
  sideGrid: { display: 'flex', flexDirection: 'column', gap: '24px' },
  approvalRow: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '12px', backgroundColor: 'var(--bg-color)', borderRadius: 'var(--radius-sm)' },
};

export default AdminDashboard;
