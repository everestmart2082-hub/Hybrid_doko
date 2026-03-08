import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { vendorAuthAPI } from '../../services/vendorApi';

const VendorRegister = () => {
  const [formData, setFormData] = useState({ name: '', phone: '', storeName: '', address: '', businessType: '', description: '' });
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleRegister = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data } = await vendorAuthAPI.register({
        name: formData.name,
        number: formData.phone,
        storeName: formData.storeName,
        address: formData.address,
        businessType: formData.businessType,
        description: formData.description
      });
      if (data.success) {
        setStep(2);
      } else {
        setError(data.message || 'Registration failed.');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Registration failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data } = await vendorAuthAPI.verifyRegistrationOtp(formData.phone, otp);
      if (data.success && data.token) {
        localStorage.setItem('vendor_token', data.token);
        navigate('/');
      } else {
        setError(data.message || 'OTP verification failed.');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'OTP verification failed.');
    } finally {
      setLoading(false);
    }
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
          <div style={{ textAlign: 'center', marginBottom: '30px' }}>
            <div style={styles.roleBadge}>🏪 Vendor Registration</div>
            <h2 style={{ fontSize: '2rem', marginBottom: '8px' }}>Create Partner Account</h2>
            <p className="text-secondary">It only takes a minute to get started</p>
          </div>

          {error && (
            <div style={{ padding: '12px 16px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', borderRadius: 'var(--radius-sm)', marginBottom: '20px', fontSize: '0.9rem' }}>
              {error}
            </div>
          )}

          {step === 1 ? (
            <form onSubmit={handleRegister}>
              <div className="form-group">
                <label className="form-label">Full Name</label>
                <input type="text" className="form-input" placeholder="John Doe" value={formData.name} onChange={e => setFormData({ ...formData, name: e.target.value })} required />
              </div>

              <div className="form-group">
                <label className="form-label">Mobile Number</label>
                <div style={{ display: 'flex', gap: '8px' }}>
                  <span style={styles.countryCode}>+977</span>
                  <input type="tel" className="form-input" placeholder="9800000000" value={formData.phone} onChange={e => setFormData({ ...formData, phone: e.target.value })} required />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Store Name</label>
                <input type="text" className="form-input" placeholder="My Store" value={formData.storeName} onChange={e => setFormData({ ...formData, storeName: e.target.value })} required />
              </div>

              <div className="form-group">
                <label className="form-label">Business Type</label>
                <input type="text" className="form-input" placeholder="e.g. Grocery, Restaurant" value={formData.businessType} onChange={e => setFormData({ ...formData, businessType: e.target.value })} />
              </div>

              <div className="form-group" style={{ marginBottom: '20px' }}>
                <label className="form-label">Address</label>
                <input type="text" className="form-input" placeholder="Store Address" value={formData.address} onChange={e => setFormData({ ...formData, address: e.target.value })} />
              </div>

              <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }} disabled={loading}>
                {loading ? 'Registering...' : 'Register & Send OTP'}
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerifyOtp}>
              <div className="form-group">
                <label className="form-label">Phone Number</label>
                <input type="tel" className="form-input" value={formData.phone} disabled style={{ backgroundColor: '#f1f5f9' }} />
              </div>

              <div className="form-group" style={{ marginBottom: '20px' }}>
                <label className="form-label">Enter OTP</label>
                <input type="text" className="form-input" placeholder="Enter 4-digit OTP" value={otp} onChange={e => setOtp(e.target.value)} maxLength={4} required autoFocus />
                <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                  For testing, use OTP: <strong>1234</strong>
                </p>
              </div>

              <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }} disabled={loading}>
                {loading ? 'Verifying...' : 'Verify & Create Account'}
              </button>

              <button type="button" onClick={() => { setStep(1); setOtp(''); setError(''); }} style={{ width: '100%', background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', fontWeight: '600', fontSize: '0.9rem', marginTop: '12px' }}>
                ← Change Details
              </button>
            </form>
          )}

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
    backgroundColor: '#ffffff',
    overflowY: 'auto'
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
  roleBadge: {
    display: 'inline-block',
    backgroundColor: '#fef3c7',
    color: '#d97706',
    padding: '6px 16px',
    borderRadius: '100px',
    fontWeight: '700',
    fontSize: '0.85rem',
    marginBottom: '16px',
    border: '1px solid #fde68a'
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
