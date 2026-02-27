import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

const AddEmployee = () => {
  const navigate = useNavigate();

  const handleSave = (e) => {
    e.preventDefault();
    navigate('/employees');
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>

      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px' }}>
        <Link to="/employees">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Onboard New Employee</h1>
          <p className="text-secondary">Create a new internal staff record and assign system permissions.</p>
        </div>
      </div>

      <div className="card">
        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>

          <h3 style={{ fontSize: '1.2rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Personal Details</h3>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">First Name</label>
              <input type="text" className="form-input" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Last Name</label>
              <input type="text" className="form-input" required />
            </div>
          </div>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Official Email</label>
              <input type="email" className="form-input" placeholder="name@doko.com" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Phone Number</label>
              <input type="tel" className="form-input" required />
            </div>
          </div>

          <h3 style={{ fontSize: '1.2rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginTop: '20px' }}>Role & Permissions</h3>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Department</label>
              <select className="form-input" required>
                <option value="support">Customer Support</option>
                <option value="operations">Operations</option>
                <option value="finance">Finance</option>
                <option value="it">IT & Admin</option>
              </select>
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">System Role Level</label>
              <select className="form-input" required>
                <option value="view_only">Level 1 (View Only)</option>
                <option value="agent">Level 2 (Support Agent)</option>
                <option value="manager">Level 3 (Manager)</option>
                <option value="admin">Level 4 (Super Admin)</option>
              </select>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end', marginTop: '30px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <Link to="/employees">
              <button type="button" className="btn btn-outline">Cancel</button>
            </Link>
            <button type="submit" className="btn btn-primary" style={{ padding: '10px 30px' }}>Create Employee</button>
          </div>

        </form>
      </div>

    </div>
  );
};

export default AddEmployee;
