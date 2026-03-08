import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const ProductList = () => {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    axios.post(`${API_BASE}/admin/product/all`, { token: getToken(), type: 'normal' })
      .then(res => setProducts(res.data.message || []))
      .catch(() => { }).finally(() => setLoading(false));
  }, []);

  const handleHide = async (id, hide) => {
    try {
      await axios.post(`${API_BASE}/admin/product/hide`, { token: getToken(), 'product id': id, suspend: hide });
      setProducts(prev => prev.map(p => p._id === id ? { ...p, hidden: hide } : p));
    } catch (e) { alert('Failed'); }
  };

  const filtered = products.filter(p =>
    (p.name || '').toLowerCase().includes(search.toLowerCase()) ||
    (p.brand || '').toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Global Product Inventory</h1>
          <p className="text-secondary">View and manage all approved products. ({products.length} total)</p>
        </div>
        <input type="text" className="form-input" placeholder="Search product name or brand..." style={{ width: '300px' }} value={search} onChange={e => setSearch(e.target.value)} />
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Product Name</th><th>Brand</th><th>Price</th><th>Stock</th><th>Delivery</th><th>Status</th><th>Actions</th></tr></thead>
            <tbody>
              {filtered.length === 0 ? (
                <tr><td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>No products found.</td></tr>
              ) : filtered.map(p => (
                <tr key={p._id}>
                  <td style={{ fontWeight: '600' }}>{p.name}</td>
                  <td>{p.brand || '—'}</td>
                  <td style={{ fontWeight: '600' }}>NPR {p.pricePerUnit}</td>
                  <td><span style={{ color: p.stock === 0 ? 'var(--danger)' : p.stock < 20 ? 'var(--warning)' : 'inherit' }}>{p.stock} {p.unit || 'units'}</span></td>
                  <td><span className="badge badge-neutral">{p.deliveryCategory || '—'}</span></td>
                  <td><span className={`badge ${p.hidden ? 'badge-danger' : 'badge-success'}`}>{p.hidden ? 'Hidden' : 'Active'}</span></td>
                  <td>
                    <button className={`btn ${p.hidden ? 'btn-success' : 'btn-danger'}`} style={{ padding: '4px 8px', fontSize: '0.8rem' }} onClick={() => handleHide(p._id, !p.hidden)}>
                      {p.hidden ? 'Unhide' : 'Hide'}
                    </button>
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

export default ProductList;
