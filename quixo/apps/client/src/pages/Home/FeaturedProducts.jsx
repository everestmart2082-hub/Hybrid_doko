import React, { useState, useEffect, useContext } from 'react';
import { useNavigate } from 'react-router-dom';
import { productAPI } from '../../services/api';
import { CartContext } from '../../context/CartContext';

const FeaturedProducts = ({ mode = 'quick' }) => {
  const [products, setProducts] = useState([]);
  const isQuick = mode === 'quick';
  const navigate = useNavigate();
  const cartContext = useContext(CartContext);
  const addToCart = cartContext?.addToCart;

  useEffect(() => {
    productAPI.getAll({ deliveryType: mode, limit: 4 })
      .then(res => setProducts(res.data.message || res.data.data || []))
      .catch(() => { });
  }, [mode]);

  if (products.length === 0) return null;

  return (
    <section className="container section">
      <div style={styles.header}>
        <h2 style={styles.title}>
          {isQuick ? 'Essentials You Need Right Now' : 'Trending on Doko Marketplace'}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {isQuick ? 'Fresh items delivered to you in 15 mins' : 'Top-rated products from verified vendors'}
        </p>
      </div>

      <div style={styles.grid}>
        {products.map((product) => (
          <div key={product._id} style={styles.card} className="animate-fade-in product-card-hover" onClick={() => navigate(`/products/${product._id}`)}>
            {product.discount > 0 && (
              <span style={{
                ...styles.badge,
                backgroundColor: isQuick ? 'var(--primary)' : 'var(--secondary)'
              }}>
                {product.discount}% OFF
              </span>
            )}

            <div style={styles.imagePlaceholder}>
              {(product.photos?.[0] || product.images?.[0])
                ? <img src={product.photos?.[0] || product.images?.[0]} alt={product.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                : <span style={{ fontSize: '4rem' }}>{isQuick ? '🛒' : '📦'}</span>
              }
              <div style={styles.deliveryBadge}>
                {isQuick ? '🚚 15 Min' : '📦 2-3 Days'}
              </div>
            </div>

            <div style={styles.cardBody}>
              <div style={styles.weight}>{product.deliveryCategory || product.category}</div>
              <h3 style={styles.name}>{product.name}</h3>
              <div style={styles.priceRow}>
                <div style={styles.priceBlock}>
                  <span style={styles.price}>Rs. {product.pricePerUnit || product.price}</span>
                </div>
                <button style={{
                  ...styles.addBtn,
                  backgroundColor: isQuick ? '#fff7ed' : '#f0fdfa',
                  color: isQuick ? 'var(--primary-dark)' : '#0f766e',
                  borderColor: isQuick ? '#fed7aa' : '#99f6e4'
                }}
                  onClick={(e) => { e.stopPropagation(); addToCart && addToCart(product._id, 1); }}
                >Add</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};

const styles = {
  header: { marginBottom: '40px', textAlign: 'center' },
  title: { fontSize: '2.2rem', color: 'var(--text-primary)', marginBottom: '8px' },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(240px, 1fr))', gap: '24px' },
  card: { backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-md)', overflow: 'hidden', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)', position: 'relative', transition: 'all 0.3s ease', cursor: 'pointer' },
  badge: { position: 'absolute', top: '12px', left: '12px', color: 'white', padding: '4px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.75rem', fontWeight: '700', zIndex: '1' },
  imagePlaceholder: { height: '200px', backgroundColor: '#f8fafc', display: 'flex', justifyContent: 'center', alignItems: 'center', borderBottom: '1px solid var(--border)', position: 'relative', overflow: 'hidden' },
  deliveryBadge: { position: 'absolute', bottom: '8px', right: '8px', backgroundColor: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(4px)', padding: '4px 8px', borderRadius: 'var(--radius-sm)', fontSize: '0.75rem', fontWeight: '800', color: 'var(--text-primary)', boxShadow: 'var(--shadow-sm)' },
  cardBody: { padding: '20px' },
  weight: { color: 'var(--text-secondary)', fontSize: '0.85rem', marginBottom: '8px', fontWeight: '500' },
  name: { fontSize: '1.1rem', fontWeight: '600', marginBottom: '16px', color: 'var(--text-primary)', minHeight: '44px', lineHeight: '1.3' },
  priceRow: { display: 'flex', justifyContent: 'space-between', alignItems: 'center' },
  priceBlock: { display: 'flex', flexDirection: 'column' },
  price: { fontSize: '1.25rem', fontWeight: '800', color: 'var(--text-primary)' },
  addBtn: { border: '1px solid', padding: '8px 24px', borderRadius: '100px', fontWeight: '700', fontSize: '1rem', cursor: 'pointer', transition: 'all 0.2s' }
};

export default FeaturedProducts;
