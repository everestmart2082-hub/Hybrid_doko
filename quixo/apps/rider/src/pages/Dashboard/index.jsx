import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { riderDashboardAPI } from '../../services/riderApi';

const Dashboard = () => {
  const [isOnline, setIsOnline] = useState(false);
  const [stats, setStats] = useState({ deliveries: 0, earnings: 0 });
  const [activeOrder, setActiveOrder] = useState(null);

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const { data } = await riderDashboardAPI.get();
      if (data.success && data.message) {
        const cards = data.message.cards || {};
        setStats({
          deliveries: cards['orders deliverd'] || 0,
          earnings: cards.earnings || 0
        });
      }
    } catch (err) {
      console.error('Failed to fetch stats:', err);
    }
  };

  return (
    <div className="view-container animate-fade-in" style={{ backgroundColor: isOnline ? 'var(--primary-light)' : 'var(--bg-color)', minHeight: '100vh', transition: 'background-color 0.4s' }}>

      {/* Top Header */}
      <div style={{ padding: '20px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', backgroundColor: 'var(--surface)', boxShadow: 'var(--shadow-sm)', position: 'sticky', top: 0, zIndex: 10 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '40px', height: '40px', borderRadius: '50%', backgroundColor: '#e2e8f0', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '1.2rem' }}>🛵</div>
          <div>
            <h2 style={{ fontSize: '1.1rem', margin: 0 }}>Doko Rider</h2>
            <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', margin: 0 }}>Vehicle: Motorbike 🏍️</p>
          </div>
        </div>
        <div style={{ textAlign: 'right' }}>
          <div style={{ fontSize: '0.8rem', fontWeight: 'bold', color: isOnline ? 'var(--success)' : 'var(--text-secondary)' }}>
            {isOnline ? 'ONLINE' : 'OFFLINE'}
          </div>
        </div>
      </div>

      <div className="container" style={{ paddingTop: '24px' }}>
        {/* Go Online Toggle */}
        <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '30px' }}>
          <button
            onClick={() => setIsOnline(!isOnline)}
            style={{
              width: '180px', height: '180px', borderRadius: '50%',
              border: isOnline ? '8px solid var(--success)' : '8px solid var(--border)',
              backgroundColor: 'var(--surface)', display: 'flex', flexDirection: 'column',
              alignItems: 'center', justifyContent: 'center',
              boxShadow: isOnline ? '0 0 30px rgba(34, 197, 94, 0.3)' : 'var(--shadow-md)',
              transition: 'all 0.3s', cursor: 'pointer'
            }}
          >
            <span style={{ fontSize: '2.5rem', marginBottom: '8px' }}>{isOnline ? '📡' : '😴'}</span>
            <span style={{ fontSize: '1.2rem', fontWeight: '800', color: isOnline ? 'var(--success)' : 'var(--text-secondary)' }}>
              {isOnline ? 'YOU ARE ONLINE' : 'GO ONLINE'}
            </span>
          </button>
        </div>

        {/* Status Message */}
        <div style={{ textAlign: 'center', marginBottom: '30px', padding: '0 20px' }}>
          <h3 style={{ fontSize: '1.2rem', color: 'var(--text-primary)' }}>
            {isOnline ? 'Searching for nearby orders...' : 'You are currently offline.'}
          </h3>
          <p style={{ fontSize: '0.9rem', color: 'var(--text-secondary)', marginTop: '8px' }}>
            {isOnline ? 'Stay in high-demand zones to receive orders faster.' : 'Go online to start receiving delivery requests and earning.'}
          </p>
        </div>

        {/* Active Order Card */}
        {activeOrder && (
          <Link to={`/orders/${activeOrder._id}`} style={{ textDecoration: 'none' }}>
            <div className="card" style={{ marginBottom: '24px', borderLeft: '4px solid var(--primary)', animation: 'pulse 2s infinite' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                <h3 style={{ fontSize: '1.1rem', margin: 0, color: 'var(--primary)' }}>🔔 Active Delivery</h3>
                <span style={{ padding: '4px 10px', borderRadius: '100px', fontSize: '0.75rem', fontWeight: '600', backgroundColor: '#ecfdf5', color: 'var(--primary-dark)', textTransform: 'capitalize' }}>
                  {(activeOrder.status || '').replace(/_/g, ' ')}
                </span>
              </div>
              <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
                Order #{activeOrder._id?.slice(-6).toUpperCase()} • NPR {activeOrder.total || 0}
              </p>
              <p style={{ color: 'var(--primary)', fontWeight: '600', fontSize: '0.85rem', marginTop: '8px' }}>Tap to view details →</p>
            </div>
          </Link>
        )}

        {/* Today's Summary */}
        <div className="card" style={{ marginBottom: '24px' }}>
          <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Today's Summary</h3>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', fontWeight: '600' }}>Deliveries</span>
              <div style={{ fontSize: '1.5rem', fontWeight: '800' }}>{stats.deliveries}</div>
            </div>
            <div>
              <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', fontWeight: '600' }}>Earnings</span>
              <div style={{ fontSize: '1.5rem', fontWeight: '800', color: 'var(--primary-dark)' }}>NPR {stats.earnings}</div>
            </div>
          </div>
        </div>

        {/* Navigation Quick Links */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', marginBottom: '20px', paddingBottom: '80px' }}>
          <Link to="/orders/available" style={{ textDecoration: 'none' }}>
            <div className="card" style={{ padding: '16px', textAlign: 'center', backgroundColor: 'var(--primary)', color: 'white', border: 'none' }}>
              <div style={{ fontSize: '1.5rem', marginBottom: '4px' }}>📦</div>
              <div style={{ fontWeight: 'bold' }}>Find Orders</div>
            </div>
          </Link>
          <Link to="/earnings" style={{ textDecoration: 'none' }}>
            <div className="card" style={{ padding: '16px', textAlign: 'center' }}>
              <div style={{ fontSize: '1.5rem', marginBottom: '4px' }}>💰</div>
              <div style={{ fontWeight: 'bold', color: 'var(--text-primary)' }}>Earnings</div>
            </div>
          </Link>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
