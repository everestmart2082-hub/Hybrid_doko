import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const RiderRegister = () => {
  const [formData, setFormData] = useState({ name: '', phone: '', vehicle: 'bike' });
  const navigate = useNavigate();

  const handleRegister = (e) => {
    e.preventDefault();
    console.log("Rider applying...", formData);
    // Directly log them in or send to an 'Application Pending' screen for now
    navigate('/');
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

          <button type="submit" className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.1rem' }}>
            Submit Application
          </button>
        </form>

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
