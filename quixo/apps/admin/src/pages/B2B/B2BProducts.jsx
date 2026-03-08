import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({ baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://127.0.0.1:5000/api/admin' });
API.interceptors.request.use((c) => { const t = localStorage.getItem('adminToken'); if (t) c.headers.Authorization = `Bearer ${t}`; return c; });

const B2BProducts = () => {
    const [products, setProducts] = useState([]);
    const [manufacturers, setManufacturers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [editId, setEditId] = useState(null);
    const [form, setForm] = useState({ manufacturerId: '', name: '', description: '', category: '', unit: 'pcs', wholesalePrice: '', retailPrice: '', moq: 1, stock: 0, tags: '' });

    useEffect(() => {
        Promise.all([
            API.get('/b2b/products').then(r => setProducts(r.data.data || [])),
            API.get('/manufacturers').then(r => setManufacturers(r.data.data || [])),
        ]).finally(() => setLoading(false));
    }, []);

    const fetchProducts = async () => {
        const { data } = await API.get('/b2b/products');
        setProducts(data.data || []);
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const payload = { ...form, wholesalePrice: Number(form.wholesalePrice), retailPrice: Number(form.retailPrice) || undefined, moq: Number(form.moq), stock: Number(form.stock), tags: form.tags ? form.tags.split(',').map(t => t.trim()) : [] };
        try {
            if (editId) await API.put(`/b2b/products/${editId}`, payload);
            else await API.post('/b2b/products', payload);
            setShowForm(false); setEditId(null); setForm({ manufacturerId: '', name: '', description: '', category: '', unit: 'pcs', wholesalePrice: '', retailPrice: '', moq: 1, stock: 0, tags: '' });
            fetchProducts();
        } catch (err) { alert(err.response?.data?.message || 'Failed to save'); }
    };

    const handleEdit = (p) => {
        setForm({ ...p, manufacturerId: p.manufacturerId?._id || p.manufacturerId, tags: (p.tags || []).join(', '), wholesalePrice: p.wholesalePrice, retailPrice: p.retailPrice || '' });
        setEditId(p._id); setShowForm(true);
    };

    const handleDelete = async (id) => {
        if (!confirm('Delete this product?')) return;
        try { await API.delete(`/b2b/products/${id}`); fetchProducts(); }
        catch (err) { alert('Failed to delete'); }
    };

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1400px', margin: '0 auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                <div>
                    <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }}>📦 Wholesale Catalog</h1>
                    <p style={{ color: 'var(--text-secondary)' }}>{products.length} products from {manufacturers.length} manufacturers</p>
                </div>
                <div style={{ display: 'flex', gap: '12px' }}>
                    <Link to="/b2b"><button className="btn btn-outline">← B2B Dashboard</button></Link>
                    <button className="btn btn-primary" onClick={() => { setShowForm(!showForm); setEditId(null); setForm({ manufacturerId: '', name: '', description: '', category: '', unit: 'pcs', wholesalePrice: '', retailPrice: '', moq: 1, stock: 0, tags: '' }); }}>
                        {showForm ? 'Cancel' : '+ Add Product'}
                    </button>
                </div>
            </div>

            {/* Add/Edit Form */}
            {showForm && (
                <div className="card" style={{ marginBottom: '24px' }}>
                    <h3 style={{ marginBottom: '20px' }}>{editId ? 'Edit' : 'Add'} Wholesale Product</h3>
                    <form onSubmit={handleSubmit}>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                            <div>
                                <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>Manufacturer *</label>
                                <select className="form-input" value={form.manufacturerId} onChange={e => setForm({ ...form, manufacturerId: e.target.value })} required>
                                    <option value="">Select manufacturer</option>
                                    {manufacturers.map(m => <option key={m._id} value={m._id}>{m.name}</option>)}
                                </select>
                            </div>
                            {[
                                { key: 'name', label: 'Product Name *', required: true },
                                { key: 'category', label: 'Category *', required: true },
                                { key: 'wholesalePrice', label: 'Wholesale Price (NPR) *', type: 'number', required: true },
                                { key: 'retailPrice', label: 'Suggested Retail Price (NPR)', type: 'number' },
                                { key: 'moq', label: 'Minimum Order Qty', type: 'number' },
                                { key: 'stock', label: 'Available Stock', type: 'number' },
                            ].map(f => (
                                <div key={f.key}>
                                    <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>{f.label}</label>
                                    <input className="form-input" type={f.type || 'text'} value={form[f.key]} onChange={e => setForm({ ...form, [f.key]: e.target.value })} required={f.required} />
                                </div>
                            ))}
                            <div>
                                <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>Unit</label>
                                <select className="form-input" value={form.unit} onChange={e => setForm({ ...form, unit: e.target.value })}>
                                    {['pcs', 'kg', 'litre', 'carton', 'dozen', 'box'].map(u => <option key={u} value={u}>{u}</option>)}
                                </select>
                            </div>
                            <div style={{ gridColumn: '1 / -1' }}>
                                <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>Tags (comma-separated)</label>
                                <input className="form-input" value={form.tags} onChange={e => setForm({ ...form, tags: e.target.value })} placeholder="e.g. organic, bulk, wholesale" />
                            </div>
                            <div style={{ gridColumn: '1 / -1' }}>
                                <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>Description</label>
                                <textarea className="form-input" value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} rows={3} />
                            </div>
                        </div>
                        <button type="submit" className="btn btn-primary" style={{ marginTop: '20px', padding: '10px 30px' }}>{editId ? 'Update' : 'Add'} Product</button>
                    </form>
                </div>
            )}

            {/* Product Grid */}
            {loading ? <div style={{ textAlign: 'center', padding: '60px' }}>Loading...</div> : products.length === 0 ? (
                <div className="card" style={{ textAlign: 'center', padding: '60px' }}>
                    <div style={{ fontSize: '2rem', marginBottom: '12px' }}>📦</div>
                    <h3>No wholesale products yet</h3>
                    <p style={{ color: 'var(--text-secondary)' }}>Add products from manufacturers to build your B2B catalog</p>
                </div>
            ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(320px, 1fr))', gap: '20px' }}>
                    {products.map(p => (
                        <div key={p._id} className="card" style={{ padding: '20px' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: '12px' }}>
                                <div>
                                    <h3 style={{ fontSize: '1.1rem', margin: 0 }}>{p.name}</h3>
                                    <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{p.manufacturerId?.name || 'Manufacturer'}</span>
                                </div>
                                <span className="badge badge-info">{p.category}</span>
                            </div>
                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginBottom: '12px' }}>
                                <div><div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Wholesale</div><div style={{ fontWeight: '800', color: 'var(--primary)' }}>NPR {p.wholesalePrice}</div></div>
                                <div><div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Retail MRP</div><div style={{ fontWeight: '600' }}>NPR {p.retailPrice || '-'}</div></div>
                                <div><div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>MOQ</div><div style={{ fontWeight: '600' }}>{p.moq} {p.unit}</div></div>
                                <div><div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Stock</div><div style={{ fontWeight: '600', color: p.stock < 10 ? 'var(--danger)' : 'var(--text-primary)' }}>{p.stock} {p.unit}</div></div>
                            </div>
                            {p.margin && <div style={{ fontSize: '0.8rem', color: 'var(--success)', fontWeight: '600', marginBottom: '12px' }}>💰 {p.margin}% margin</div>}
                            <div style={{ display: 'flex', gap: '8px' }}>
                                <button className="btn btn-outline" style={{ flex: 1, padding: '6px', fontSize: '0.85rem' }} onClick={() => handleEdit(p)}>Edit</button>
                                <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem', color: 'var(--danger)' }} onClick={() => handleDelete(p._id)}>Delete</button>
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default B2BProducts;
