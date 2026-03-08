import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { riderAuthAPI } from '../../services/riderApi';

const RiderRegister = () => {
  const [formData, setFormData] = useState({ name: '', phone: '', vehicle: 'bike' });
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
      const { data } = await riderAuthAPI.register({
        name: formData.name,
        number: formData.phone,
        type: formData.vehicle
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
      const { data } = await riderAuthAPI.verifyRegistrationOtp(formData.phone, otp);
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
        <div style={{ display: 'flex', width: '100%', justifyContent: 'flex-start', marginBottom: '20px' }}>
          <Link to="/login" style={{ color: 'white', textDecoration: 'none', fontWeight: 'bold' }}>← Back to Login</Link>
        </div>
        <h1 style={{ fontSize: '2rem', margin: 0 }}>Join the Fleet 🛵</h1>
        <p style={{ color: 'rgba(255,255,255,0.9)', marginTop: '8px', fontSize: '0.9rem' }}>Earn on your own schedule with Doko.</p>
      </div>

      <div className="card" style={styles.card}>
        <div style={{ textAlign: 'center', marginBottom: '20px' }}>
          <div style={styles.roleBadge}>🛵 Rider Registration</div>
        </div>

        {error && (
          <div style={{ padding: '12px 16px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', borderRadius: 'var(--radius-sm)', marginBottom: '20px', fontSize: '0.9rem' }}>
            {error}
          </div>
        )}

        {step === 1 ? (
          <form onSubmit={handleRegister}>

            <h3 style={{ fontSize: '1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginBottom: '20px' }}>Personal Info</h3>

            <div className="form-group">
              <label className="form-label">Full Name</label>
              <input
                type="text"
                className="form-input"
                placeholder="e.g. Ramesh Thapa"
                value={formData.name}
                onChange={e => setFormData({ ...formData, name: e.target.value })}
                required
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

            <h3 style={{ fontSize: '1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginBottom: '20px', marginTop: '30px' }}>Vehicle Info</h3>

            <div className="form-group" style={{ marginBottom: '30px' }}>
              <label className="form-label">Vehicle Type</label>
              <div style={{ display: 'flex', gap: '10px' }}>
                <div
                  style={{ ...styles.vehicleCard, ...(formData.vehicle === 'bike' ? styles.vehicleCardActive : {}) }}
                  onClick={() => setFormData({ ...formData, vehicle: 'bike' })}
                >
                  <div style={{ fontSize: '2rem' }}>🏍️</div>
                  <div style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Motorbike</div>
                </div>
                <div
                  style={{ ...styles.vehicleCard, ...(formData.vehicle === 'scooter' ? styles.vehicleCardActive : {}) }}
                  onClick={() => setFormData({ ...formData, vehicle: 'scooter' })}
                >
                  <div style={{ fontSize: '2rem' }}>🛵</div>
                  <div style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Scooter</div>
                </div>
                <div
                  style={{ ...styles.vehicleCard, ...(formData.vehicle === 'bicycle' ? styles.vehicleCardActive : {}) }}
                  onClick={() => setFormData({ ...formData, vehicle: 'bicycle' })}
                >
                  <div style={{ fontSize: '2rem' }}>🚲</div>
                  <div style={{ fontSize: '0.85rem', fontWeight: 'bold' }}>Bicycle</div>
                </div>
              </div>
            </div>

            <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }} disabled={loading}>
              {loading ? 'Submitting...' : 'Submit & Send OTP'}
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
              {loading ? 'Verifying...' : 'Verify & Join'}
            </button>

            <button type="button" onClick={() => { setStep(1); setOtp(''); setError(''); }} style={{ width: '100%', background: 'none', border: 'none', color: 'var(--primary)', cursor: 'pointer', fontWeight: '600', fontSize: '0.9rem', marginTop: '12px' }}>
              ← Change Details
            </button>
          </form>
        )}

        <p style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', textAlign: 'center', marginTop: '20px' }}>
          By submitting, you agree to Doko's Terms and Conditions and acknowledge our Privacy Policy.
        </p>
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
    margin: '0 auto 20px auto',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'flex-start'
  },
  card: {
    width: '100%',
    maxWidth: '400px',
    margin: '0 auto',
    padding: '30px 24px',
    borderRadius: 'var(--radius-lg)',
    boxShadow: '0 20px 25px -5px rgb(0 0 0 / 0.1)'
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
  },
  vehicleCard: {
    flex: 1,
    border: '2px solid var(--border)',
    borderRadius: 'var(--radius-md)',
    padding: '12px 4px',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    cursor: 'pointer',
    transition: 'all 0.2s',
    color: 'var(--text-secondary)'
  },
  vehicleCardActive: {
    borderColor: 'var(--primary)',
    backgroundColor: 'var(--primary-light)',
    color: 'var(--primary-dark)'
  }
};

export default RiderRegister;
