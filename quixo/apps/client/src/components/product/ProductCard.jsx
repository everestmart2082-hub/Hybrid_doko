import React from 'react';
import { Link } from 'react-router-dom';

const ProductCard = ({ product, isQuick = true }) => {
    const finalPrice = product.discount
        ? product.price - (product.price * product.discount / 100)
        : product.price;

    return (
        <Link to={`/products/${product.id}`} style={{ textDecoration: 'none' }}>
            <div style={styles.card} className="product-card-hover">

                {/* Badges */}
                {product.discount > 0 && (
                    <span style={{ ...styles.discountBadge, backgroundColor: isQuick ? 'var(--secondary)' : '#dc2626' }}>
                        {product.discount}% OFF
                    </span>
                )}

                {/* Quick/Eco indicator */}
                <span style={{ ...styles.deliveryBadge, backgroundColor: isQuick ? '#fff7ed' : '#f0fdfa', color: isQuick ? '#c2410c' : '#0f766e' }}>
                    {isQuick ? '⚡ 15 min' : '📦 2-3 days'}
                </span>

                {/* Image Area */}
                <div style={styles.imageArea}>
                    {product.image ? (
                        <span style={{ fontSize: '4.5rem' }}>{product.image}</span>
                    ) : (
                        <img src={product.photos?.[0] || ''} alt={product.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    )}
                </div>

                {/* Body */}
                <div style={styles.body}>
                    {product.brand && <p style={styles.brand}>{product.brand}</p>}
                    <h3 style={styles.name}>{product.name}</h3>

                    {/* Rating */}
                    <div style={styles.ratingRow}>
                        <span style={{ color: '#f59e0b' }}>⭐</span>
                        <span style={styles.ratingText}>{product.rating || '4.5'}</span>
                        {product.weight && <span style={styles.unit}> · {product.weight}</span>}
                    </div>

                    {/* Price Row */}
                    <div style={styles.priceRow}>
                        <div>
                            <span style={styles.price}>NPR {Math.round(finalPrice)}</span>
                            {product.discount > 0 && (
                                <span style={styles.oldPrice}>NPR {product.price}</span>
                            )}
                        </div>
                        <button
                            style={{ ...styles.addBtn, borderColor: isQuick ? '#fed7aa' : '#99f6e4', color: isQuick ? '#c2410c' : '#0f766e', backgroundColor: isQuick ? '#fff7ed' : '#f0fdfa' }}
                            onClick={(e) => { e.preventDefault(); console.log('Add to cart:', product.id); }}
                        >
                            + Add
                        </button>
                    </div>

                    {/* Stock indicator */}
                    {product.stock !== undefined && product.stock <= 5 && product.stock > 0 && (
                        <p style={styles.lowStock}>Only {product.stock} left!</p>
                    )}
                    {product.stock === 0 && (
                        <p style={{ ...styles.lowStock, color: '#dc2626' }}>Out of Stock</p>
                    )}
                </div>
            </div>
        </Link>
    );
};

const styles = {
    card: {
        backgroundColor: 'var(--surface)',
        borderRadius: 'var(--radius-md)',
        overflow: 'hidden',
        boxShadow: 'var(--shadow-sm)',
        border: '1px solid var(--border)',
        position: 'relative',
        display: 'flex',
        flexDirection: 'column',
        height: '100%'
    },
    discountBadge: {
        position: 'absolute', top: '12px', left: '12px',
        color: 'white', padding: '4px 10px', borderRadius: '100px',
        fontSize: '0.75rem', fontWeight: '800', zIndex: 2
    },
    deliveryBadge: {
        position: 'absolute', top: '12px', right: '12px',
        padding: '4px 8px', borderRadius: '100px',
        fontSize: '0.7rem', fontWeight: '800', zIndex: 2
    },
    imageArea: {
        height: '180px', backgroundColor: '#f8fafc',
        display: 'flex', justifyContent: 'center', alignItems: 'center',
        borderBottom: '1px solid var(--border)'
    },
    body: { padding: '16px', display: 'flex', flexDirection: 'column', flex: 1 },
    brand: { fontSize: '0.8rem', color: 'var(--text-secondary)', marginBottom: '4px', fontWeight: '500' },
    name: { fontSize: '1.05rem', fontWeight: '700', color: 'var(--text-primary)', marginBottom: '8px', lineHeight: '1.3', minHeight: '42px' },
    ratingRow: { display: 'flex', alignItems: 'center', gap: '4px', marginBottom: '12px' },
    ratingText: { fontSize: '0.85rem', fontWeight: '600', color: 'var(--text-primary)' },
    unit: { fontSize: '0.8rem', color: 'var(--text-secondary)' },
    priceRow: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: 'auto' },
    price: { fontSize: '1.2rem', fontWeight: '800', color: 'var(--text-primary)' },
    oldPrice: { fontSize: '0.85rem', color: 'var(--text-secondary)', textDecoration: 'line-through', marginLeft: '8px' },
    addBtn: {
        border: '1.5px solid', padding: '6px 16px', borderRadius: '100px',
        fontWeight: '800', fontSize: '0.9rem', cursor: 'pointer', transition: 'all 0.2s', backgroundColor: 'transparent'
    },
    lowStock: { fontSize: '0.8rem', color: '#f59e0b', fontWeight: '700', marginTop: '8px' }
};

export default ProductCard;
