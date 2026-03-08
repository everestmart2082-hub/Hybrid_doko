import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const ProductApproval = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    axios.post(`${API_BASE}/admin/product/all`, { token: getToken(), type: 'requested' })
      .then(res => setProducts(res.data.message || []))
      .catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleApprove = async (id) => {
    try {
      await axios.post(`${API_BASE}/admin/product/approve`, { token: getToken(), 'product id': id, approval: true });
      setProducts(prev => prev.filter(p => p._id !== id));
    } catch (e) { alert('Failed to approve'); }
  };

  const handleHide = async (id) => {
    try {
      await axios.post(`${API_BASE}/admin/product/hide`, { token: getToken(), 'product id': id, suspend: true });
      setProducts(prev => prev.filter(p => p._id !== id));
    } catch (e) { alert('Failed'); }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Product Approvals</h1>
          <p className="text-secondary">Review queued products before they go live. ({products.length} pending)</p>
        </div>
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Product Name</th><th>Brand</th><th>Price</th><th>Stock</th><th>Category</th><th>Actions</th></tr></thead>
            <tbody>
              {products.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No pending products 🎉</td></tr>
              ) : products.map(p => (
                <tr key={p._id}>
                  <td style={{ fontWeight: '600' }}>{p.name}</td>
                  <td>{p.brand || '—'}</td>
                  <td style={{ fontWeight: '600' }}>NPR {p.pricePerUnit}</td>
                  <td>{p.stock} {p.unit || 'units'}</td>
                  <td><span className="badge badge-neutral">{p.deliveryCategory || '—'}</span></td>
                  <td>
                    <div style={{ display: 'flex', gap: '8px' }}>
                      <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleApprove(p._id)}>✓ Approve</button>
                      <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }} onClick={() => handleHide(p._id)}>✕ Hide</button>
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

export default ProductApproval;
