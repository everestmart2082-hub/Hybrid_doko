import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { adminLogin, adminVerifyOtp } from '../../services/adminService';

const AdminLogin = () => {
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState(1); // 1 = phone, 2 = OTP
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();

  const handleSendOtp = async (e) => {
    e.preventDefault();
    setLoading(true); setError('');
    try {
      const { data } = await adminLogin(phone);
      if (data.success) { setStep(2); }
      else { setError(data.message || 'Admin not found.'); }
    } catch (err) { setError(err.response?.data?.message || 'Login failed.'); }
    finally { setLoading(false); }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    setLoading(true); setError('');
    try {
      const { data } = await adminVerifyOtp(phone, otp);
      if (data.success && data.token) {
        localStorage.setItem('admin_token', data.token);
        navigate('/');
      } else { setError(data.message || 'OTP verification failed.'); }
    } catch (err) { setError(err.response?.data?.message || 'OTP verification failed.'); }
    finally { setLoading(false); }
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
            <p className="text-secondary">
              {step === 1 ? 'Enter your admin phone number' : `Verify OTP sent to +977 ${phone}`}
            </p>
          </div>

          {error && (
            <div style={{ padding: '12px 16px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', borderRadius: '8px', marginBottom: '20px', fontSize: '0.9rem' }}>
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
                    autoFocus
                  />
                </div>
              </div>
              <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem', marginTop: '20px' }} disabled={loading}>
                {loading ? 'Sending...' : 'Send OTP'}
              </button>
            </form>
          ) : (
            <form onSubmit={handleVerifyOtp}>
              <div className="form-group">
                <label className="form-label">Enter OTP</label>
                <input
                  type="text"
                  className="form-input"
                  placeholder="1234"
                  value={otp}
                  onChange={e => setOtp(e.target.value)}
                  maxLength={4}
                  required
                  autoFocus
                  style={{ textAlign: 'center', letterSpacing: '8px', fontSize: '1.5rem', fontWeight: '800' }}
                />
                <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '8px' }}>
                  For testing, use OTP: <strong>1234</strong>
                </p>
              </div>
              <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem', marginTop: '20px' }} disabled={loading}>
                {loading ? 'Verifying...' : 'Access Dashboard'}
              </button>
              <button type="button" onClick={() => { setStep(1); setOtp(''); setError(''); }}
                style={{ width: '100%', background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', fontWeight: '600', fontSize: '0.9rem', marginTop: '16px' }}>
                ← Change Phone Number
              </button>
            </form>
          )}

          <div style={{ marginTop: '30px', textAlign: 'center', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
            Restricted System. Unauthorized access is strictly prohibited.
          </div>
        </div>
      </div>

    </div>
  );
};

const styles = {
  container: { display: 'flex', minHeight: '100vh', backgroundColor: 'var(--bg-color)' },
  leftPanel: { flex: '1', backgroundColor: 'var(--primary-dark)', display: 'flex', flexDirection: 'column', justifyContent: 'center', alignItems: 'center', padding: '40px', position: 'relative', overflow: 'hidden' },
  rightPanel: { flex: '1', display: 'flex', justifyContent: 'center', alignItems: 'center', padding: '40px', backgroundColor: '#ffffff' },
  brandBadge: { display: 'inline-block', backgroundColor: 'rgba(255,255,255,0.1)', color: 'white', padding: '8px 24px', borderRadius: '100px', fontWeight: '800', letterSpacing: '2px', fontSize: '1rem', marginBottom: '30px', border: '1px solid rgba(255,255,255,0.2)' },
  featureGrid: { display: 'flex', justifyContent: 'center', gap: '40px', marginTop: '60px' },
  featureItem: { display: 'flex', flexDirection: 'column', alignItems: 'center', opacity: 0.9 },
  loginCard: { width: '100%', maxWidth: '480px', padding: '48px 40px', border: 'none', boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1)' },
  countryCode: { display: 'flex', alignItems: 'center', justifyContent: 'center', padding: '0 16px', backgroundColor: '#f1f5f9', border: '1px solid var(--border-color, #e5e7eb)', borderRadius: '8px', fontWeight: '600', color: '#64748b' }
};

export default AdminLogin;
