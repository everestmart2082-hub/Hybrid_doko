import React, { useState } from 'react';
import { Link } from 'react-router-dom';

const Register = () => {
  const [formData, setFormData] = useState({
    name: '',
    phone: '',
    password: '',
    confirmPassword: ''
  });

  const handleChange = (e) => {
    setFormData({ ...formData, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    console.log('Register attempt:', formData);
  };

  return (
    <div style={styles.container}>
      <div style={styles.authBox} className="animate-fade-in">
        <div style={styles.leftPanel}>
          <div style={styles.brand}>
            <h2>DOKO</h2>
            <p>15-Minute Delivery</p>
          </div>
          <img
            src="https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=600&q=80"
            alt="Fresh Produce"
            style={styles.image}
          />
        </div>
        <div style={styles.rightPanel}>
          <div style={styles.formContainer}>
            <h2 style={styles.title}>Create Account</h2>
            <p style={styles.subtitle}>Join Doko for fastest deliveries in town.</p>

            <form onSubmit={handleSubmit} style={styles.form}>
              <div style={styles.inputGroup}>
                <label style={styles.label}>Full Name</label>
                <input
                  type="text"
                  name="name"
                  value={formData.name}
                  onChange={handleChange}
                  placeholder="John Doe"
                  style={styles.input}
                  required
                />
              </div>

              <div style={styles.inputGroup}>
                <label style={styles.label}>Phone Number</label>
                <input
                  type="tel"
                  name="phone"
                  value={formData.phone}
                  onChange={handleChange}
                  placeholder="Enter your phone number"
                  style={styles.input}
                  required
                />
              </div>

              <div style={styles.inputGroup}>
                <label style={styles.label}>Password</label>
                <input
                  type="password"
                  name="password"
                  value={formData.password}
                  onChange={handleChange}
                  placeholder="Create a strong password"
                  style={styles.input}
                  required
                />
              </div>

              <div style={styles.inputGroup}>
                <label style={styles.label}>Confirm Password</label>
                <input
                  type="password"
                  name="confirmPassword"
                  value={formData.confirmPassword}
                  onChange={handleChange}
                  placeholder="Repeat your password"
                  style={styles.input}
                  required
                />
              </div>

              <button type="submit" className="btn btn-primary" style={styles.submitBtn}>
                Create Account
              </button>
            </form>

            <p style={styles.footerText}>
              Already have an account? <Link to="/login" style={{ color: 'var(--primary)', fontWeight: '600' }}>Log in</Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

// Reusing similar styles as Login for consistency
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
    backgroundColor: 'var(--secondary)',
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
    zIndex: '10',
    textShadow: '0 2px 4px rgba(0,0,0,0.3)'
  },
  image: {
    width: '100%',
    height: '100%',
    objectFit: 'cover',
    opacity: '0.9'
  },
  rightPanel: {
    flex: '1',
    padding: '40px',
    display: 'flex',
    flexDirection: 'column',
    justifyContent: 'center'
  },
  formContainer: {
    maxWidth: '400px',
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
  form: {
    display: 'flex',
    flexDirection: 'column',
    gap: '16px'
  },
  inputGroup: {
    display: 'flex',
    flexDirection: 'column',
    gap: '6px'
  },
  label: {
    fontSize: '0.9rem',
    fontWeight: '600',
    color: 'var(--text-primary)'
  },
  input: {
    padding: '12px 16px',
    borderRadius: 'var(--radius-sm)',
    border: '1px solid var(--border)',
    fontSize: '1rem',
    outline: 'none',
    transition: 'border-color 0.2s'
  },
  submitBtn: {
    width: '100%',
    padding: '14px',
    marginTop: '16px'
  },
  footerText: {
    textAlign: 'center',
    marginTop: '24px',
    color: 'var(--text-secondary)'
  }
};

export default Register;
