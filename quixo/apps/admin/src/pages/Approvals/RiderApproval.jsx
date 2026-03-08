import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const RiderApproval = () => {
  const [riders, setRiders] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.get(`${API_BASE}/rider/all`).then(res => {
      const all = res.data.message || [];
      setRiders(all.filter(r => !r.verified));
    }).catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleApprove = async (id) => {
    try {
      await axios.post(`${API_BASE}/admin/rider/approve`, { token: getToken(), 'rider id': id, approved: true });
      setRiders(prev => prev.filter(r => r._id !== id));
    } catch (e) { alert('Failed to approve'); }
  };

  const handleReject = async (id) => {
    try {
      await axios.post(`${API_BASE}/admin/rider/approve`, { token: getToken(), 'rider id': id, approved: false });
      setRiders(prev => prev.filter(r => r._id !== id));
    } catch (e) { alert('Failed to reject'); }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Rider Approvals</h1>
          <p className="text-secondary">Verify rider documents and vehicle registration. ({riders.length} pending)</p>
        </div>
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Phone</th><th>Vehicle</th><th>Bike Number</th><th>Documents</th><th>Actions</th></tr></thead>
            <tbody>
              {riders.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No pending approvals 🎉</td></tr>
              ) : riders.map(r => (
                <tr key={r._id}>
                  <td style={{ fontWeight: '600', color: 'var(--primary-dark)' }}>{r.name}</td>
                  <td>{r.number}</td>
                  <td>{r.bikeModel || '—'} ({r.type || '—'})</td>
                  <td>{r.bikeNumber || '—'}</td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      {r.rcBook && <span className="badge badge-info">RC Book</span>}
                      {r.citizenship && <span className="badge badge-info">Citizenship</span>}
                      {r.panCard && <span className="badge badge-info">PAN</span>}
                      {r.bikeInsurancePaper && <span className="badge badge-info">Insurance</span>}
                      {!r.rcBook && !r.citizenship && !r.panCard && <span className="badge badge-warning">Missing</span>}
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleApprove(r._id)}>Approve</button>
                      <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleReject(r._id)}>Reject</button>
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

export default RiderApproval;
