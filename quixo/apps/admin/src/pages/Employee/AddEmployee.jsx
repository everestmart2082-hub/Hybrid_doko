import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const AddEmployee = () => {
  const navigate = useNavigate();
  const [form, setForm] = useState({ name: '', position: '', salary: '', address: '', email: '', phone: '', citizenship: '', bankName: '', accountNumber: '', pan: '' });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleChange = (e) => setForm(prev => ({ ...prev, [e.target.name]: e.target.value }));

  const handleSave = async (e) => {
    e.preventDefault();
    setLoading(true); setError('');
    try {
      const res = await axios.post(`${API_BASE}/admin/employee/add`, { token: getToken(), ...form, salary: Number(form.salary) });
      if (res.data.success) navigate('/employees');
      else setError(res.data.message || 'Failed to add employee');
    } catch (err) { setError('Server error'); }
    finally { setLoading(false); }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>
      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px' }}>
        <Link to="/employees">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>←</button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Onboard New Employee</h1>
          <p className="text-secondary">Create a new internal staff record.</p>
        </div>
      </div>

      {error && <div style={{ padding: '12px 16px', backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', borderRadius: '8px', marginBottom: '20px' }}>{error}</div>}

      <div className="card">
        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <h3 style={{ fontSize: '1.2rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Personal Details</h3>
          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Full Name</label>
              <input type="text" className="form-input" name="name" value={form.name} onChange={handleChange} required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Position</label>
              <input type="text" className="form-input" name="position" value={form.position} onChange={handleChange} required />
            </div>
          </div>
          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Email</label>
              <input type="email" className="form-input" name="email" value={form.email} onChange={handleChange} placeholder="name@doko.com" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Phone</label>
              <input type="tel" className="form-input" name="phone" value={form.phone} onChange={handleChange} required />
            </div>
          </div>
          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Salary (NPR)</label>
              <input type="number" className="form-input" name="salary" value={form.salary} onChange={handleChange} required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Address</label>
              <input type="text" className="form-input" name="address" value={form.address} onChange={handleChange} />
            </div>
          </div>

          <h3 style={{ fontSize: '1.2rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginTop: '20px' }}>Documents & Banking</h3>
          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Citizenship Number</label>
              <input type="text" className="form-input" name="citizenship" value={form.citizenship} onChange={handleChange} />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">PAN Number</label>
              <input type="text" className="form-input" name="pan" value={form.pan} onChange={handleChange} />
            </div>
          </div>
          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Bank Name</label>
              <input type="text" className="form-input" name="bankName" value={form.bankName} onChange={handleChange} />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Account Number</label>
              <input type="text" className="form-input" name="accountNumber" value={form.accountNumber} onChange={handleChange} />
            </div>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end', marginTop: '30px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <Link to="/employees"><button type="button" className="btn btn-outline">Cancel</button></Link>
            <button type="submit" className="btn btn-primary" style={{ padding: '10px 30px' }} disabled={loading}>
              {loading ? 'Adding...' : 'Create Employee'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AddEmployee;
