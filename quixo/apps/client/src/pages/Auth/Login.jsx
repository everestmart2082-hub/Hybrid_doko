import React, { useState, useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { authAPI } from '../../services/api';
import { AuthContext } from '../../context/AuthContext';

const ROLES = [
  { id: 'customer', label: 'Customer', icon: '👤', color: '#2563eb', bg: '#eff6ff', border: '#bfdbfe', desc: 'Order & get delivery' },
  { id: 'vendor', label: 'Vendor', icon: '🏪', color: '#d97706', bg: '#fef3c7', border: '#fde68a', desc: 'Sell your products' },
  { id: 'rider', label: 'Rider', icon: '🛵', color: '#059669', bg: '#ecfdf5', border: '#a7f3d0', desc: 'Deliver & earn' },
];

const Login = () => {
  const [role, setRole] = useState(null);
  const [phone, setPhone] = useState('');
  const [otp, setOtp] = useState('');
  const [step, setStep] = useState(0); // 0 = pick role, 1 = phone, 2 = OTP
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const navigate = useNavigate();
  const { login, fetchUser } = useContext(AuthContext);

  const selectedRole = ROLES.find(r => r.id === role);

  // --- API helpers per role ---
  const loginFn = (phone) => {
    if (role === 'vendor') return authAPI.vendorLogin(phone);
    if (role === 'rider') return authAPI.riderLogin(phone);
    return authAPI.login(phone);
  };
  const verifyFn = (phone, otp) => {
    if (role === 'vendor') return authAPI.vendorVerifyLoginOtp(phone, otp);
    if (role === 'rider') return authAPI.riderVerifyLoginOtp(phone, otp);
    return authAPI.verifyLoginOtp(phone, otp);
  };

  const handleSendOtp = async (e) => {
    e.preventDefault();
    setLoading(true); setError('');
    try {
      const { data } = await loginFn(phone);
      if (data.success) { setStep(2); }
      else { setError(data.message || 'Phone number not found.'); }
    } catch (err) { setError(err.response?.data?.message || 'Login failed.'); }
    finally { setLoading(false); }
  };

  const handleVerifyOtp = async (e) => {
    e.preventDefault();
    setLoading(true); setError('');
    try {
      const { data } = await verifyFn(phone, otp);
      if (data.success && data.token) {
        if (role === 'customer') {
          login(data.token, null);
          try { const p = await authAPI.getProfile(); if (p.data.success) login(data.token, p.data.message); } catch { }
          navigate('/');
        } else if (role === 'vendor') {
          // Store token for vendor app & redirect
          localStorage.setItem('vendor_token', data.token);
          window.location.href = 'http://localhost:3001/?token=' + data.token;
        } else if (role === 'rider') {
          localStorage.setItem('rider_token', data.token);
          window.location.href = 'http://localhost:3002/?token=' + data.token;
        }
      } else { setError(data.message || 'OTP verification failed.'); }
    } catch (err) { setError(err.response?.data?.message || 'OTP verification failed.'); }
    finally { setLoading(false); }
  };

  // --- STEP 0: Role selector ---
  if (step === 0) {
    return (
      <div style={styles.container}>
        <div style={styles.card} className="animate-fade-in">
          <div style={{ textAlign: 'center', marginBottom: '40px' }}>
            <h1 style={{ fontSize: '2.2rem', marginBottom: '8px' }}>Welcome to <span style={{ color: 'var(--primary)' }}>DOKO</span></h1>
            <p style={{ color: 'var(--text-secondary)', fontSize: '1.05rem' }}>Choose how you'd like to sign in</p>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px', marginBottom: '30px' }}>
            {ROLES.map(r => (
              <button
                key={r.id}
                onClick={() => { setRole(r.id); setStep(1); setError(''); }}
                style={{
                  display: 'flex', alignItems: 'center', gap: '20px',
                  padding: '20px 24px', borderRadius: 'var(--radius-md)',
                  border: `2px solid ${r.border}`, backgroundColor: r.bg,
                  cursor: 'pointer', transition: 'all 0.2s',
                  textAlign: 'left'
                }}
                onMouseOver={e => { e.currentTarget.style.transform = 'translateY(-2px)'; e.currentTarget.style.boxShadow = 'var(--shadow-md)'; }}
                onMouseOut={e => { e.currentTarget.style.transform = 'none'; e.currentTarget.style.boxShadow = 'none'; }}
              >
                <span style={{ fontSize: '2.5rem' }}>{r.icon}</span>
                <div style={{ flex: 1 }}>
                  <div style={{ fontWeight: '800', fontSize: '1.15rem', color: r.color }}>Sign in as {r.label}</div>
                  <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '2px' }}>{r.desc}</div>
                </div>
                <span style={{ fontSize: '1.5rem', color: r.color }}>→</span>
              </button>
            ))}
          </div>

          <p style={{ textAlign: 'center', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
            Don't have an account? <Link to="/register" style={{ color: 'var(--primary)', fontWeight: '700' }}>Create one</Link>
          </p>
        </div>
      </div>
    );
  }

  // --- STEP 1 & 2: Phone + OTP ---
  return (
    <div style={styles.container}>
      <div style={styles.card} className="animate-fade-in">

        {/* Back & Role Badge */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px', marginBottom: '30px' }}>
          <button onClick={() => { setStep(0); setRole(null); setPhone(''); setOtp(''); setError(''); }}
            style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1.3rem', padding: '4px 8px' }}>←</button>
          <div style={{
            padding: '6px 16px', borderRadius: '100px', fontWeight: '700', fontSize: '0.85rem',
            backgroundColor: selectedRole?.bg, color: selectedRole?.color, border: `1px solid ${selectedRole?.border}`
          }}>
            {selectedRole?.icon} {selectedRole?.label} Login
          </div>
        </div>

        <h2 style={{ fontSize: '1.8rem', marginBottom: '8px' }}>
          {step === 1 ? 'Enter your phone' : 'Verify OTP'}
        </h2>
        <p style={{ color: 'var(--text-secondary)', marginBottom: '28px' }}>
          {step === 1
            ? `Sign in to your ${selectedRole?.label} account.`
            : `We sent a code to +977 ${phone}`}
        </p>

        {error && (
          <div style={{ padding: '12px 16px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', borderRadius: 'var(--radius-sm)', marginBottom: '20px', fontSize: '0.9rem' }}>
            {error}
          </div>
        )}

        {step === 1 ? (
          <form onSubmit={handleSendOtp} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <label style={styles.label}>Phone Number</label>
              <div style={{ display: 'flex', gap: '8px' }}>
                <span style={styles.countryCode}>+977</span>
                <input type="tel" value={phone} onChange={e => setPhone(e.target.value)}
                  placeholder="9800000000" style={{ ...styles.input, flex: 1 }} required autoFocus />
              </div>
            </div>
            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.05rem' }} disabled={loading}>
              {loading ? 'Sending...' : 'Send OTP'}
            </button>
          </form>
        ) : (
          <form onSubmit={handleVerifyOtp} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
              <label style={styles.label}>Enter OTP</label>
              <input type="text" value={otp} onChange={e => setOtp(e.target.value)}
                placeholder="1234" style={{ ...styles.input, textAlign: 'center', letterSpacing: '8px', fontSize: '1.5rem', fontWeight: '800' }}
                maxLength={4} required autoFocus />
              <p style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '4px' }}>
                For testing, use OTP: <strong>1234</strong>
              </p>
            </div>
            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.05rem' }} disabled={loading}>
              {loading ? 'Verifying...' : 'Verify & Sign In'}
            </button>
            <button type="button" onClick={() => { setStep(1); setOtp(''); setError(''); }}
              style={{ background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', fontWeight: '600', fontSize: '0.9rem' }}>
              ← Change Phone Number
            </button>
          </form>
        )}

        {role !== 'customer' && (
          <div style={{ marginTop: '24px', padding: '14px', backgroundColor: '#fffbeb', borderRadius: 'var(--radius-sm)', border: '1px solid #fde68a', fontSize: '0.85rem', color: '#92400e' }}>
            ⚠️ {selectedRole?.label} accounts require <strong>admin approval</strong> before full access is granted.
          </div>
        )}

        <p style={{ textAlign: 'center', marginTop: '24px', color: 'var(--text-secondary)', fontSize: '0.9rem' }}>
          Don't have an account? <Link to="/register" style={{ color: 'var(--primary)', fontWeight: '700' }}>Create one</Link>
        </p>
      </div>
    </div>
  );
};

const styles = {
  container: {
    minHeight: 'calc(100vh - 70px)',
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    padding: '40px 20px', backgroundColor: '#f3f4f6'
  },
  card: {
    width: '100%', maxWidth: '480px',
    backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)',
    padding: '48px 40px', boxShadow: 'var(--shadow-lg)'
  },
  label: { fontSize: '0.9rem', fontWeight: '600', color: 'var(--text-primary)' },
  input: {
    padding: '14px 16px', borderRadius: 'var(--radius-sm)',
    border: '1px solid var(--border)', fontSize: '1rem', outline: 'none',
    transition: 'border-color 0.2s'
  },
  countryCode: {
    display: 'flex', alignItems: 'center', justifyContent: 'center',
    padding: '0 16px', backgroundColor: '#f1f5f9',
    border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)',
    fontWeight: '600', color: 'var(--text-secondary)'
  }
};

export default Login;
