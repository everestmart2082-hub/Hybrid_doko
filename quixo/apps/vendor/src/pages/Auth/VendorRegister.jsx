import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const VendorRegister = () => {
  const [formData, setFormData] = useState({ name: '', email: '', phone: '', password: '' });
  const navigate = useNavigate();

  const handleRegister = (e) => {
    e.preventDefault();
    console.log("Registering newly...", formData);
    // After registration, vendors need to set up their store
    navigate('/store-setup');
  };

  return (
    <div style={styles.container}>

      {/* Left Panel - Branding */}
      <div style={styles.leftPanel}>
        <div className="animate-fade-in" style={{ maxWidth: '400px', textAlign: 'center' }}>
          <div style={styles.brandBadge}>DOKO PARTNERS</div>
          <h1 style={{ fontSize: '3rem', color: 'white', marginBottom: '20px', lineHeight: '1.2' }}>
            Reach More Customers
          </h1>
          <p style={{ color: 'rgba(255,255,255,0.9)', fontSize: '1.1rem' }}>
            Join Doko's growing 15-minute delivery network and expand your business today.
          </p>

          <div style={{ marginTop: '50px', textAlign: 'left', backgroundColor: 'rgba(255,255,255,0.1)', padding: '24px', borderRadius: 'var(--radius-md)', border: '1px solid rgba(255,255,255,0.2)' }}>
            <p style={{ color: 'white', fontWeight: '600', marginBottom: '12px' }}>Why partner with Doko?</p>
            <ul style={{ color: 'rgba(255,255,255,0.85)', paddingLeft: '20px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <li>Access to thousands of local customers</li>
              <li>Dedicated delivery fleet handled by us</li>
              <li>Real-time sales & inventory analytics</li>
              <li>Weekly guaranteed payouts</li>
            </ul>
          </div>
        </div>
      </div>

      {/* Right Panel - Form */}
      <div style={styles.rightPanel}>
        <div className="card animate-fade-in" style={styles.loginCard}>
          <div style={{ textAlign: 'center', marginBottom: '40px' }}>
            <h2 style={{ fontSize: '2rem', marginBottom: '8px' }}>Create Partner Account</h2>
            <p className="text-secondary">It only takes a minute to get started</p>
          </div>

          <form onSubmit={handleRegister}>
            <div className="form-group">
              <label className="form-label">Full Name</label>
              <input
                type="text"
                className="form-input"
                placeholder="John Doe"
                value={formData.name}
                onChange={e => setFormData({ ...formData, name: e.target.value })}
                required
              />
            </div>

            <div className="form-group">
              <label className="form-label">Email Address (Optional)</label>
              <input
                type="email"
                className="form-input"
                placeholder="john@example.com"
                value={formData.email}
                onChange={e => setFormData({ ...formData, email: e.target.value })}
              />
            </div>

            <div className="form-group">
              <label className="form-label">Mobile Number</label>
              <div style={{ display: 'flex', gap: '8px' }}>
                <span style={styles.countryCode}>+977</span>
                <input
                  type="tel"
                  className="form-input"
                  placeholder="9800000000"
                  value={formData.phone}
                  onChange={e => setFormData({ ...formData, phone: e.target.value })}
                  required
                />
              </div>
            </div>

            <div className="form-group" style={{ marginBottom: '30px' }}>
              <label className="form-label">Create Password</label>
              <input
                type="password"
                className="form-input"
                placeholder="••••••••"
                value={formData.password}
                onChange={e => setFormData({ ...formData, password: e.target.value })}
                required
              />
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }}>
              Create Account
            </button>
          </form>

          <div style={{ marginTop: '30px', textAlign: 'center', color: 'var(--text-secondary)' }}>
            Already have an account? <Link to="/login" style={{ color: 'var(--primary)', fontWeight: '600' }}>Log In</Link>
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
    backgroundColor: 'var(--primary)',
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

export default VendorRegister;
