import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({
    baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://127.0.0.1:5000/api/admin',
});
API.interceptors.request.use((config) => {
    const token = localStorage.getItem('adminToken');
    if (token) config.headers.Authorization = `Bearer ${token}`;
    return config;
});

const B2BDashboard = () => {
    const [stats, setStats] = useState(null);
    const [recentOrders, setRecentOrders] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        Promise.allSettled([
            API.get('/b2b/dashboard'),
            API.get('/b2b/orders'),
        ]).then(([dashRes, ordersRes]) => {
            if (dashRes.status === 'fulfilled') setStats(dashRes.value.data.data);
            if (ordersRes.status === 'fulfilled') setRecentOrders((ordersRes.value.data.data || []).slice(0, 5));
        }).finally(() => setLoading(false));
    }, []);

    const statusColors = { pending: '#f59e0b', negotiating: '#8b5cf6', approved: '#3b82f6', rejected: '#ef4444', processing: '#06b6d4', shipped: '#ec4899', delivered: '#10b981', cancelled: '#94a3b8' };

    if (loading) return <div className="container" style={{ padding: '80px', textAlign: 'center' }}>Loading B2B Dashboard...</div>;

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1400px', margin: '0 auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '40px' }}>
                <div>
                    <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>🏭 B2B Supply Chain</h1>
                    <p style={{ color: 'var(--text-secondary)' }}>Manage manufacturers, wholesale catalog, and vendor bulk orders</p>
                </div>
                <div style={{ display: 'flex', gap: '12px' }}>
                    <Link to="/b2b/manufacturers"><button className="btn btn-outline">Manufacturers</button></Link>
                    <Link to="/b2b/products"><button className="btn btn-outline">Catalog</button></Link>
                    <Link to="/b2b/orders"><button className="btn btn-primary">B2B Orders</button></Link>
                </div>
            </div>

            {/* KPIs */}
            {stats && (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))', gap: '20px', marginBottom: '40px' }}>
                    {[
                        { label: 'Manufacturers', value: stats.totalManufacturers, icon: '🏭', color: 'var(--primary)' },
                        { label: 'Catalog Products', value: stats.totalProducts, icon: '📦', color: '#3b82f6' },
                        { label: 'Total B2B Orders', value: stats.totalOrders, icon: '📋', color: '#8b5cf6' },
                        { label: 'Pending / Negotiating', value: stats.pendingOrders, icon: '⏳', color: '#f59e0b', highlight: stats.pendingOrders > 0 },
                        { label: 'B2B Revenue', value: `NPR ${(stats.totalRevenue || 0).toLocaleString()}`, icon: '💰', color: '#10b981' },
                        { label: 'Platform Fees', value: `NPR ${(stats.platformFees || 0).toLocaleString()}`, icon: '💎', color: '#ec4899' },
                    ].map((kpi, i) => (
                        <div key={i} className="card" style={{ borderLeft: `4px solid ${kpi.color}`, padding: '20px' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                                <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', fontWeight: '600' }}>{kpi.label}</span>
                                <span>{kpi.icon}</span>
                            </div>
                            <div style={{ fontSize: '1.8rem', fontWeight: '800' }}>{kpi.value}</div>
                        </div>
                    ))}
                </div>
            )}

            {/* Quick Actions */}
            <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
                <div className="card">
                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
                        <h3 style={{ fontSize: '1.2rem', margin: 0 }}>Recent B2B Orders</h3>
                        <Link to="/b2b/orders" style={{ color: 'var(--primary)', fontWeight: '600', textDecoration: 'none' }}>View All →</Link>
                    </div>
                    {recentOrders.length === 0 ? (
                        <div style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No B2B orders yet</div>
                    ) : (
                        <table className="data-table">
                            <thead><tr><th>Order</th><th>Vendor</th><th>Total</th><th>Status</th></tr></thead>
                            <tbody>
                                {recentOrders.map(order => (
                                    <tr key={order._id}>
                                        <td style={{ fontWeight: '600' }}>#{order._id?.slice(-6).toUpperCase()}</td>
                                        <td>{order.vendorId?.storeName || 'Vendor'}</td>
                                        <td style={{ fontWeight: '600' }}>NPR {(order.total || 0).toLocaleString()}</td>
                                        <td>
                                            <span style={{ padding: '4px 10px', borderRadius: '100px', fontSize: '0.8rem', fontWeight: '600', backgroundColor: `${statusColors[order.status] || '#94a3b8'}20`, color: statusColors[order.status] || '#94a3b8', textTransform: 'capitalize' }}>
                                                {order.status}
                                            </span>
                                        </td>
                                    </tr>
                                ))}
                            </tbody>
                        </table>
                    )}
                </div>

                <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
                    <div className="card" style={{ backgroundColor: '#fef3c7', borderColor: '#fde68a' }}>
                        <h3 style={{ fontSize: '1.1rem', color: '#92400e', marginBottom: '12px' }}>💡 How B2B Works</h3>
                        <ol style={{ paddingLeft: '16px', fontSize: '0.85rem', color: '#78350f', lineHeight: '1.8' }}>
                            <li>Admin adds manufacturers & their catalog</li>
                            <li>Vendors browse catalog & place bulk orders</li>
                            <li>Admin reviews, negotiates pricing if needed</li>
                            <li>Doko procures from manufacturer</li>
                            <li>Doko ships to vendor, earns margin + 5% fee</li>
                        </ol>
                    </div>
                    <Link to="/b2b/manufacturers" style={{ textDecoration: 'none' }}>
                        <div className="card" style={{ textAlign: 'center', cursor: 'pointer' }}>
                            <div style={{ fontSize: '2rem', marginBottom: '8px' }}>🏭</div>
                            <div style={{ fontWeight: '700' }}>+ Add Manufacturer</div>
                        </div>
                    </Link>
                </div>
            </div>
        </div>
    );
};

export default B2BDashboard;
