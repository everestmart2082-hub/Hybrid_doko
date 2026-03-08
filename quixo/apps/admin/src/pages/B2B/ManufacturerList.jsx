import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({ baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://localhost:5000/api' });
API.interceptors.request.use((c) => { const t = localStorage.getItem('adminToken'); if (t) c.headers.Authorization = `Bearer ${t}`; return c; });

const ManufacturerList = () => {
    const [manufacturers, setManufacturers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showForm, setShowForm] = useState(false);
    const [form, setForm] = useState({ name: '', contactName: '', phone: '', email: '', address: '', city: '', businessType: '', description: '' });
    const [editId, setEditId] = useState(null);

    useEffect(() => { fetchAll(); }, []);

    const fetchAll = async () => {
        try { const { data } = await API.get('/manufacturers'); setManufacturers(data.data || []); }
        catch (err) { console.error(err); }
        finally { setLoading(false); }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        try {
            if (editId) { await API.put(`/manufacturers/${editId}`, form); }
            else { await API.post('/manufacturers', form); }
            setShowForm(false); setEditId(null); setForm({ name: '', contactName: '', phone: '', email: '', address: '', city: '', businessType: '', description: '' });
            fetchAll();
        } catch (err) { alert(err.response?.data?.message || 'Failed to save'); }
    };

    const handleEdit = (m) => { setForm(m); setEditId(m._id); setShowForm(true); };

    const handleDelete = async (id) => {
        if (!confirm('Delete this manufacturer?')) return;
        try { await API.delete(`/manufacturers/${id}`); fetchAll(); }
        catch (err) { alert('Failed to delete'); }
    };

    const handleStatusToggle = async (m) => {
        const newStatus = m.status === 'active' ? 'suspended' : 'active';
        try { await API.put(`/manufacturers/${m._id}`, { status: newStatus }); fetchAll(); }
        catch (err) { alert('Failed to update status'); }
    };

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                <div>
                    <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }}>🏭 Manufacturers</h1>
                    <p style={{ color: 'var(--text-secondary)' }}>{manufacturers.length} registered manufacturers</p>
                </div>
                <div style={{ display: 'flex', gap: '12px' }}>
                    <Link to="/b2b"><button className="btn btn-outline">← B2B Dashboard</button></Link>
                    <button className="btn btn-primary" onClick={() => { setShowForm(!showForm); setEditId(null); setForm({ name: '', contactName: '', phone: '', email: '', address: '', city: '', businessType: '', description: '' }); }}>
                        {showForm ? 'Cancel' : '+ Add Manufacturer'}
                    </button>
                </div>
            </div>

            {/* Form */}
            {showForm && (
                <div className="card" style={{ marginBottom: '24px' }}>
                    <h3 style={{ marginBottom: '20px' }}>{editId ? 'Edit' : 'Add New'} Manufacturer</h3>
                    <form onSubmit={handleSubmit}>
                        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
                            {[
                                { key: 'name', label: 'Company Name *', required: true },
                                { key: 'contactName', label: 'Contact Person *', required: true },
                                { key: 'phone', label: 'Phone *', required: true },
                                { key: 'email', label: 'Email' },
                                { key: 'city', label: 'City' },
                                { key: 'businessType', label: 'Business Type (e.g. FMCG, Electronics)' },
                                { key: 'address', label: 'Address', full: true },
                                { key: 'description', label: 'Description', full: true },
                            ].map(f => (
                                <div key={f.key} style={f.full ? { gridColumn: '1 / -1' } : {}}>
                                    <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>{f.label}</label>
                                    <input className="form-input" value={form[f.key] || ''} onChange={e => setForm({ ...form, [f.key]: e.target.value })} required={f.required} />
                                </div>
                            ))}
                        </div>
                        <button type="submit" className="btn btn-primary" style={{ marginTop: '20px', padding: '10px 30px' }}>
                            {editId ? 'Update' : 'Create'} Manufacturer
                        </button>
                    </form>
                </div>
            )}

            {/* Table */}
            {loading ? (
                <div style={{ textAlign: 'center', padding: '60px', color: 'var(--text-secondary)' }}>Loading...</div>
            ) : manufacturers.length === 0 ? (
                <div className="card" style={{ textAlign: 'center', padding: '60px' }}>
                    <div style={{ fontSize: '2rem', marginBottom: '12px' }}>🏭</div>
                    <h3>No manufacturers yet</h3>
                    <p style={{ color: 'var(--text-secondary)' }}>Add your first manufacturer to start building the B2B catalog</p>
                </div>
            ) : (
                <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
                    <table className="data-table">
                        <thead>
                            <tr><th>Company</th><th>Contact</th><th>Phone</th><th>Type</th><th>Status</th><th>Actions</th></tr>
                        </thead>
                        <tbody>
                            {manufacturers.map(m => (
                                <tr key={m._id}>
                                    <td><div style={{ fontWeight: '700' }}>{m.name}</div><div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>{m.city}</div></td>
                                    <td>{m.contactName}</td>
                                    <td>{m.phone}</td>
                                    <td><span className="badge badge-info">{m.businessType || '-'}</span></td>
                                    <td>
                                        <span style={{ padding: '4px 10px', borderRadius: '100px', fontSize: '0.8rem', fontWeight: '600', backgroundColor: m.status === 'active' ? '#d1fae5' : '#fee2e2', color: m.status === 'active' ? '#065f46' : '#991b1b' }}>
                                            {m.status}
                                        </span>
                                    </td>
                                    <td>
                                        <div style={{ display: 'flex', gap: '8px' }}>
                                            <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '0.8rem' }} onClick={() => handleEdit(m)}>Edit</button>
                                            <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '0.8rem', color: m.status === 'active' ? 'var(--danger)' : 'var(--success)' }} onClick={() => handleStatusToggle(m)}>
                                                {m.status === 'active' ? 'Suspend' : 'Activate'}
                                            </button>
                                            <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '0.8rem', color: 'var(--danger)' }} onClick={() => handleDelete(m._id)}>Delete</button>
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

export default ManufacturerList;
