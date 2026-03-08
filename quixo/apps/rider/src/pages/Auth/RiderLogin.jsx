import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { riderAuthAPI } from '../../services/riderApi';

const RiderLogin = () => {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState(1);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSendOtp = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data } = await riderAuthAPI.login(phone);
      if (data.success) {
        setStep(2);
      } else {
        setError(data.message || 'Login failed. Phone number not found.');
      }
    } catch (err) {
      setError(err.response?.data?.message || 'Login failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const { data } = await riderAuthAPI.verifyLoginOtp(phone, otp);
      if (data.success && data.token) {
        localStorage.setItem('rider_token', data.token);
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
    <div style={styles.container} className="animate-fade-in">

      <div style={styles.header}>
        <h1 style={{ fontSize: '2.5rem', margin: 0 }}>DOKO</h1>
        <div className="badge badge-warning" style={{ alignSelf: 'flex-start', marginTop: '4px' }}>Rider Delivery App</div>
      </div>

      <div className="card" style={styles.card}>
        <div style={{ textAlign: 'center', marginBottom: '30px' }}>
          <div style={{ fontSize: '3rem', marginBottom: '10px' }}>🛵</div>
          <div style={styles.roleBadge}>🛵 Rider Login</div>
          <h2 style={{ fontSize: '1.5rem', marginBottom: '8px' }}>Welcome Back, Captain!</h2>
          <p className="text-secondary" style={{ fontSize: '0.9rem' }}>Log in to view your deliveries and earnings.</p>
        </div>

        {error && (
          <div style={{ padding: '12px 16px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', borderRadius: 'var(--radius-sm)', marginBottom: '20px', fontSize: '0.9rem' }}>
            {error}
          </div>
        )}

        {step === 1 ? (
          <form onSubmit={handleSendOtp}>
            <div className="form-group">
              <label className="form-label">Phone Number</label>
              <div style={{ display: 'flex', gap: '8px' }}>
                <span style={styles.countryCode}>+977</span>
                <input
                  type="tel"
                  className="form-input"
                  placeholder="9800000000"
                  value={phone}
                  onChange={e => setPhone(e.target.value)}
                  required
                />
              </div>
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem', marginTop: '20px' }} disabled={loading}>
              {loading ? 'Sending OTP...' : 'Send OTP'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp}>
            <div className="form-group">
              <label className="form-label">Phone Number</label>
              <input type="tel" className="form-input" value={phone} disabled style={{ backgroundColor: '#f1f5f9' }} />
            </div>

            <div className="form-group" style={{ marginBottom: '20px' }}>
              <label className="form-label">Enter OTP</label>
              <input
                type="text"
                className="form-input"
                placeholder="Enter 4-digit OTP"
                value={otp}
                onChange={e => setOtp(e.target.value)}
                maxLength={4}
                required
                autoFocus
              />
              <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                For testing, use OTP: <strong>1234</strong>
              </p>
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }} disabled={loading}>
              {loading ? 'Verifying...' : 'Verify & Go Online'}
            </button>

            <button type="button" onClick={() => { setStep(1); setOtp(''); setError(''); }} style={{ width: '100%', background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', fontWeight: '600', fontSize: '0.9rem', marginTop: '12px' }}>
              ← Change Phone Number
            </button>
          </form>
        )}

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
  roleBadge: {
    display: 'inline-block',
    backgroundColor: '#ecfdf5',
    color: '#059669',
    padding: '6px 16px',
    borderRadius: '100px',
    fontWeight: '700',
    fontSize: '0.85rem',
    marginBottom: '12px',
    border: '1px solid #a7f3d0'
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
