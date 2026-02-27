import React, { useState, useEffect } from 'react';
import { Link, useLocation } from 'react-router-dom';

const mockProducts = {
  quick: [
    { id: 1, name: 'Fresh Organic Apples', price: 290, weight: '1 kg', image: '🍎', category: 'Fruits', badge: '10% OFF' },
    { id: 2, name: 'Farm Eggs', price: 180, weight: '1 Dozen', image: '🥚', category: 'Dairy', badge: 'Fastest' },
    { id: 3, name: 'Amul Taza Milk', price: 100, weight: '1 Litre', image: '🥛', category: 'Dairy' },
    { id: 4, name: 'Whole Wheat Bread', price: 60, weight: '400g', image: '🍞', category: 'Bakery', badge: 'Sale' },
    { id: 5, name: 'Fresh Bananas', price: 120, weight: '1 kg', image: '🍌', category: 'Fruits' },
    { id: 6, name: 'Broccoli', price: 150, weight: '500g', image: '🥦', category: 'Vegetables' },
  ],
  ecommerce: [
    { id: 11, name: 'Wireless Bluetooth Earbuds', price: 3499, weight: 'Electronics', image: '🎧', category: 'Electronics', badge: 'Top Rated' },
    { id: 12, name: 'Cotton T-Shirt (M)', price: 850, weight: 'Fashion', image: '👕', category: 'Fashion' },
    { id: 13, name: 'Smart Fitness Tracker', price: 2900, weight: 'Accessories', image: '⌚', category: 'Electronics' },
    { id: 14, name: 'Anti-Slip Yoga Mat', price: 1200, weight: 'Sports', image: '🧘', category: 'Sports', badge: 'Sale' },
    { id: 15, name: 'Frying Pan Non-Stick', price: 1800, weight: 'Home', image: '🍳', category: 'Home Appliances' },
  ]
};

const defaultCategories = {
  quick: ['All', 'Fruits', 'Vegetables', 'Dairy', 'Bakery', 'Meat', 'Snacks'],
  ecommerce: ['All', 'Electronics', 'Fashion', 'Home Appliances', 'Sports', 'Books']
};

const ProductList = () => {
  const location = useLocation();

  // Extract initial mode from query params to support 'Shop By Category' deep links, else default quick
  const params = new URLSearchParams(location.search);
  const initialMode = params.get('mode') === 'ecommerce' ? 'ecommerce' : 'quick';
  const initialCat = params.get('category') || 'All';

  const [deliveryMode, setDeliveryMode] = useState(initialMode);
  const [activeCategory, setActiveCategory] = useState(initialCat);

  // Reset category to 'All' if they switch modes
  useEffect(() => {
    setActiveCategory('All');
  }, [deliveryMode]);

  const categories = defaultCategories[deliveryMode];
  const allProducts = mockProducts[deliveryMode];
  const isQuick = deliveryMode === 'quick';

  const filteredProducts = activeCategory === 'All' || activeCategory === 'all'
    ? allProducts
    : allProducts.filter(p => p.category.toLowerCase() === activeCategory.toLowerCase());

  return (
    <div className="container animate-fade-in" style={styles.page}>

      {/* Sidebar Filters */}
      <aside style={styles.sidebar}>

        <div style={{ marginBottom: '30px' }}>
          <h3 style={{ fontSize: '1rem', color: 'var(--text-secondary)', marginBottom: '12px' }}>Delivery Speed</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '8px' }}>
            <button
              onClick={() => setDeliveryMode('quick')}
              style={{ ...styles.modeBtn, borderColor: isQuick ? 'var(--primary)' : 'var(--border)', backgroundColor: isQuick ? 'var(--primary-light)' : 'transparent', color: isQuick ? 'var(--primary-dark)' : 'var(--text-primary)' }}
            >
              ⚡ 15-Min Delivery
            </button>
            <button
              onClick={() => setDeliveryMode('ecommerce')}
              style={{ ...styles.modeBtn, borderColor: !isQuick ? 'var(--secondary)' : 'var(--border)', backgroundColor: !isQuick ? '#ccfbf1' : 'transparent', color: !isQuick ? '#0f766e' : 'var(--text-primary)' }}
            >
              📦 Standard (2-3 Days)
            </button>
          </div>
        </div>

        <h3 style={styles.sidebarTitle}>Categories</h3>
        <ul style={styles.categoryList}>
          {categories.map(cat => (
            <li key={cat}>
              <button
                onClick={() => setActiveCategory(cat)}
                style={{
                  ...styles.categoryBtn,
                  ...(activeCategory.toLowerCase() === cat.toLowerCase()
                    ? { backgroundColor: isQuick ? 'var(--primary-light)' : '#ccfbf1', color: isQuick ? 'var(--primary-dark)' : '#0f766e', fontWeight: '700' }
                    : {})
                }}
              >
                {cat}
              </button>
            </li>
          ))}
        </ul>
      </aside>

      {/* Main Content */}
      <main style={styles.mainContent}>

        <div style={{ padding: '24px', backgroundColor: isQuick ? '#ffedd5' : '#f0fdfa', borderRadius: 'var(--radius-md)', marginBottom: '24px', border: isQuick ? '1px solid #fed7aa' : '1px solid #99f6e4' }}>
          <h1 style={{ fontSize: '1.8rem', color: isQuick ? 'var(--primary-dark)' : '#0f766e', margin: 0 }}>
            {isQuick ? 'Quick Commerce Catalog' : 'E-Commerce Marketplace'}
          </h1>
          <p style={{ color: isQuick ? '#c2410c' : '#115e59', marginTop: '4px', fontSize: '0.95rem' }}>
            {isQuick ? 'Items available for immediate dispatch in your area.' : 'Items shipped nationwide from verified vendors.'}
          </p>
        </div>

        <div style={styles.header}>
          <h2 style={{ fontSize: '1.3rem' }}>{activeCategory} Products</h2>
          <span style={styles.resultCount}>{filteredProducts.length} results</span>
        </div>

        <div style={styles.grid}>
          {filteredProducts.map((product) => (
            <Link to={`/products/${product.id}`} key={product.id} style={{ textDecoration: 'none' }}>
              <div style={styles.card} className="product-card-hover">
                {product.badge && (
                  <span style={{
                    ...styles.badge,
                    backgroundColor: isQuick ? 'var(--primary)' : 'var(--secondary)'
                  }}>
                    {isQuick ? '⚡ ' : '⭐ '}{product.badge}
                  </span>
                )}
                <div style={styles.imagePlaceholder}>
                  <span style={{ fontSize: '4rem' }}>{product.image}</span>
                </div>
                <div style={styles.cardBody}>
                  <div style={styles.weight}>{product.weight}</div>
                  <h3 style={styles.name}>{product.name}</h3>
                  <div style={styles.priceRow}>
                    <span style={styles.price}>Rs. {product.price}</span>
                    <button
                      style={{
                        ...styles.addBtn,
                        backgroundColor: isQuick ? '#fff7ed' : '#f0fdfa',
                        color: isQuick ? 'var(--primary-dark)' : '#0f766e',
                        borderColor: isQuick ? '#fed7aa' : '#99f6e4'
                      }}
                      onClick={(e) => { e.preventDefault(); console.log('Added to cart:', product.id); }}
                    >
                      Add
                    </button>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </main>

    </div>
  );
};

const styles = {
  page: {
    display: 'flex',
    gap: '30px',
    paddingTop: '40px',
    paddingBottom: '80px',
    minHeight: 'calc(100vh - 70px)'
  },
  sidebar: {
    width: '260px',
    flexShrink: '0',
    backgroundColor: 'var(--surface)',
    padding: '24px',
    borderRadius: 'var(--radius-lg)',
    boxShadow: 'var(--shadow-sm)',
    border: '1px solid var(--border)',
    height: 'fit-content',
    position: 'sticky',
    top: '90px'
  },
  modeBtn: {
    width: '100%',
    padding: '12px',
    textAlign: 'left',
    borderRadius: 'var(--radius-sm)',
    border: '2px solid',
    fontWeight: '700',
    fontSize: '0.9rem',
    cursor: 'pointer',
    transition: 'var(--transition)'
  },
  sidebarTitle: {
    fontSize: '1.2rem',
    marginBottom: '20px',
    paddingBottom: '10px',
    borderBottom: '1px solid var(--border)'
  },
  categoryList: {
    display: 'flex',
    flexDirection: 'column',
    gap: '8px'
  },
  categoryBtn: {
    width: '100%',
    textAlign: 'left',
    padding: '10px 16px',
    backgroundColor: 'transparent',
    borderRadius: 'var(--radius-sm)',
    color: 'var(--text-secondary)',
    fontWeight: '500',
    fontSize: '1rem',
    transition: 'var(--transition)',
    border: 'none',
    cursor: 'pointer'
  },
  mainContent: {
    flex: '1'
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'baseline',
    marginBottom: '24px'
  },
  resultCount: {
    color: 'var(--text-secondary)',
    fontSize: '0.9rem'
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))',
    gap: '24px'
  },
  card: {
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-md)',
    overflow: 'hidden',
    boxShadow: 'var(--shadow-sm)',
    border: '1px solid var(--border)',
    display: 'flex',
    flexDirection: 'column',
    position: 'relative'
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
    height: '180px',
    backgroundColor: '#f9fafb',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    borderBottom: '1px solid var(--border)'
  },
  cardBody: {
    padding: '16px',
    display: 'flex',
    flexDirection: 'column',
    flex: '1'
  },
  weight: {
    color: 'var(--text-secondary)',
    fontSize: '0.8rem',
    marginBottom: '6px'
  },
  name: {
    fontSize: '1.1rem',
    fontWeight: '600',
    marginBottom: 'auto',
    color: 'var(--text-primary)',
    paddingBottom: '16px'
  },
  priceRow: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginTop: '10px'
  },
  price: {
    fontSize: '1.2rem',
    fontWeight: '700',
    color: 'var(--text-primary)'
  },
  addBtn: {
    border: '1px solid',
    padding: '6px 16px',
    borderRadius: '100px',
    fontWeight: '700',
    fontSize: '0.9rem',
    cursor: 'pointer',
    transition: 'all 0.2s'
  }
};

export default ProductList;
