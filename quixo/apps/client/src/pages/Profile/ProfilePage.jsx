import React, { useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { AuthContext } from '../../context/AuthContext';

const ProfilePage = () => {
  const { user, logout } = useContext(AuthContext);
  const navigate = useNavigate();

  if (!user) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center', minHeight: 'calc(100vh - 70px)' }}>
        <div style={{ fontSize: '4rem', marginBottom: '16px' }}>👤</div>
        <h2>Please log in to view your profile</h2>
        <button className="btn btn-primary" style={{ marginTop: '20px' }} onClick={() => navigate('/login')}>Log In</button>
      </div>
    );
  }

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px 20px', minHeight: 'calc(100vh - 70px)' }}>
      <div style={{ maxWidth: '600px', margin: '0 auto' }}>

        {/* Profile Card */}
        <div style={{ backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)', overflow: 'hidden', marginBottom: '24px' }}>
          <div style={{ padding: '40px 30px', backgroundColor: '#f8fafc', borderBottom: '1px solid var(--border)', textAlign: 'center' }}>
            <div style={{ width: '80px', height: '80px', borderRadius: '50%', backgroundColor: 'var(--primary)', color: 'white', display: 'flex', justifyContent: 'center', alignItems: 'center', fontSize: '2rem', fontWeight: '700', margin: '0 auto 16px' }}>
              {user.name?.[0]?.toUpperCase() || '?'}
            </div>
            <h2 style={{ fontSize: '1.5rem', marginBottom: '4px' }}>{user.name}</h2>
            <p style={{ color: 'var(--text-secondary)' }}>{user.email}</p>
            {user.phone && <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem' }}>{user.phone}</p>}
          </div>

          <div style={{ padding: '24px 30px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Name</span>
              <span style={{ fontWeight: '600' }}>{user.name}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Email</span>
              <span style={{ fontWeight: '600' }}>{user.email}</span>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 0', borderBottom: '1px solid var(--border)' }}>
              <span style={{ color: 'var(--text-secondary)' }}>Role</span>
              <span style={{ fontWeight: '600', textTransform: 'capitalize' }}>{user.role}</span>
            </div>
            {user.phone && (
              <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 0' }}>
                <span style={{ color: 'var(--text-secondary)' }}>Phone</span>
                <span style={{ fontWeight: '600' }}>{user.phone}</span>
              </div>
            )}
          </div>
        </div>

        {/* Quick Links */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '24px' }}>
          <button className="btn btn-outline" style={{ padding: '16px', justifyContent: 'flex-start', gap: '12px' }} onClick={() => navigate('/orders')}>
            📦 My Orders
          </button>
          <button className="btn btn-outline" style={{ padding: '16px', justifyContent: 'flex-start', gap: '12px' }} onClick={() => navigate('/wishlist')}>
            ❤️ My Wishlist
          </button>
        </div>

        {/* Logout */}
        <button className="btn" onClick={handleLogout} style={{ width: '100%', padding: '16px', border: '1px solid #ef4444', color: '#ef4444', fontSize: '1rem', fontWeight: '600' }}>
          Logout
        </button>

      </div>
    </div>
  );
};

export default ProfilePage;
