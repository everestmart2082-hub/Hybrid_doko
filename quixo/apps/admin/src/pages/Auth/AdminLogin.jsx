import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';

const AdminLogin = () => {
  const [credentials, setCredentials] = useState({ email: '', password: '' });
  const navigate = useNavigate();

  const handleLogin = (e) => {
    e.preventDefault();
    // Simulate successful login
    console.log("Admin Logging in...", credentials);
    navigate('/');
  };

  return (
    <div style={styles.container}>

      <div style={styles.leftPanel}>
        <div className="animate-fade-in" style={{ maxWidth: '400px', textAlign: 'center' }}>
          <div style={styles.brandBadge}>DOKO</div>
          <h1 style={{ fontSize: '3rem', color: 'white', marginBottom: '20px', lineHeight: '1.2' }}>
            System Administration
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.8)', fontSize: '1.1rem' }}>
            Centralized platform management, approvals, analytics, and operational control.
          </p>

          <div style={styles.featureGrid}>
            <div style={styles.featureItem}>
              <span style={{ fontSize: '2rem' }}>📊</span>
              <span style={{ color: 'white', fontWeight: '600', marginTop: '8px' }}>Analytics</span>
            </div>
            <div style={styles.featureItem}>
              <span style={{ fontSize: '2rem' }}>🏪</span>
              <span style={{ color: 'white', fontWeight: '600', marginTop: '8px' }}>Vendors</span>
            </div>
            <div style={styles.featureItem}>
              <span style={{ fontSize: '2rem' }}>🛵</span>
              <span style={{ color: 'white', fontWeight: '600', marginTop: '8px' }}>Riders</span>
            </div>
          </div>
        </div>
      </div>

      <div style={styles.rightPanel}>
        <div className="card animate-fade-in" style={styles.loginCard}>
          <div style={{ textAlign: 'center', marginBottom: '40px' }}>
            <h2 style={{ fontSize: '2rem', marginBottom: '8px' }}>Admin Login</h2>
            <p className="text-secondary">Sign in with your authorized credentials</p>
          </div>

          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label className="form-label">Admin Email Address</label>
              <input
                type="email"
                className="form-input"
                placeholder="admin@doko.com"
                value={credentials.email}
                onChange={e => setCredentials({ ...credentials, email: e.target.value })}
                required
              />
            </div>
            <div className="form-group" style={{ marginBottom: '30px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '8px' }}>
                <label className="form-label" style={{ marginBottom: 0 }}>Password</label>
                <a href="#" style={{ color: 'var(--primary)', fontSize: '0.9rem', textDecoration: 'none', fontWeight: '600' }}>Forgot password?</a>
              </div>
              <input
                type="password"
                className="form-input"
                placeholder="••••••••"
                value={credentials.password}
                onChange={e => setCredentials({ ...credentials, password: e.target.value })}
                required
              />
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }}>
              Access Dashboard
            </button>
          </form>

          <div style={{ marginTop: '30px', textAlign: 'center', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
            Restricted System. Unauthorized access is strictly prohibited.
          </div>
        </div>
      </div>

    </div>
  );
};

const styles = {
  container: {
    display: 'flex',
    minHeight: '100vh',
    backgroundColor: 'var(--bg-color)'
  },
  leftPanel: {
    flex: '1',
    backgroundColor: 'var(--primary-dark)',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    alignItems: 'center',
    padding: '40px',
    position: 'relative',
    overflow: 'hidden'
  },
  rightPanel: {
    flex: '1',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    padding: '40px',
    backgroundColor: '#ffffff'
  },
  brandBadge: {
    display: 'inline-block',
    backgroundColor: 'rgba(255,255,255,0.1)',
    color: 'white',
    padding: '8px 24px',
    borderRadius: '100px',
    fontWeight: '800',
    letterSpacing: '2px',
    fontSize: '1rem',
    marginBottom: '30px',
    border: '1px solid rgba(255,255,255,0.2)'
  },
  featureGrid: {
    display: 'flex',
    justifyContent: 'center',
    gap: '40px',
    marginTop: '60px'
  },
  featureItem: {
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    opacity: 0.9
  },
  loginCard: {
    width: '100%',
    maxWidth: '480px',
    padding: '48px 40px',
    border: 'none',
    boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)'
  }
};

export default AdminLogin;
