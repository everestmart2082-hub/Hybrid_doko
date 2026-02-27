import React from 'react';
import { useNavigate } from 'react-router-dom';

const RiderProfile = () => {
  const navigate = useNavigate();

  const handleLogout = () => {
    console.log("Logging out rider...");
    navigate('/login');
  };

  return (
    <div className="view-container animate-fade-in" style={{ pb: '100px' }}>

      <div style={{ backgroundColor: 'var(--primary)', color: 'white', padding: '40px 20px 20px 20px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
        <div style={{ width: '100px', height: '100px', borderRadius: '50%', backgroundColor: 'white', backgroundImage: 'url("https://i.pravatar.cc/150?img=11")', backgroundSize: 'cover', border: '4px solid rgba(255,255,255,0.3)', marginBottom: '16px' }}></div>
        <h2 style={{ fontSize: '1.5rem', margin: 0 }}>Ramesh Thapa</h2>
        <div className="badge" style={{ backgroundColor: 'rgba(255,255,255,0.2)', color: 'white', marginTop: '8px' }}>Doko Captain</div>

        <div style={{ display: 'flex', gap: '20px', marginTop: '20px', width: '100%', justifyContent: 'space-around', backgroundColor: 'rgba(0,0,0,0.15)', padding: '16px', borderRadius: 'var(--radius-md)' }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.2rem', fontWeight: '800' }}>4.9 ★</div>
            <div style={{ fontSize: '0.8rem', opacity: 0.8 }}>Rating</div>
          </div>
          <div style={{ width: '1px', backgroundColor: 'rgba(255,255,255,0.2)' }}></div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.2rem', fontWeight: '800' }}>1,245</div>
            <div style={{ fontSize: '0.8rem', opacity: 0.8 }}>Deliveries</div>
          </div>
          <div style={{ width: '1px', backgroundColor: 'rgba(255,255,255,0.2)' }}></div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.2rem', fontWeight: '800' }}>1.5 Yrs</div>
            <div style={{ fontSize: '0.8rem', opacity: 0.8 }}>Tenure</div>
          </div>
        </div>
      </div>

      <div className="container" style={{ paddingTop: '24px' }}>

        <div className="card" style={{ padding: '0', overflow: 'hidden', marginBottom: '24px' }}>

          <div style={{ padding: '16px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ fontSize: '1.5rem' }}>👤</div>
            <div style={{ flex: 1 }}>
              <h4 style={{ margin: 0, fontSize: '1rem' }}>Personal Info</h4>
              <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-secondary)' }}>+977 9800000000</p>
            </div>
            <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>Edit</button>
          </div>

          <div style={{ padding: '16px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ fontSize: '1.5rem' }}>🏍️</div>
            <div style={{ flex: 1 }}>
              <h4 style={{ margin: 0, fontSize: '1rem' }}>Vehicle Details</h4>
              <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-secondary)' }}>Honda Dio (Ba 43 Pa 1234)</p>
            </div>
            <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>Edit</button>
          </div>

          <div style={{ padding: '16px', display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ fontSize: '1.5rem' }}>🏦</div>
            <div style={{ flex: 1 }}>
              <h4 style={{ margin: 0, fontSize: '1rem' }}>Bank Account</h4>
              <p style={{ margin: 0, fontSize: '0.85rem', color: 'var(--text-secondary)' }}>NIC Asia (**** 4512)</p>
            </div>
            <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.8rem' }}>Edit</button>
          </div>

        </div>

        <h3 style={{ fontSize: '1rem', marginLeft: '8px', marginBottom: '16px', color: 'var(--text-secondary)' }}>App Settings</h3>

        <div className="card" style={{ padding: '0', overflow: 'hidden', marginBottom: '30px' }}>

          <div style={{ padding: '16px', borderBottom: '1px solid var(--border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}>
            <span style={{ fontWeight: '600' }}>Navigation Preferences</span>
            <span style={{ color: 'var(--text-secondary)' }}>Google Maps ❯</span>
          </div>

          <div style={{ padding: '16px', borderBottom: '1px solid var(--border)', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}>
            <span style={{ fontWeight: '600' }}>Dark Mode</span>
            {/* Toggle switch mockup */}
            <div style={{ width: '40px', height: '24px', backgroundColor: 'var(--border)', borderRadius: '12px', position: 'relative' }}>
              <div style={{ width: '20px', height: '20px', backgroundColor: 'white', borderRadius: '50%', position: 'absolute', top: '2px', left: '2px', boxShadow: 'var(--shadow-sm)' }}></div>
            </div>
          </div>

          <div style={{ padding: '16px', display: 'flex', justifyContent: 'space-between', alignItems: 'center', cursor: 'pointer' }}>
            <span style={{ fontWeight: '600' }}>Help & Support</span>
            <span style={{ color: 'var(--text-secondary)' }}>❯</span>
          </div>

        </div>

        <button
          onClick={handleLogout}
          className="btn btn-outline"
          style={{ width: '100%', color: 'var(--danger)', borderColor: 'var(--danger)', padding: '16px', marginBottom: '40px' }}
        >
          Sign Out
        </button>

      </div>
    </div>
  );
};

export default RiderProfile;
