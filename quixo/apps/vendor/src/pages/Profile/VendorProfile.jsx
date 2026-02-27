import React from 'react';

const VendorProfile = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>

      <div style={{ marginBottom: '30px' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Store Settings & Profile</h1>
        <p className="text-secondary">Update your public store details and private contact info.</p>
      </div>

      <div className="card">
        <form style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>

          <div style={{ display: 'flex', alignItems: 'center', gap: '20px', marginBottom: '20px' }}>
            <div style={{ width: '80px', height: '80px', borderRadius: '50%', backgroundColor: 'var(--primary-light)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '2rem' }}>
              🏪
            </div>
            <div>
              <button type="button" className="btn btn-outline" style={{ marginBottom: '8px' }}>Change Store Logo</button>
              <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', margin: 0 }}>JPG or PNG. Max 2MB.</p>
            </div>
          </div>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Public Information</h3>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Store Name</label>
            <input type="text" className="form-input" defaultValue="Kathmandu Fresh Mart" required />
          </div>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Support Email</label>
              <input type="email" className="form-input" defaultValue="support@ktmfresh.com" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Support Phone</label>
              <input type="tel" className="form-input" defaultValue="+977 9801234567" required />
            </div>
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Physical Address</label>
            <textarea className="form-input" rows="3" defaultValue="142 Minbhawan Marg, Kathmandu" required></textarea>
          </div>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginTop: '20px' }}>Private Information</h3>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Owner Full Name</label>
              <input type="text" className="form-input" defaultValue="Krishna Bahadur" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Owner Phone (Login ID)</label>
              <input type="tel" className="form-input" defaultValue="+977 9800000000" disabled style={{ backgroundColor: '#f1f5f9' }} />
            </div>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end', marginTop: '30px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <button type="submit" className="btn btn-primary" style={{ padding: '10px 30px' }}>Save Changes</button>
          </div>

        </form>
      </div>

    </div>
  );
};

export default VendorProfile;
