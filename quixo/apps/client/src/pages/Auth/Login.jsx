import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const Login = () => {
  const [role, setRole] = useState('customer');
  const [step, setStep] = useState(1);
  const [phone, setPhone] = useState('9800000000'); // Test number
  const [otp, setOtp] = useState('');
  const navigate = useNavigate();

  const handleSendOtp = (e) => {
    e.preventDefault();
    if (phone.length >= 10) {
      setStep(2);
    } else {
      alert("Please enter a valid 10-digit phone number.");
    }
  };

  const handleVerifyOtp = (e) => {
    e.preventDefault();
    if (otp === '1234') {
      console.log(`Logged in successfully as ${role}`);

      // Redirect based on selected role
      if (role === 'customer') {
        navigate('/');
      } else if (role === 'vendor') {
        // Redirecting to Vendor App (running on port 3001)
        window.location.href = 'http://localhost:3001/';
      } else if (role === 'rider') {
        // Redirecting to Rider App (assuming running on port 5176 or similar)
        window.location.href = 'http://localhost:5176/';
      }
    } else {
      alert('Invalid OTP. Please use the test OTP: 1234');
    }
  };

  return (
    <div style={styles.container}>
      <div style={styles.authBox} className="animate-fade-in">

        {/* Left Branding Panel */}
        <div style={styles.leftPanel}>
          <div style={styles.brand}>
            <h2>DOKO</h2>
            <p>Unified Platform Access</p>
          </div>
          <img
            src="https://images.unsplash.com/photo-1550989460-0adf9ea622e2?auto=format&fit=crop&w=600&q=80"
            alt="Delivery Operations"
            style={styles.image}
          />
        </div>

        {/* Right Form Panel */}
        <div style={styles.rightPanel}>
          <div style={styles.formContainer}>
            <h2 style={styles.title}>Welcome to Doko</h2>
            <p style={styles.subtitle}>Select your account type to continue.</p>

            {/* Role Selection */}
            {step === 1 && (
              <div style={styles.roleGrid}>
                <div
                  style={{ ...styles.roleCard, ...(role === 'customer' ? styles.roleCardActive : {}) }}
                  onClick={() => setRole('customer')}
                >
                  <span style={styles.roleIcon}>🛍️</span>
                  <span>Customer</span>
                </div>
                <div
                  style={{ ...styles.roleCard, ...(role === 'vendor' ? styles.roleCardActive : {}) }}
                  onClick={() => setRole('vendor')}
                >
                  <span style={styles.roleIcon}>🏪</span>
                  <span>Vendor</span>
                </div>
                <div
                  style={{ ...styles.roleCard, ...(role === 'rider' ? styles.roleCardActive : {}) }}
                  onClick={() => setRole('rider')}
                >
                  <span style={styles.roleIcon}>🛵</span>
                  <span>Rider</span>
                </div>
              </div>
            )}

            {/* Step 1: Phone Number Registration/Login */}
            {step === 1 ? (
              <form onSubmit={handleSendOtp} style={styles.form}>
                <div style={styles.inputGroup}>
                  <label style={styles.label}>Phone Number</label>
                  <div style={{ display: 'flex', gap: '10px' }}>
                    <span style={styles.countryCode}>+977</span>
                    <input
                      type="tel"
                      value={phone}
                      onChange={(e) => setPhone(e.target.value)}
                      placeholder="9800000000"
                      style={{ ...styles.input, flex: 1 }}
                      required
                    />
                  </div>
                  <small style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>
                    *Test phone number preset for demo purposes.
                  </small>
                </div>

                <button type="submit" className="btn btn-primary" style={styles.submitBtn}>
                  Send OTP
                </button>
              </form>
            ) : (
              /* Step 2: OTP Verification */
              <form onSubmit={handleVerifyOtp} style={styles.form}>
                <div style={styles.inputGroup}>
                  <label style={styles.label}>Enter OTP</label>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '-5px', marginBottom: '10px' }}>
                    An OTP has been sent to +977 {phone}. <br />
                    <strong>Test OTP is: 1234</strong>
                  </p>
                  <input
                    type="text"
                    value={otp}
                    onChange={(e) => setOtp(e.target.value)}
                    placeholder="1234"
                    maxLength="4"
                    style={{ ...styles.input, textAlign: 'center', fontSize: '1.5rem', letterSpacing: '8px' }}
                    required
                  />
                </div>

                <div style={{ display: 'flex', gap: '10px', marginTop: '10px' }}>
                  <button type="button" className="btn btn-outline" style={{ flex: 1, padding: '14px' }} onClick={() => setStep(1)}>
                    Back
                  </button>
                  <button type="submit" className="btn btn-primary" style={{ flex: 2, padding: '14px' }}>
                    Verify & Login
                  </button>
                </div>
              </form>
            )}

            <p style={styles.footerText}>
              Don't have an account? <Link to="/register" style={{ color: 'var(--primary)', fontWeight: '600' }}>Sign up</Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

const styles = {
  container: {
    minHeight: 'calc(100vh - 70px)',
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'center',
    padding: '40px 20px',
    backgroundColor: '#f3f4f6'
  },
  authBox: {
    display: 'flex',
    width: '100%',
    maxWidth: '1000px',
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-lg)',
    overflow: 'hidden',
    boxShadow: 'var(--shadow-lg)'
  },
  leftPanel: {
    flex: '1',
    backgroundColor: 'var(--primary)',
    position: 'relative',
    display: 'none',
    '@media (min-width: 768px)': {
      display: 'block'
    }
  },
  brand: {
    position: 'absolute',
    top: '40px',
    left: '40px',
    color: 'white',
    zIndex: '10'
  },
  image: {
    width: '100%',
    height: '100%',
    objectFit: 'cover',
    opacity: '0.8'
  },
  rightPanel: {
    flex: '1.2',
    padding: '60px 40px',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center'
  },
  formContainer: {
    maxWidth: '420px',
    width: '100%',
    margin: '0 auto'
  },
  title: {
    fontSize: '2rem',
    marginBottom: '8px'
  },
  subtitle: {
    color: 'var(--text-secondary)',
    marginBottom: '32px'
  },
  roleGrid: {
    display: 'flex',
    gap: '12px',
    marginBottom: '30px'
  },
  roleCard: {
    flex: 1,
    padding: '16px 12px',
    border: '2px solid var(--border)',
    borderRadius: 'var(--radius-sm)',
    display: 'flex',
    flexDirection: 'column',
    alignItems: 'center',
    gap: '8px',
    cursor: 'pointer',
    transition: 'all 0.2s',
    color: 'var(--text-secondary)',
    fontWeight: '600'
  },
  roleCardActive: {
    borderColor: 'var(--primary)',
    color: 'var(--primary)',
    backgroundColor: 'var(--primary-light)'
  },
  roleIcon: {
    fontSize: '1.8rem'
  },
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '20px'
  },
  inputGroup: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  label: {
    fontSize: '0.9rem',
    fontWeight: '600',
    color: 'var(--text-primary)'
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
  },
  input: {
    padding: '14px 16px',
    borderRadius: 'var(--radius-sm)',
    border: '1px solid var(--border)',
    fontSize: '1rem',
    outline: 'none',
    transition: 'border-color 0.2s'
  },
  submitBtn: {
    width: '100%',
    padding: '16px',
    marginTop: '10px',
    fontSize: '1.05rem'
  },
  footerText: {
    textAlign: 'center',
    marginTop: '30px',
    color: 'var(--text-secondary)'
  }
};

export default Login;
