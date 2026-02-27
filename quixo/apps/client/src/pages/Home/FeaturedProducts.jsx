import React from 'react';

const mockProducts = {
  quick: [
    { id: 1, name: 'Fresh Organic Apples', price: 290, oldPrice: 350, weight: '1 kg', image: '🍎', badge: '10% OFF' },
    { id: 2, name: 'Farm Eggs', price: 180, oldPrice: null, weight: '1 Dozen', image: '🥚', badge: 'Fastest' },
    { id: 3, name: 'Amul Taza Milk', price: 100, oldPrice: null, weight: '1 Litre', image: '🥛', badge: '' },
    { id: 4, name: 'Whole Wheat Bread', price: 60, oldPrice: 80, weight: '400g', image: '🍞', badge: '25% OFF' }
  ],
  ecommerce: [
    { id: 11, name: 'Wireless Noise Cancelling Earbuds', price: 3499, oldPrice: 4999, weight: 'Electronics', image: '🎧', badge: 'Sale' },
    { id: 12, name: 'Men’s Cotton T-Shirt', price: 850, oldPrice: null, weight: 'Fashion', image: '👕', badge: 'Top Rated' },
    { id: 13, name: 'Smart Fitness Watch', price: 2900, oldPrice: 3500, weight: 'Accessories', image: '⌚', badge: '' },
    { id: 14, name: 'Yoga Mat (Anti-Slip)', price: 1200, oldPrice: 1500, weight: 'Sports', image: '🧘', badge: '20% OFF' }
  ]
};

const FeaturedProducts = ({ mode = 'quick' }) => {
  const products = mockProducts[mode];
  const isQuick = mode === 'quick';

  return (
    <section className="container section">
      <div style={styles.header}>
        <h2 style={styles.title}>
          {isQuick ? 'Essentials You Need Right Now' : 'Trending on Doko Marketplace'}
        </h2>
        <p style={{ color: 'var(--text-secondary)' }}>
          {isQuick ? 'Handpicked fresh items delivered to you in 15 mins' : 'Discover top-rated products from verified national vendors'}
        </p>
      </div>

      <div style={styles.grid}>
        {products.map((product) => (
          <div key={product.id} style={styles.card} className="animate-fade-in product-card-hover">
            {product.badge && (
              <span style={{
                ...styles.badge,
                backgroundColor: isQuick ? 'var(--primary)' : 'var(--secondary)'
              }}>
                {isQuick ? '⚡ ' : '⭐ '}{product.badge}
              </span>
            )}

            <div style={styles.imagePlaceholder}>
              <span style={{ fontSize: '5rem' }}>{product.image}</span>
              {/* Delivery Speed Badge overlay on image */}
              <div style={styles.deliveryBadge}>
                {isQuick ? '🚚 15 Min' : '📦 2-3 Days'}
              </div>
            </div>

            <div style={styles.cardBody}>
              <div style={styles.weight}>{product.weight}</div>
              <h3 style={styles.name}>{product.name}</h3>
              <div style={styles.priceRow}>
                <div style={styles.priceBlock}>
                  <span style={styles.price}>Rs. {product.price}</span>
                  {product.oldPrice && <span style={styles.oldPrice}>Rs. {product.oldPrice}</span>}
                </div>
                <button style={{
                  ...styles.addBtn,
                  backgroundColor: isQuick ? '#fff7ed' : '#f0fdfa',
                  color: isQuick ? 'var(--primary-dark)' : '#0f766e',
                  borderColor: isQuick ? '#fed7aa' : '#99f6e4'
                }}>Add</button>
              </div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
};

const styles = {
  header: {
    marginBottom: '40px',
    textAlign: 'center'
  },
  title: {
    fontSize: '2.5rem',
    color: 'var(--text-primary)',
    marginBottom: '8px'
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))',
    gap: '24px'
  },
  card: {
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-md)',
    overflow: 'hidden',
    boxShadow: 'var(--shadow-md)',
    border: '1px solid var(--border)',
    position: 'relative',
    transition: 'all 0.3s ease',
    cursor: 'pointer'
  },
  badge: {
    position: 'absolute',
    top: '12px',
    left: '12px',
    color: 'white',
    padding: '4px 8px',
    borderRadius: 'var(--radius-sm)',
    fontSize: '0.75rem',
    fontWeight: '700',
    zIndex: '1'
  },
  imagePlaceholder: {
    height: '200px',
    backgroundColor: '#f8fafc',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    borderBottom: '1px solid var(--border)',
    position: 'relative'
  },
  deliveryBadge: {
    position: 'absolute',
    bottom: '8px',
    right: '8px',
    backgroundColor: 'rgba(255,255,255,0.9)',
    backdropFilter: 'blur(4px)',
    padding: '4px 8px',
    borderRadius: 'var(--radius-sm)',
    fontSize: '0.75rem',
    fontWeight: '800',
    color: 'var(--text-primary)',
    boxShadow: 'var(--shadow-sm)'
  },
  cardBody: {
    padding: '20px'
  },
  weight: {
    color: 'var(--text-secondary)',
    fontSize: '0.85rem',
    marginBottom: '8px',
    fontWeight: '500'
  },
  name: {
    fontSize: '1.15rem',
    fontWeight: '600',
    marginBottom: '16px',
    color: 'var(--text-primary)',
    minHeight: '48px',
    lineHeight: '1.3'
  },
  priceRow: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center'
  },
  priceBlock: {
    display: 'flex',
    flexDirection: 'column'
  },
  price: {
    fontSize: '1.3rem',
    fontWeight: '800',
    color: 'var(--text-primary)'
  },
  oldPrice: {
    fontSize: '0.9rem',
    color: 'var(--text-secondary)',
    textDecoration: 'line-through',
    marginTop: '2px'
  },
  addBtn: {
    border: '1px solid',
    padding: '8px 24px',
    borderRadius: '100px',
    fontWeight: '700',
    fontSize: '1rem',
    cursor: 'pointer',
    transition: 'all 0.2s'
  }
};

export default FeaturedProducts;
