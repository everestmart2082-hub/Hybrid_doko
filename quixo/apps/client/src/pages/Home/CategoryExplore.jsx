import React from 'react';

const quickCategories = [
  { id: 1, name: 'Fresh Vegetables', icon: '🥬', color: '#ecfdf5' },
  { id: 2, name: 'Dairy & Bakery', icon: '🥛', color: '#eff6ff' },
  { id: 3, name: 'Snacks & Drinks', icon: '🥤', color: '#fef3c7' },
  { id: 4, name: 'Instant Munchies', icon: '🍜', color: '#fee2e2' },
  { id: 5, name: 'Pet Care', icon: '🐶', color: '#f3e8ff' },
  { id: 6, name: 'Personal Care', icon: '🧴', color: '#fce7f3' },
];

const ecoCategories = [
  { id: 11, name: 'Electronics', icon: '💻', color: '#f1f5f9' },
  { id: 12, name: 'Fashion', icon: '👕', color: '#fdf4ff' },
  { id: 13, name: 'Home Appliances', icon: '📺', color: '#fef2f2' },
  { id: 14, name: 'Books & Media', icon: '📚', color: '#f0fdf4' },
  { id: 15, name: 'Sports Gear', icon: '⚽', color: '#fffbeb' },
  { id: 16, name: 'Toys', icon: '🧸', color: '#e0e7ff' },
];

const CategoryExplore = ({ mode = 'quick' }) => {
  const categories = mode === 'quick' ? quickCategories : ecoCategories;

  return (
    <section className="container section">
      <div style={styles.header}>
        <h2 style={styles.title}>
          {mode === 'quick' ? 'Shop Instant Categories' : 'Browse Platform Categories'}
        </h2>
        <button style={{ ...styles.seeAll, color: mode === 'quick' ? 'var(--primary)' : 'var(--secondary)' }}>
          See All →
        </button>
      </div>

      <div style={styles.grid}>
        {categories.map((category) => (
          <div key={category.id} style={styles.card} className="category-card animate-fade-in">
            <div style={{ ...styles.iconWrapper, backgroundColor: category.color }}>
              <span style={styles.icon}>{category.icon}</span>
            </div>
            <h3 style={styles.name}>{category.name}</h3>
          </div>
        ))}
      </div>
    </section>
  );
};

const styles = {
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: '30px'
  },
  title: {
    fontSize: '2rem',
    color: 'var(--text-primary)'
  },
  seeAll: {
    background: 'none',
    fontWeight: '700',
    fontSize: '1rem',
    cursor: 'pointer',
    border: 'none'
  },
  grid: {
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fit, minmax(160px, 1fr))',
    gap: '24px'
  },
  card: {
    backgroundColor: 'var(--surface)',
    padding: '30px 16px',
    borderRadius: 'var(--radius-lg)',
    textAlign: 'center',
    cursor: 'pointer',
    boxShadow: 'var(--shadow-sm)',
    transition: 'all 0.3s ease',
    border: '1px solid var(--border)'
  },
  iconWrapper: {
    width: '80px',
    height: '80px',
    borderRadius: '50%',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    margin: '0 auto 20px',
    transition: 'transform 0.3s ease'
  },
  icon: {
    fontSize: '2.5rem'
  },
  name: {
    fontSize: '1.05rem',
    fontWeight: '700',
    color: 'var(--text-primary)'
  }
};

export default CategoryExplore;
