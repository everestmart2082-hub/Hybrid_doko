import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API = axios.create({ baseURL: import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api/vender' });
API.interceptors.request.use((c) => { const t = localStorage.getItem('vendorToken') || localStorage.getItem('token'); if (t) c.headers.Authorization = `Bearer ${t}`; return c; });

const B2BMarketplace = () => {
    const [products, setProducts] = useState([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [category, setCategory] = useState('');
    const [cart, setCart] = useState({}); // { productId: qty }

    useEffect(() => { fetchProducts(); }, [search, category]);

    const fetchProducts = async () => {
        try {
            const params = {};
            if (search) params.search = search;
            if (category) params.category = category;
            const { data } = await API.get('/b2b/products', { params });
            setProducts(data.data || []);
        } catch (err) { console.error(err); }
        finally { setLoading(false); }
    };

    const categories = [...new Set(products.map(p => p.category).filter(Boolean))];
    const cartCount = Object.keys(cart).length;

    const updateQty = (productId, moq, qty) => {
        if (qty < moq) { const newCart = { ...cart }; delete newCart[productId]; setCart(newCart); return; }
        setCart({ ...cart, [productId]: qty });
    };

    return (
        <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '1400px', margin: '0 auto' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
                <div>
                    <h1 style={{ fontSize: '1.8rem', marginBottom: '4px' }}>🏭 B2B Wholesale Marketplace</h1>
                    <p style={{ color: 'var(--text-secondary)' }}>Browse wholesale products and place bulk orders</p>
                </div>
                <div style={{ display: 'flex', gap: '12px' }}>
                    <Link to="/b2b/my-orders"><button className="btn btn-outline">📋 My B2B Orders</button></Link>
                    {cartCount > 0 && (
                        <Link to="/b2b/order" state={{ cart, products }}>
                            <button className="btn btn-primary">🛒 Cart ({cartCount}) — Place Order</button>
                        </Link>
                    )}
                </div>
            </div>

            {/* Search & Filter */}
            <div style={{ display: 'flex', gap: '12px', marginBottom: '24px' }}>
                <input className="form-input" style={{ flex: 1 }} placeholder="Search products..." value={search} onChange={e => setSearch(e.target.value)} />
                <select className="form-input" style={{ width: '200px' }} value={category} onChange={e => setCategory(e.target.value)}>
                    <option value="">All Categories</option>
                    {categories.map(c => <option key={c} value={c}>{c}</option>)}
                </select>
            </div>

            {/* Product Grid */}
            {loading ? <div style={{ textAlign: 'center', padding: '60px' }}>Loading catalog...</div> : products.length === 0 ? (
                <div className="card" style={{ textAlign: 'center', padding: '60px' }}>
                    <div style={{ fontSize: '2rem', marginBottom: '12px' }}>📦</div>
                    <h3>No products available</h3>
                    <p style={{ color: 'var(--text-secondary)' }}>Check back later for wholesale deals from our partners</p>
                </div>
            ) : (
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))', gap: '20px' }}>
                    {products.map(p => (
                        <div key={p._id} className="card" style={{ padding: '20px', border: cart[p._id] ? '2px solid var(--primary)' : '1px solid var(--border)' }}>
                            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px' }}>
                                <div>
                                    <h3 style={{ fontSize: '1.1rem', margin: 0 }}>{p.name}</h3>
                                    <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>by {p.manufacturerId?.name || 'Manufacturer'}</span>
                                </div>
                                <span className="badge badge-info" style={{ height: 'fit-content' }}>{p.category}</span>
                            </div>

                            {p.description && <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '12px' }}>{p.description}</p>}

                            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '8px', marginBottom: '16px' }}>
                                <div>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Wholesale Price</div>
                                    <div style={{ fontSize: '1.3rem', fontWeight: '800', color: 'var(--primary)' }}>NPR {p.wholesalePrice}</div>
                                </div>
                                {p.retailPrice && (
                                    <div>
                                        <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Retail MRP</div>
                                        <div style={{ fontSize: '1.1rem', fontWeight: '600', color: 'var(--text-secondary)', textDecoration: 'line-through' }}>NPR {p.retailPrice}</div>
                                    </div>
                                )}
                                <div>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Min Order</div>
                                    <div style={{ fontWeight: '600' }}>{p.moq} {p.unit}</div>
                                </div>
                                <div>
                                    <div style={{ fontSize: '0.75rem', color: 'var(--text-secondary)' }}>Available</div>
                                    <div style={{ fontWeight: '600', color: p.stock < 10 ? 'var(--danger)' : 'inherit' }}>{p.stock} {p.unit}</div>
                                </div>
                            </div>

                            {p.margin && <div style={{ fontSize: '0.85rem', color: 'var(--success)', fontWeight: '600', marginBottom: '12px' }}>💰 Your margin: ~{p.margin}%</div>}

                            <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
                                {cart[p._id] ? (
                                    <>
                                        <button className="btn btn-outline" style={{ width: '36px', height: '36px', padding: 0 }} onClick={() => updateQty(p._id, p.moq, (cart[p._id] || 0) - 1)}>-</button>
                                        <input type="number" className="form-input" style={{ width: '80px', textAlign: 'center', fontWeight: '700' }} value={cart[p._id] || ''} onChange={e => updateQty(p._id, p.moq, Number(e.target.value))} min={p.moq} />
                                        <button className="btn btn-outline" style={{ width: '36px', height: '36px', padding: 0 }} onClick={() => updateQty(p._id, p.moq, (cart[p._id] || 0) + 1)}>+</button>
                                        <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginLeft: '8px' }}>{p.unit}</span>
                                    </>
                                ) : (
                                    <button className="btn btn-primary" style={{ width: '100%' }} onClick={() => setCart({ ...cart, [p._id]: p.moq })} disabled={p.stock < p.moq}>
                                        {p.stock < p.moq ? 'Out of Stock' : `+ Add to Order (min ${p.moq})`}
                                    </button>
                                )}
                            </div>
                        </div>
                    ))}
                </div>
            )}
        </div>
    );
};

export default B2BMarketplace;
