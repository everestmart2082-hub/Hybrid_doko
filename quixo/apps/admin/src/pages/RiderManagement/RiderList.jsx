import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const RiderList = () => {
  const [riders, setRiders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    axios.get(`${API_BASE}/rider/all`).then(res => {
      setRiders(res.data.message || []);
    }).catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleSuspend = async (id, suspended) => {
    try {
      await axios.post(`${API_BASE}/admin/rider/suspension`, { token: getToken(), 'rider id': id, suspended });
      setRiders(prev => prev.map(r => r._id === id ? { ...r, suspended } : r));
    } catch (e) { alert('Failed to update'); }
  };

  const filtered = riders.filter(r =>
    (r.name || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Rider Fleet Management</h1>
          <p className="text-secondary">Track rider status, performance, and assignments. ({riders.length} total)</p>
        </div>
        <input type="text" className="form-input" placeholder="Search riders..." style={{ width: '250px' }} value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading riders...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Phone</th><th>Vehicle</th><th>Rating</th><th>Verified</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No riders found.</td></tr>
              ) : filtered.map(r => (
                <tr key={r._id}>
                  <td style={{ fontWeight: '600' }}>{r.name}</td>
                  <td>{r.number}</td>
                  <td>{r.bikeModel || '—'} ({r.type || '—'})</td>
                  <td style={{ color: 'var(--warning)', fontWeight: 'bold' }}>{r.rating || 0} ⭐</td>
                  <td><span className={`badge ${r.verified ? 'badge-success' : 'badge-warning'}`}>{r.verified ? 'Verified' : 'Pending'}</span></td>
                  <td><span className={`badge ${r.suspended ? 'badge-danger' : 'badge-success'}`}>{r.suspended ? 'Suspended' : 'Active'}</span></td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <Link to={`/riders/${r._id}`}><button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>View</button></Link>
                      <button className={`btn ${r.suspended ? 'btn-success' : 'btn-danger'}`} style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleSuspend(r._id, !r.suspended)}>
                        {r.suspended ? 'Unsuspend' : 'Suspend'}
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default RiderList;
