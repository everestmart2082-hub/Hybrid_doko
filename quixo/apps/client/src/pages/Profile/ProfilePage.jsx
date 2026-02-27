import React, { useState } from 'react';

const ProfilePage = () => {
  const [activeTab, setActiveTab] = useState('details');

  return (
    <div className="container animate-fade-in" style={styles.page}>

      <div style={styles.sidebar}>
        <div style={styles.profileHeader}>
          <div style={styles.avatar}>JD</div>
          <div>
            <h2 style={styles.name}>John Doe</h2>
            <div style={styles.phone}>+977 9800000000</div>
          </div>
        </div>

        <nav style={styles.navConfig}>
          <button style={styles.navBtn(activeTab === 'details')} onClick={() => setActiveTab('details')}>
            Personal Details
          </button>
          <button style={styles.navBtn(activeTab === 'addresses')} onClick={() => setActiveTab('addresses')}>
            Saved Addresses
          </button>
          <button style={styles.navBtn(activeTab === 'payments')} onClick={() => setActiveTab('payments')}>
            Payment Methods
          </button>
          <button style={{ ...styles.navBtn(false), color: '#ef4444', marginTop: 'auto' }}>
            Logout
          </button>
        </nav>
      </div>

      <div style={styles.mainContent}>

        {activeTab === 'details' && (
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Personal Details</h3>
            <form style={styles.form}>
              <div style={styles.inputGroup}>
                <label style={styles.label}>Full Name</label>
                <input type="text" defaultValue="John Doe" style={styles.input} />
              </div>
              <div style={styles.inputGroup}>
                <label style={styles.label}>Phone Number</label>
                <input type="tel" defaultValue="+977 9800000000" disabled style={{ ...styles.input, backgroundColor: '#f3f4f6' }} />
              </div>
              <div style={styles.inputGroup}>
                <label style={styles.label}>Email Address (Optional)</label>
                <input type="email" placeholder="john@example.com" style={styles.input} />
              </div>
              <button type="button" className="btn btn-primary" style={{ alignSelf: 'flex-start', padding: '12px 24px', marginTop: '10px' }}>
                Save Changes
              </button>
            </form>
          </div>
        )}

        {activeTab === 'addresses' && (
          <div style={styles.card}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
              <h3 style={{ fontSize: '1.4rem' }}>Saved Addresses</h3>
              <button style={{ color: 'var(--primary)', fontWeight: '600', background: 'none' }}>+ Add New</button>
            </div>

            <div style={styles.addressList}>
              <div style={styles.addressCard}>
                <div style={styles.addressBadge}>Home</div>
                <p style={{ marginTop: '12px', color: 'var(--text-secondary)', lineHeight: '1.5' }}>
                  123 Main Street, Apt 4B<br />
                  Kathmandu, Nepal<br />
                  Landmark: Near City Center
                </p>
                <div style={{ display: 'flex', gap: '16px', marginTop: '16px' }}>
                  <button style={styles.textBtn}>Edit</button>
                  <button style={{ ...styles.textBtn, color: '#ef4444' }}>Delete</button>
                </div>
              </div>
            </div>
          </div>
        )}

        {activeTab === 'payments' && (
          <div style={styles.card}>
            <h3 style={styles.cardTitle}>Payment Methods</h3>
            <div style={{ padding: '24px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-sm)', border: '1px dashed var(--border)', textAlign: 'center' }}>
              <p style={{ color: 'var(--text-secondary)' }}>No saved payment methods yet.</p>
              <button className="btn" style={{ marginTop: '16px', border: '1px solid var(--border)' }}>Add New Method</button>
            </div>
          </div>
        )}

      </div>

    </div>
  );
};

const styles = {
  page: { padding: '40px 20px', minHeight: 'calc(100vh - 70px)', display: 'flex', gap: '30px', alignItems: 'flex-start' },
  sidebar: {
    width: '300px',
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-lg)',
    boxShadow: 'var(--shadow-sm)',
    border: '1px solid var(--border)',
    overflow: 'hidden',
    position: 'sticky',
    top: '90px',
    display: 'flex',
    flexDirection: 'column',
    height: 'calc(100vh - 120px)'
  },
  profileHeader: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    padding: '30px 24px',
    backgroundColor: '#f8fafc',
    borderBottom: '1px solid var(--border)'
  },
  avatar: {
    width: '60px',
    height: '60px',
    borderRadius: '50%',
    backgroundColor: 'var(--primary)',
    color: 'white',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    fontSize: '1.4rem',
    fontWeight: '700'
  },
  name: { fontSize: '1.2rem', marginBottom: '4px' },
  phone: { color: 'var(--text-secondary)', fontSize: '0.9rem' },
  navConfig: {
    display: 'flex',
    flexDirection: 'column',
    flex: '1',
    padding: '16px'
  },
  navBtn: (isActive) => ({
    padding: '16px 20px',
    textAlign: 'left',
    background: isActive ? '#ecfdf5' : 'transparent',
    color: isActive ? 'var(--primary-dark)' : 'var(--text-secondary)',
    fontWeight: isActive ? '600' : '500',
    borderRadius: 'var(--radius-sm)',
    marginBottom: '8px',
    transition: 'var(--transition)'
  }),
  mainContent: { flex: '1' },
  card: {
    backgroundColor: 'var(--surface)',
    padding: '40px',
    borderRadius: 'var(--radius-lg)',
    boxShadow: 'var(--shadow-sm)',
    border: '1px solid var(--border)'
  },
  cardTitle: { fontSize: '1.5rem', marginBottom: '30px' },
  form: { display: 'flex', flexDirection: 'column', gap: '24px', maxWidth: '500px' },
  inputGroup: { display: 'flex', flexDirection: 'column', gap: '8px' },
  label: { fontSize: '0.9rem', fontWeight: '600', color: 'var(--text-primary)' },
  input: {
    padding: '14px 16px',
    borderRadius: 'var(--radius-sm)',
    border: '1px solid var(--border)',
    fontSize: '1rem',
    outline: 'none',
    transition: 'border-color 0.2s'
  },
  addressList: { display: 'flex', flexDirection: 'column', gap: '20px' },
  addressCard: {
    padding: '24px',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius-md)'
  },
  addressBadge: {
    display: 'inline-block',
    backgroundColor: '#f1f5f9',
    padding: '4px 12px',
    borderRadius: 'var(--radius-sm)',
    fontSize: '0.85rem',
    fontWeight: '600'
  },
  textBtn: {
    background: 'none',
    color: 'var(--primary)',
    fontWeight: '600',
    fontSize: '0.95rem'
  }
};

export default ProfilePage;
