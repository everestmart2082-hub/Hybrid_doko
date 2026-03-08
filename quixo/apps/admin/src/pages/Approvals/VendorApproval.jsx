import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const VendorApproval = () => {
  const [vendors, setVendors] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get(`${API_BASE}/vender/all`).then(res => {
      const all = res.data.message || [];
      setVendors(all.filter(v => !v.verified));
    }).catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleApprove = async (id) => {
    try {
      await axios.post(`${API_BASE}/admin/vender/approve`, { token: getToken(), 'vender id': id, approved: true });
      setVendors(prev => prev.filter(v => v._id !== id));
    } catch (e) { alert('Failed to approve'); }
  };

  const handleReject = async (id) => {
    try {
      await axios.post(`${API_BASE}/admin/vender/approve`, { token: getToken(), 'vender id': id, approved: false });
      setVendors(prev => prev.filter(v => v._id !== id));
    } catch (e) { alert('Failed to reject'); }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Vendor Approvals</h1>
          <p className="text-secondary">Review and approve new vendor registrations. ({vendors.length} pending)</p>
        </div>
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Store Name</th><th>Business Type</th><th>Phone</th><th>PAN</th><th>Actions</th></tr></thead>
            <tbody>
              {vendors.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No pending approvals 🎉</td></tr>
              ) : vendors.map(v => (
                <tr key={v._id}>
                  <td style={{ fontWeight: '600' }}>{v.name}</td>
                  <td style={{ color: 'var(--primary-dark)', fontWeight: '600' }}>{v.storeName || '—'}</td>
                  <td><span className="badge badge-neutral">{v.businessType || '—'}</span></td>
                  <td>{v.number}</td>
                  <td>{v.pan || '—'}</td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleApprove(v._id)}>Approve</button>
                      <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleReject(v._id)}>Reject</button>
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

export default VendorApproval;
