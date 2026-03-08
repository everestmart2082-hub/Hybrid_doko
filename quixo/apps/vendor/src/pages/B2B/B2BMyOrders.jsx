import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({ baseURL: import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api/vender' });
API.interceptors.request.use((c) => { const t = localStorage.getItem('vendorToken') || localStorage.getItem('token'); if (t) c.headers.Authorization = `Bearer ${t}`; return c; });

const B2BMyOrders = () => {
    const [orders, setOrders] = useState([]);
    const [loading, setLoading] = useState(true);
    const [selected, setSelected] = useState(null);
    const [negotiateMsg, setNegotiateMsg] = useState('');

    useEffect(() => { fetchOrders(); }, []);

    const fetchOrders = async () => {
        try { const { data } = await API.get('/b2b/orders'); setOrders(data.data || []); }
        catch (err) { console.error(err); }
        finally { setLoading(false); }
    };

    const handleNegotiate = async (id) => {
        if (!negotiateMsg.trim()) return;
        try { await API.post(`/b2b/orders/${id}/negotiate`, { message: negotiateMsg, by: 'vendor' }); setNegotiateMsg(''); const { data } = await API.get(`/b2b/orders/${id}`); setSelected(data.data); fetchOrders(); }
        catch (err) { alert('Failed to send message'); }
    };

    const statusColors = { pending: '#f59e0b', negotiating: '#8b5cf6', approved: '#3b82f6', rejected: '#ef4444', processing: '#06b6d4', shipped: '#ec4899', delivered: '#10b981', cancelled: '#94a3b8' };
    const statusIcons = { pending: '⏳', negotiating: '💬', approved: '✅', rejected: '❌', processing: '⚙️', shipped: '🚚', delivered: '📦', cancelled: '🚫' };

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                <div>
                    <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }}>📋 My B2B Orders</h1>
                    <p style={{ color: 'var(--text-secondary)' }}>{orders.length} bulk orders submitted</p>
                </div>
                <Link to="/b2b/marketplace"><button className="btn btn-primary">🏭 Browse Catalog</button></Link>
            </div>

            {loading ? <div style={{ textAlign: 'center', padding: '60px' }}>Loading...</div> : orders.length === 0 ? (
                <div className="card" style={{ textAlign: 'center', padding: '60px' }}>
                    <div style={{ fontSize: '3rem', marginBottom: '12px' }}>🏭</div>
                    <h3>No B2B orders yet</h3>
                    <p style={{ color: 'var(--text-secondary)', marginBottom: '16px' }}>Browse the wholesale marketplace and place your first bulk order</p>
                    <Link to="/b2b/marketplace"><button className="btn btn-primary">Browse Catalog</button></Link>
                </div>
            ) : (
                <div style={{ display: 'grid', gridTemplateColumns: selected ? '1fr 1fr' : '1fr', gap: '24px' }}>
                    {/* Orders List */}
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
                        {orders.map(order => (
                            <div key={order._id} className="card" style={{ padding: '20px', cursor: 'pointer', border: selected?._id === order._id ? '2px solid var(--primary)' : '1px solid var(--border)', transition: 'var(--transition)' }}
                                onClick={async () => { try { const { data } = await API.get(`/b2b/orders/${order._id}`); setSelected(data.data); } catch (e) { setSelected(order); } }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
                                    <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                                        <span style={{ fontSize: '1.2rem' }}>{statusIcons[order.status] || '📋'}</span>
                                        <span style={{ fontWeight: '700' }}>#{order._id?.slice(-6).toUpperCase()}</span>
                                    </div>
                                    <span style={{ padding: '4px 12px', borderRadius: '100px', fontSize: '0.75rem', fontWeight: '600', backgroundColor: `${statusColors[order.status]}20`, color: statusColors[order.status], textTransform: 'capitalize' }}>
                                        {order.status}
                                    </span>
                                </div>
                                <div style={{ display: 'flex', justifyContent: 'space-between', color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
                                    <span>{order.items?.length || 0} items • {new Date(order.createdAt).toLocaleDateString()}</span>
                                    <span style={{ fontWeight: '700', color: 'var(--text-primary)' }}>NPR {(order.total || 0).toLocaleString()}</span>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Detail Panel */}
                    {selected && (
                        <div className="card" style={{ position: 'sticky', top: '20px', maxHeight: '85vh', overflowY: 'auto' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>
                                <h3 style={{ margin: 0 }}>Order #{selected._id?.slice(-6).toUpperCase()}</h3>
                                <button className="btn btn-outline" style={{ padding: '4px 10px', fontSize: '0.8rem' }} onClick={() => setSelected(null)}>✕</button>
                            </div>

                            <div style={{ padding: '10px 14px', borderRadius: 'var(--radius-sm)', backgroundColor: `${statusColors[selected.status]}15`, color: statusColors[selected.status], fontWeight: '600', textTransform: 'capitalize', textAlign: 'center', marginBottom: '16px' }}>
                                {statusIcons[selected.status]} {selected.status}
                            </div>

                            {selected.expectedDelivery && (
                                <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '12px' }}>📅 Expected delivery: {new Date(selected.expectedDelivery).toLocaleDateString()}</div>
                            )}

                            <h4 style={{ marginBottom: '8px' }}>Items</h4>
                            {(selected.items || []).map((item, i) => (
                                <div key={i} style={{ display: 'flex', justifyContent: 'space-between', padding: '8px 0', borderBottom: '1px solid var(--border)' }}>
                                    <div><div style={{ fontWeight: '600' }}>{item.name}</div><div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>×{item.qty} @ NPR {item.unitPrice}</div></div>
                                    <span style={{ fontWeight: '600' }}>NPR {(item.total || 0).toLocaleString()}</span>
                                </div>
                            ))}

                            <div style={{ marginTop: '12px', display: 'flex', flexDirection: 'column', gap: '4px' }}>
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem', color: 'var(--text-secondary)' }}><span>Subtotal</span><span>NPR {(selected.subTotal || 0).toLocaleString()}</span></div>
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '0.9rem', color: 'var(--text-secondary)' }}><span>Platform Fee</span><span>NPR {(selected.platformFee || 0).toLocaleString()}</span></div>
                                <div style={{ display: 'flex', justifyContent: 'space-between', fontWeight: '800', fontSize: '1.1rem', paddingTop: '8px', borderTop: '2px solid var(--border)' }}><span>Total</span><span>NPR {(selected.total || 0).toLocaleString()}</span></div>
                            </div>

                            {/* Negotiation Thread */}
                            {(selected.negotiation?.length > 0 || ['pending', 'negotiating'].includes(selected.status)) && (
                                <div style={{ marginTop: '20px', borderTop: '1px solid var(--border)', paddingTop: '16px' }}>
                                    <h4 style={{ marginBottom: '12px' }}>💬 Messages</h4>
                                    {(selected.negotiation || []).map((n, i) => (
                                        <div key={i} style={{ padding: '8px 12px', marginBottom: '8px', borderRadius: 'var(--radius-sm)', backgroundColor: n.by === 'vendor' ? '#eff6ff' : '#f1f5f9', borderLeft: n.by === 'vendor' ? '3px solid #3b82f6' : '3px solid #94a3b8' }}>
                                            <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)', marginBottom: '4px' }}>{n.by === 'vendor' ? 'You' : 'Doko Team'} • {new Date(n.date).toLocaleString()}</div>
                                            <div style={{ fontSize: '0.9rem' }}>{n.message}</div>
                                            {n.newPrice && <div style={{ fontWeight: '600', color: 'var(--primary)', marginTop: '4px' }}>Proposed: NPR {n.newPrice}</div>}
                                        </div>
                                    ))}
                                    {['pending', 'negotiating'].includes(selected.status) && (
                                        <div style={{ display: 'flex', gap: '8px', marginTop: '8px' }}>
                                            <input className="form-input" value={negotiateMsg} onChange={e => setNegotiateMsg(e.target.value)} placeholder="Reply to Doko team..." style={{ flex: 1 }} />
                                            <button className="btn btn-primary" style={{ padding: '8px 16px' }} onClick={() => handleNegotiate(selected._id)}>Send</button>
                                        </div>
                                    )}
                                </div>
                            )}

                            {selected.adminNotes && (
                                <div style={{ marginTop: '16px', padding: '12px', backgroundColor: '#fef3c7', borderRadius: 'var(--radius-sm)', fontSize: '0.85rem', color: '#92400e' }}>
                                    📝 <strong>Admin note:</strong> {selected.adminNotes}
                                </div>
                            )}
                        </div>
                    )}
                </div>
            )}
        </div>
    );
};

export default B2BMyOrders;
