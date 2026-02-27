import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const RiderLogin = () => {
  const [credentials, setCredentials] = useState({ phone: '', password: '' });
  const navigate = useNavigate();

  const handleLogin = (e) => {
    e.preventDefault();
    console.log("Rider Logging in...", credentials);
    navigate('/');
  };

  return (
    <div style={styles.container} className="animate-fade-in">

      <div style={styles.header}>
        <h1 style={{ fontSize: '2.5rem', margin: 0 }}>DOKO</h1>
        <div className="badge badge-warning" style={{ alignSelf: 'flex-start', marginTop: '4px' }}>Rider Delivery App</div>
      </div>

      <div className="card" style={styles.card}>
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <div style={{ fontSize: '3rem', marginBottom: '10px' }}>🛵</div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '8px' }}>Welcome Back, Captain!</h2>
          <p className="text-secondary" style={{ fontSize: '0.9rem' }}>Log in to view your deliveries and earnings.</p>
        </div>

        <form onSubmit={handleLogin}>
          <div className="form-group">
            <label className="form-label">Phone Number</label>
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
              <label className="form-label" style={{ marginBottom: 0 }}>Password / OTP</label>
              <a href="#" style={{ color: 'var(--primary)', fontSize: '0.85rem', textDecoration: 'none', fontWeight: '600' }}>Forgot?</a>
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
            Go Online
          </button>
        </form>

        <div style={{ marginTop: '30px', textAlign: 'center', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
          Want to ride with Doko? <Link to="/register" style={{ color: 'var(--primary)', fontWeight: '700' }}>Sign up as a Rider</Link>
        </div>
      </div>

    </div>
  );
};

const styles = {
  container: {
    minHeight: '100vh',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center',
    padding: '20px',
    backgroundColor: 'var(--primary)',
    backgroundImage: 'linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%)'
  },
  header: {
    color: 'white',
    width: '100%',
    maxWidth: '400px',
    margin: '0 auto 30px auto',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    textAlign: 'center'
  },
  card: {
    width: '100%',
    maxWidth: '400px',
    margin: '0 auto',
    padding: '30px 24px',
    borderRadius: 'var(--radius-lg)'
  },
  countryCode: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '0 12px',
    backgroundColor: '#f1f5f9',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius-sm)',
    fontWeight: '600',
    color: 'var(--text-secondary)',
    fontSize: '0.9rem'
  }
};

export default RiderLogin;
