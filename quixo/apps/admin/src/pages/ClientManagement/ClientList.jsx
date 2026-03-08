import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const ClientList = () => {
  const [clients, setClients] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    axios.get(`${API_BASE}/user/all`).then(res => {
      setClients(res.data.message || []);
    }).catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleSuspend = async (id, suspended) => {
    try {
      await axios.post(`${API_BASE}/admin/user/suspension`, { token: getToken(), 'user id': id, suspended });
      setClients(prev => prev.map(c => c._id === id ? { ...c, suspend: suspended } : c));
    } catch (e) { alert('Failed to update'); }
  };

  const filtered = clients.filter(c =>
    (c.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.email || '').toLowerCase().includes(search.toLowerCase()) ||
    (c.number || '').includes(search)
  );

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Client Database</h1>
          <p className="text-secondary">View registered users. ({clients.length} total)</p>
        </div>
        <input type="text" className="form-input" placeholder="Search email, name, or phone..." style={{ width: '300px' }} value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading clients...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Phone</th><th>Email</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No clients found.</td></tr>
              ) : filtered.map(c => (
                <tr key={c._id}>
                  <td style={{ fontWeight: '600' }}>{c.name}</td>
                  <td>{c.number}</td>
                  <td>{c.email || '—'}</td>
                  <td><span className={`badge ${c.suspend ? 'badge-danger' : 'badge-success'}`}>{c.suspend ? 'Suspended' : 'Active'}</span></td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <Link to={`/clients/${c._id}`}><button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Details</button></Link>
                      <button className={`btn ${c.suspend ? 'btn-success' : 'btn-danger'}`} style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleSuspend(c._id, !c.suspend)}>
                        {c.suspend ? 'Unsuspend' : 'Suspend'}
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

export default ClientList;
