import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({ baseURL: import.meta.env.VITE_ADMIN_API_URL || 'http://127.0.0.1:5000/api/admin' });
API.interceptors.request.use((c) => { const t = localStorage.getItem('adminToken'); if (t) c.headers.Authorization = `Bearer ${t}`; return c; });

const B2BOrders = () => {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [filter, setFilter] = useState('');
    const [selectedOrder, setSelectedOrder] = useState(null);
    const [negotiateMsg, setNegotiateMsg] = useState('');

    useEffect(() => { fetchOrders(); }, [filter]);

    const fetchOrders = async () => {
        try {
            const url = filter ? `/b2b/orders?status=${filter}` : '/b2b/orders';
            const { data } = await API.get(url);
            setOrders(data.data || []);
        } catch (err) { console.error(err); }
        finally { setLoading(false); }
    };

    const handleStatusUpdate = async (id, status) => {
        try { await API.put(`/b2b/orders/${id}`, { status }); fetchOrders(); if (selectedOrder?._id === id) { const { data } = await API.get(`/b2b/orders/${id}`); setSelectedOrder(data.data); } }
        catch (err) { alert(err.response?.data?.message || 'Failed to update'); }
    };

    const handleNegotiate = async (id) => {
        if (!negotiateMsg.trim()) return;
        try { await API.post(`/b2b/orders/${id}/negotiate`, { message: negotiateMsg, by: 'admin' }); setNegotiateMsg(''); const { data } = await API.get(`/b2b/orders/${id}`); setSelectedOrder(data.data); fetchOrders(); }
        catch (err) { alert('Failed to send negotiation'); }
    };

    const statusColors = { pending: '#f59e0b', negotiating: '#8b5cf6', approved: '#3b82f6', rejected: '#ef4444', processing: '#06b6d4', shipped: '#ec4899', delivered: '#10b981', cancelled: '#94a3b8' };

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1400px', margin: '0 auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                <div>
                    <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }}>📋 B2B Orders</h1>
                    <p style={{ color: 'var(--text-secondary)' }}>{orders.length} orders found</p>
                </div>
                <Link to="/b2b"><button className="btn btn-outline">← B2B Dashboard</button></Link>
            </div>

            {/* Filters */}
            <div style={{ display: 'flex', gap: '8px', marginBottom: '24px', flexWrap: 'wrap' }}>
                {['', 'pending', 'negotiating', 'approved', 'processing', 'shipped', 'delivered', 'rejected'].map(s => (
                    <button key={s} className={`btn ${filter === s ? 'btn-primary' : 'btn-outline'}`} style={{ padding: '6px 14px', fontSize: '0.85rem' }} onClick={() => setFilter(s)}>
                        {s || 'All'}
                    </button>
                ))}
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: selectedOrder ? '1fr 1fr' : '1fr', gap: '24px' }}>
                {/* Orders List */}
                <div>
                    {loading ? <div style={{ textAlign: 'center', padding: '40px' }}>Loading...</div> : orders.length === 0 ? (
                        <div className="card" style={{ textAlign: 'center', padding: '60px' }}><h3>No orders found</h3></div>
                    ) : (
                        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                            {orders.map(order => (
                                <div key={order._id} className="card" style={{ padding: '16px', cursor: 'pointer', border: selectedOrder?._id === order._id ? '2px solid var(--primary)' : '1px solid var(--border)' }} onClick={() => setSelectedOrder(order)}>
                                    <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                                        <div>
                                            <span style={{ fontWeight: '700' }}>#{order._id?.slice(-6).toUpperCase()}</span>
                                            <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem', marginLeft: '8px' }}>{order.vendorId?.storeName || 'Vendor'}</span>
                                        </div>
                                        <span style={{ padding: '4px 12px', borderRadius: '100px', fontSize: '0.75rem', fontWeight: '600', backgroundColor: `${statusColors[order.status]}20`, color: statusColors[order.status], textTransform: 'capitalize' }}>
                                            {order.status}
                                        </span>
                                    </div>
                                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
                                        <span>{order.items?.length || 0} items</span>
                                        <span style={{ fontWeight: '700', color: 'var(--text-primary)' }}>NPR {(order.total || 0).toLocaleString()}</span>
                                    </div>
                                </div>
                            ))}
                        </div>
                    )}
                </div>

                {/* Order Detail Panel */}
                {selectedOrder && (
                    <div className="card" style={{ position: 'sticky', top: '20px', maxHeight: '85vh', overflowY: 'auto' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>
                            <h3 style={{ margin: 0 }}>Order #{selectedOrder._id?.slice(-6).toUpperCase()}</h3>
                            <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '0.8rem' }} onClick={() => setSelectedOrder(null)}>✕</button>
                        </div>

                        <div style={{ marginBottom: '16px' }}>
                            <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>Vendor</div>
                            <div style={{ fontWeight: '600' }}>{selectedOrder.vendorId?.storeName || 'Vendor'}</div>
                            <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>{selectedOrder.vendorId?.contact}</div>
                        </div>

                        <h4 style={{ marginBottom: '12px' }}>Items</h4>
                        {(selectedOrder.items || []).map((item, i) => (
                            <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid var(--border)' }}>
                                <div><div style={{ fontWeight: '600' }}>{item.name}</div><div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>×{item.qty} @ NPR {item.unitPrice}</div></div>
                                <span style={{ fontWeight: '600' }}>NPR {(item.total || 0).toLocaleString()}</span>
                            </div>
                        ))}
                        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', color: 'var(--text-secondary)', fontSize: '0.9rem' }}><span>Subtotal</span><span>NPR {(selectedOrder.subTotal || 0).toLocaleString()}</span></div>
                        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', color: 'var(--text-secondary)', fontSize: '0.9rem' }}><span>Platform Fee (5%)</span><span>NPR {(selectedOrder.platformFee || 0).toLocaleString()}</span></div>
                        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 0', fontWeight: '800', fontSize: '1.1rem', borderTop: '2px solid var(--border)', marginTop: '4px' }}><span>Total</span><span>NPR {(selectedOrder.total || 0).toLocaleString()}</span></div>

                        {/* Status Actions */}
                        <div style={{ marginTop: '16px', marginBottom: '16px' }}>
                            <div style={{ fontSize: '0.85rem', fontWeight: '600', marginBottom: '8px' }}>Update Status</div>
                            <div style={{ display: 'flex', gap: '6px', flexWrap: 'wrap' }}>
                                {['approved', 'processing', 'shipped', 'delivered', 'rejected'].map(s => (
                                    <button key={s} className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '0.8rem', color: statusColors[s], borderColor: statusColors[s], textTransform: 'capitalize' }}
                                        onClick={() => handleStatusUpdate(selectedOrder._id, s)}>{s}</button>
                                ))}
                            </div>
                        </div>

                        {/* Negotiation Thread */}
                        <div style={{ marginTop: '16px', borderTop: '1px solid var(--border)', paddingTop: '16px' }}>
                            <h4 style={{ marginBottom: '12px' }}>💬 Negotiation</h4>
                            {(selectedOrder.negotiation || []).map((n, i) => (
                                <div key={i} style={{ padding: '8px 12px', marginBottom: '8px', borderRadius: 'var(--radius-sm)', backgroundColor: n.by === 'admin' ? '#eff6ff' : '#f1f5f9', borderLeft: n.by === 'admin' ? '3px solid #3b82f6' : '3px solid #94a3b8' }}>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>{n.by} • {new Date(n.date).toLocaleString()}</div>
                                    <div style={{ fontSize: '0.9rem' }}>{n.message}</div>
                                    {n.newPrice && <div style={{ fontWeight: '600', color: 'var(--primary)', marginTop: '4px' }}>Proposed price: NPR {n.newPrice}</div>}
                                </div>
                            ))}
                            <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                                <input className="form-input" value={negotiateMsg} onChange={e => setNegotiateMsg(e.target.value)} placeholder="Send a message..." style={{ flex: 1 }} />
                                <button className="btn btn-primary" style={{ padding: '8px 16px' }} onClick={() => handleNegotiate(selectedOrder._id)}>Send</button>
                            </div>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
};

export default B2BOrders;
