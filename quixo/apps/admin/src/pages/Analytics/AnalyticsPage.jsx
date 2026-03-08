import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE = '/api';

const AnalyticsPage = () => {
  const [vendors, setVendors] = useState([]);
  const [riders, setRiders] = useState([]);
  const [users, setUsers] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([
      axios.get(`${API_BASE}/vender/all`).catch(() => ({ data: { message: [] } })),
      axios.get(`${API_BASE}/rider/all`).catch(() => ({ data: { message: [] } })),
      axios.get(`${API_BASE}/user/all`).catch(() => ({ data: { message: [] } })),
      axios.get(`${API_BASE}/product/all`).catch(() => ({ data: { message: [] } })),
    ]).then(([vRes, rRes, uRes, pRes]) => {
      setVendors(vRes.data.message || []);
      setRiders(rRes.data.message || []);
      setUsers(uRes.data.message || []);
      setProducts(pRes.data.message || []);
    }).finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 40px', textAlign: 'center' }}>
        <div style={{ fontSize: '2rem', marginBottom: '16px' }}>📊</div>
        <p>Loading analytics...</p>
      </div>
    );
  }

  const verifiedVendors = vendors.filter(v => v.verified).length;
  const suspendedVendors = vendors.filter(v => v.suspended).length;
  const verifiedRiders = riders.filter(r => r.verified).length;
  const suspendedUsers = users.filter(u => u.suspend).length;
  const approvedProducts = products.filter(p => p.approved).length;

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ marginBottom: '40px' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Platform Analytics</h1>
        <p className="text-secondary">Real-time insights from live data.</p>
      </div>

      {/* KPI Summary */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))', gap: '20px', marginBottom: '30px' }}>
        {[
          { label: 'Total Vendors', value: vendors.length, icon: '🏪' },
          { label: 'Total Riders', value: riders.length, icon: '🛵' },
          { label: 'Total Users', value: users.length, icon: '👥' },
          { label: 'Total Products', value: products.length, icon: '🏷️' },
          { label: 'Approved Products', value: approvedProducts, icon: '✅' },
        ].map((k, i) => (
          <div key={i} className="card" style={{ textAlign: 'center', padding: '20px' }}>
            <div style={{ fontSize: '1.5rem', marginBottom: '8px' }}>{k.icon}</div>
            <div style={{ fontSize: '1.6rem', fontWeight: '800' }}>{k.value}</div>
            <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginTop: '4px' }}>{k.label}</div>
          </div>
        ))}
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px', marginBottom: '30px' }}>
        {/* Vendor Stats */}
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Vendor Breakdown</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { label: 'Verified', value: verifiedVendors, pct: vendors.length ? ((verifiedVendors / vendors.length) * 100).toFixed(0) : 0, color: '#10b981' },
              { label: 'Pending', value: vendors.length - verifiedVendors - suspendedVendors, pct: vendors.length ? (((vendors.length - verifiedVendors - suspendedVendors) / vendors.length) * 100).toFixed(0) : 0, color: '#f59e0b' },
              { label: 'Suspended', value: suspendedVendors, pct: vendors.length ? ((suspendedVendors / vendors.length) * 100).toFixed(0) : 0, color: '#ef4444' },
            ].map((stat, i) => (
              <div key={i}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                  <span style={{ fontWeight: '500' }}>{stat.label}</span>
                  <span style={{ fontWeight: '600' }}>{stat.value} ({stat.pct}%)</span>
                </div>
                <div style={{ height: '8px', backgroundColor: '#f1f5f9', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ height: '100%', width: `${stat.pct}%`, backgroundColor: stat.color, borderRadius: '4px', transition: 'width 0.5s' }}></div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Rider Stats */}
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Rider Breakdown</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {[
              { label: 'Verified', value: verifiedRiders, pct: riders.length ? ((verifiedRiders / riders.length) * 100).toFixed(0) : 0, color: '#10b981' },
              { label: 'Pending', value: riders.length - verifiedRiders, pct: riders.length ? (((riders.length - verifiedRiders) / riders.length) * 100).toFixed(0) : 0, color: '#f59e0b' },
            ].map((stat, i) => (
              <div key={i}>
                <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '4px' }}>
                  <span style={{ fontWeight: '500' }}>{stat.label}</span>
                  <span style={{ fontWeight: '600' }}>{stat.value} ({stat.pct}%)</span>
                </div>
                <div style={{ height: '8px', backgroundColor: '#f1f5f9', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ height: '100%', width: `${stat.pct}%`, backgroundColor: stat.color, borderRadius: '4px', transition: 'width 0.5s' }}></div>
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Product Category Breakdown */}
      <div className="card">
        <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Product Delivery Category</h3>
        <div style={{ display: 'flex', gap: '20px' }}>
          {['quick', 'ecommerce'].map(cat => {
            const count = products.filter(p => p.deliveryCategory === cat).length;
            return (
              <div key={cat} className="card" style={{ flex: 1, textAlign: 'center', padding: '30px', backgroundColor: '#f8fafc' }}>
                <div style={{ fontSize: '2.5rem', fontWeight: '800', color: 'var(--primary)' }}>{count}</div>
                <div style={{ color: 'var(--text-secondary)', fontWeight: '600', textTransform: 'capitalize', marginTop: '8px' }}>{cat}</div>
              </div>
            );
          })}
          <div className="card" style={{ flex: 1, textAlign: 'center', padding: '30px', backgroundColor: '#f8fafc' }}>
            <div style={{ fontSize: '2.5rem', fontWeight: '800', color: 'var(--danger)' }}>{users.filter(u => u.suspend).length}</div>
            <div style={{ color: 'var(--text-secondary)', fontWeight: '600', marginTop: '8px' }}>Suspended Users</div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default AnalyticsPage;
