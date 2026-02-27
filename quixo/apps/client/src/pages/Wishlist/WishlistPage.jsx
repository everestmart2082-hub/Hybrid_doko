import React from 'react';
import { Link } from 'react-router-dom';

const mockWishlist = [
  { id: 1, name: 'Fresh Organic Apples', price: 290, oldPrice: 350, image: '🍎', type: 'quick', rating: '4.8' },
  { id: 11, name: 'Wireless Bluetooth Earbuds', price: 3499, oldPrice: 4999, image: '🎧', type: 'ecommerce', rating: '4.5' },
  { id: 6, name: 'Broccoli', price: 150, oldPrice: null, image: '🥦', type: 'quick', rating: '4.2' },
];

const WishlistPage = () => {
  return (
    <div className="container animate-fade-in" style={{ paddingTop: '40px', paddingBottom: '80px', minHeight: 'calc(100vh - 70px)' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2.2rem', margin: 0 }}>My Wishlist</h1>
          <p style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>{mockWishlist.length} saved items</p>
        </div>
      </div>

      {mockWishlist.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '80px 20px' }}>
          <div style={{ fontSize: '5rem', marginBottom: '20px' }}>💔</div>
          <h2 style={{ marginBottom: '12px' }}>Your wishlist is empty</h2>
          <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>Browse products and tap the heart icon to save items here.</p>
          <Link to="/products"><button className="btn btn-primary">Browse Products</button></Link>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '24px' }}>
          {mockWishlist.map(item => (
            <div key={item.id} className="product-card-hover" style={{
              backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-md)',
              overflow: 'hidden', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)',
              position: 'relative'
            }}>
              {/* Remove Button */}
              <button style={{ position: 'absolute', top: '12px', right: '12px', background: 'white', border: 'none', borderRadius: '50%', width: '36px', height: '36px', fontSize: '1.1rem', cursor: 'pointer', boxShadow: 'var(--shadow-sm)', zIndex: 2 }}>
                ❌
              </button>

              {/* Delivery Badge */}
              <span style={{ position: 'absolute', top: '12px', left: '12px', padding: '4px 8px', borderRadius: '100px', fontSize: '0.7rem', fontWeight: '800', zIndex: 2, backgroundColor: item.type === 'quick' ? '#fff7ed' : '#f0fdfa', color: item.type === 'quick' ? '#c2410c' : '#0f766e' }}>
                {item.type === 'quick' ? '⚡ 15 min' : '📦 2-3 days'}
              </span>

              <div style={{ height: '180px', backgroundColor: '#f8fafc', display: 'flex', justifyContent: 'center', alignItems: 'center', borderBottom: '1px solid var(--border)' }}>
                <span style={{ fontSize: '5rem' }}>{item.image}</span>
              </div>

              <div style={{ padding: '16px' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '4px', marginBottom: '8px' }}>
                  <span style={{ color: '#f59e0b' }}>⭐</span>
                  <span style={{ fontSize: '0.85rem', fontWeight: '600' }}>{item.rating}</span>
                </div>
                <h3 style={{ fontSize: '1.05rem', fontWeight: '700', marginBottom: '12px', minHeight: '42px', lineHeight: '1.3' }}>{item.name}</h3>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                  <div>
                    <span style={{ fontSize: '1.2rem', fontWeight: '800' }}>NPR {item.price}</span>
                    {item.oldPrice && <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', textDecoration: 'line-through', marginLeft: '8px' }}>NPR {item.oldPrice}</span>}
                  </div>
                  <button className="btn btn-primary" style={{ padding: '8px 16px', fontSize: '0.85rem' }}>Add to Cart</button>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default WishlistPage;
