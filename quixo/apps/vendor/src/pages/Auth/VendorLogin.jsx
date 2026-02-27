import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const VendorLogin = () => {
  const [credentials, setCredentials] = useState({ phone: '', password: '' });
  const navigate = useNavigate();

  const handleLogin = (e) => {
    e.preventDefault();
    console.log("Vendor Logging in...", credentials);
    navigate('/');
  };

  return (
    <div style={styles.container}>

      {/* Left Panel - Branding */}
      <div style={styles.leftPanel}>
        <div className="animate-fade-in" style={{ maxWidth: '400px', textAlign: 'center' }}>
          <div style={styles.brandBadge}>DOKO PARTNERS</div>
          <h1 style={{ fontSize: '3rem', color: 'white', marginBottom: '20px', lineHeight: '1.2' }}>
            Grow Your Business With Us
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.9)', fontSize: '1.1rem' }}>
            Access your vendor dashboard to manage products, track orders, and view earnings.
          </p>

          <div style={styles.featureGrid}>
            <div style={styles.featureItem}>
              <span style={{ fontSize: '2rem' }}>📈</span>
              <span style={{ color: 'white', fontWeight: '600', marginTop: '8px' }}>Sales</span>
            </div>
            <div style={styles.featureItem}>
              <span style={{ fontSize: '2rem' }}>📦</span>
              <span style={{ color: 'white', fontWeight: '600', marginTop: '8px' }}>Orders</span>
            </div>
            <div style={styles.featureItem}>
              <span style={{ fontSize: '2rem' }}>💰</span>
              <span style={{ color: 'white', fontWeight: '600', marginTop: '8px' }}>Payouts</span>
            </div>
          </div>
        </div>
      </div>

      {/* Right Panel - Form */}
      <div style={styles.rightPanel}>
        <div className="card animate-fade-in" style={styles.loginCard}>
          <div style={{ textAlign: 'center', marginBottom: '40px' }}>
            <h2 style={{ fontSize: '2rem', marginBottom: '8px' }}>Store Login</h2>
            <p className="text-secondary">Welcome back to your partner dashboard</p>
          </div>

          <form onSubmit={handleLogin}>
            <div className="form-group">
              <label className="form-label">Registered Phone Number</label>
              <div style={{ display: 'flex', gap: '8px' }}>
                <span style={styles.countryCode}>+977</span>
                <input
                  type="tel"
                  className="form-input"
                  placeholder="9800000000"
                  value={credentials.phone}
                  onChange={e => setCredentials({ ...credentials, phone: e.target.value })}
                  required
                />
              </div>
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

          <div style={{ marginTop: '30px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            Are you a new store owner? <Link to="/register" style={{ color: 'var(--primary)', fontWeight: '600' }}>Apply Now</Link>
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
    backgroundColor: 'rgba(255,255,255,0.2)',
    color: 'white',
    padding: '8px 24px',
    borderRadius: '100px',
    fontWeight: '800',
    letterSpacing: '2px',
    fontSize: '1rem',
    marginBottom: '30px',
    border: '1px solid rgba(255,255,255,0.3)'
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
    opacity: 0.95
  },
  loginCard: {
    width: '100%',
    maxWidth: '480px',
    padding: '48px 40px',
    border: 'none',
    boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)'
  },
  countryCode: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '0 16px',
    backgroundColor: '#f1f5f9',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius-sm)',
    fontWeight: '600',
    color: 'var(--text-secondary)'
  }
};

export default VendorLogin;
