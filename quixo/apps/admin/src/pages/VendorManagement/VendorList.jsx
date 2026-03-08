import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const VendorList = () => {
  const [vendors, setVendors] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    axios.get(`${API_BASE}/vender/all`).then(res => {
      setVendors(res.data.message || []);
    }).catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleSuspend = async (id, suspended) => {
    try {
      await axios.post(`${API_BASE}/admin/vender/suspension`, { token: getToken(), 'vender id': id, suspended });
      setVendors(prev => prev.map(v => v._id === id ? { ...v, suspended } : v));
    } catch (e) { alert('Failed to update'); }
  };

  const filtered = vendors.filter(v =>
    (v.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (v.storeName || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Vendor Directory</h1>
          <p className="text-secondary">Manage and monitor all onboarded vendors. ({vendors.length} total)</p>
        </div>
        <input type="text" className="form-input" placeholder="Search vendors..." style={{ width: '250px' }} value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading vendors...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Store</th><th>Business Type</th><th>Phone</th><th>Verified</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No vendors found.</td></tr>
              ) : filtered.map(v => (
                <tr key={v._id}>
                  <td style={{ fontWeight: '600' }}>{v.name}</td>
                  <td>{v.storeName || '—'}</td>
                  <td><span className="badge badge-neutral">{v.businessType || '—'}</span></td>
                  <td>{v.number}</td>
                  <td><span className={`badge ${v.verified ? 'badge-success' : 'badge-warning'}`}>{v.verified ? 'Verified' : 'Pending'}</span></td>
                  <td><span className={`badge ${v.suspended ? 'badge-danger' : 'badge-success'}`}>{v.suspended ? 'Suspended' : 'Active'}</span></td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <Link to={`/vendors/${v._id}`}><button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>View</button></Link>
                      <button className={`btn ${v.suspended ? 'btn-success' : 'btn-danger'}`} style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleSuspend(v._id, !v.suspended)}>
                        {v.suspended ? 'Unsuspend' : 'Suspend'}
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

export default VendorList;
