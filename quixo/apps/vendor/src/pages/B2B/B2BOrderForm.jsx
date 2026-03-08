import React, { useState } from 'react';
import { useLocation, useNavigate, Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({ baseURL: import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api/vender' });
API.interceptors.request.use((c) => { const t = localStorage.getItem('vendorToken') || localStorage.getItem('token'); if (t) c.headers.Authorization = `Bearer ${t}`; return c; });

const B2BOrderForm = () => {
    const { state } = useLocation();
    const navigate = useNavigate();
    const [submitting, setSubmitting] = useState(false);
    const [deliveryAddress, setDeliveryAddress] = useState('');
    const [notes, setNotes] = useState('');
    const [paymentMethod, setPaymentMethod] = useState('bankTransfer');

    const cart = state?.cart || {};
    const products = state?.products || [];
    const cartProducts = products.filter(p => cart[p._id]);

    if (cartProducts.length === 0) {
        return (
            <div className="container animate-fade-in" style={{ padding: '80px', textAlign: 'center' }}>
                <h2>🛒 Your B2B cart is empty</h2>
                <p style={{ color: 'var(--text-secondary)' }}>Go back to browse and add products.</p>
                <Link to="/b2b/marketplace"><button className="btn btn-primary" style={{ marginTop: '16px' }}>Browse Catalog</button></Link>
            </div>
        );
    }

    const subTotal = cartProducts.reduce((s, p) => s + (p.wholesalePrice * cart[p._id]), 0);
    const platformFee = Math.round(subTotal * 0.05);
    const total = subTotal + platformFee;

    const handleSubmit = async () => {
        if (!deliveryAddress.trim()) { alert('Please enter a delivery address'); return; }
        try {
            setSubmitting(true);
            const items = cartProducts.map(p => ({ productId: p._id, qty: cart[p._id] }));
            await API.post('/b2b/orders', { items, deliveryAddress, notes, paymentMethod });
            alert('✅ B2B order placed successfully! Our team will review it shortly.');
            navigate('/b2b/my-orders');
        } catch (err) { alert(err.response?.data?.message || 'Failed to place order'); }
        finally { setSubmitting(false); }
    };

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1000px', margin: '0 auto' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '30px' }}>
                <Link to="/b2b/marketplace"><button className="btn btn-outline" style={{ width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>←</button></Link>
                <div>
                    <h1 style={{ fontSize: '1.8rem', margin: 0 }}>📋 Review B2B Order</h1>
                    <p style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>{cartProducts.length} products in your order</p>
                </div>
            </div>

            <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px' }}>
                {/* Items */}
                <div>
                    <div className="card" style={{ marginBottom: '20px' }}>
                        <h3 style={{ marginBottom: '16px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>Order Items</h3>
                        {cartProducts.map(p => (
                            <div key={p._id} style={{ display: 'flex', justifyContent: 'space-between', padding: '12px 0', borderBottom: '1px solid var(--border)', alignItems: 'center' }}>
                                <div>
                                    <div style={{ fontWeight: '600' }}>{p.name}</div>
                                    <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>by {p.manufacturerId?.name || 'Manufacturer'} • NPR {p.wholesalePrice}/{p.unit}</div>
                                </div>
                                <div style={{ textAlign: 'right' }}>
                                    <div style={{ fontWeight: '700' }}>× {cart[p._id]} {p.unit}</div>
                                    <div style={{ color: 'var(--primary)', fontWeight: '600' }}>NPR {(p.wholesalePrice * cart[p._id]).toLocaleString()}</div>
                                </div>
                            </div>
                        ))}
                    </div>

                    {/* Delivery & Notes */}
                    <div className="card">
                        <h3 style={{ marginBottom: '16px' }}>Delivery Details</h3>
                        <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', color: 'var(--text-secondary)' }}>Delivery Address *</label>
                        <textarea className="form-input" value={deliveryAddress} onChange={e => setDeliveryAddress(e.target.value)} rows={2} placeholder="Enter your store/warehouse delivery address" required />
                        <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', marginTop: '16px', color: 'var(--text-secondary)' }}>Notes for Doko team (optional)</label>
                        <textarea className="form-input" value={notes} onChange={e => setNotes(e.target.value)} rows={2} placeholder="Any special requests or notes..." />
                        <label style={{ display: 'block', fontSize: '0.85rem', fontWeight: '600', marginBottom: '6px', marginTop: '16px', color: 'var(--text-secondary)' }}>Payment Method</label>
                        <select className="form-input" value={paymentMethod} onChange={e => setPaymentMethod(e.target.value)}>
                            <option value="bankTransfer">Bank Transfer</option>
                            <option value="cashOnDelivery">Cash on Delivery</option>
                            <option value="credit">Credit (Buy Now, Pay Later)</option>
                        </select>
                    </div>
                </div>

                {/* Summary */}
                <div className="card" style={{ position: 'sticky', top: '20px', height: 'fit-content' }}>
                    <h3 style={{ marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '8px' }}>Order Summary</h3>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', marginBottom: '20px' }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between' }}><span style={{ color: 'var(--text-secondary)' }}>Subtotal</span><span>NPR {subTotal.toLocaleString()}</span></div>
                        <div style={{ display: 'flex', justifyContent: 'space-between' }}><span style={{ color: 'var(--text-secondary)' }}>Platform Fee (5%)</span><span>NPR {platformFee.toLocaleString()}</span></div>
                        <div style={{ display: 'flex', justifyContent: 'space-between', fontWeight: '800', fontSize: '1.2rem', paddingTop: '12px', borderTop: '2px solid var(--border)' }}><span>Total</span><span>NPR {total.toLocaleString()}</span></div>
                    </div>

                    <div style={{ backgroundColor: '#eff6ff', padding: '12px', borderRadius: 'var(--radius-sm)', fontSize: '0.85rem', color: '#1e40af', marginBottom: '20px' }}>
                        ℹ️ Our team will review your order and may negotiate pricing for better deals. You'll be notified once approved.
                    </div>

                    <button className="btn btn-primary" style={{ width: '100%', padding: '14px', fontSize: '1.05rem' }} onClick={handleSubmit} disabled={submitting}>
                        {submitting ? 'Placing Order...' : '✅ Submit B2B Order'}
                    </button>
                </div>
            </div>
        </div>
    );
};

export default B2BOrderForm;
