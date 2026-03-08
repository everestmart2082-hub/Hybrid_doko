import React from 'react';
import { useNavigate } from 'react-router-dom';

const categories = [
  { name: 'Fruits', icon: '🍎', color: '#ecfdf5' },
  { name: 'Vegetables', icon: '🥬', color: '#f0fdf4' },
  { name: 'Dairy', icon: '🥛', color: '#eff6ff' },
  { name: 'Bakery', icon: '🍞', color: '#fef3c7' },
  { name: 'Electronics', icon: '💻', color: '#f1f5f9' },
  { name: 'Fashion', icon: '👕', color: '#fdf4ff' },
  { name: 'Sports', icon: '⚽', color: '#fffbeb' },
  { name: 'Home Appliances', icon: '📺', color: '#fef2f2' },
  { name: 'Books', icon: '📚', color: '#f0fdf4' },
  { name: 'Grains', icon: '🌾', color: '#fefce8' },
];

const CategoryExplore = () => {
  const navigate = useNavigate();

  return (
    <section className="container section">
      <div style={styles.header}>
        <h2 style={styles.title}>Shop by Category</h2>
        <button style={styles.seeAll} onClick={() => navigate('/products')}>
          See All →
        </button>
      </div>

      <div style={styles.grid}>
        {categories.map((category) => (
          <div key={category.name} style={styles.card} className="category-card animate-fade-in" onClick={() => navigate(`/products?category=${encodeURIComponent(category.name)}`)}>
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
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' },
  title: { fontSize: '2rem', color: 'var(--text-primary)' },
  seeAll: { background: 'none', fontWeight: '700', fontSize: '1rem', cursor: 'pointer', border: 'none', color: 'var(--primary)' },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: '20px' },
  card: { backgroundColor: 'var(--surface)', padding: '24px 16px', borderRadius: 'var(--radius-lg)', textAlign: 'center', cursor: 'pointer', boxShadow: 'var(--shadow-sm)', transition: 'all 0.3s ease', border: '1px solid var(--border)' },
  iconWrapper: { width: '70px', height: '70px', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center', margin: '0 auto 16px', transition: 'transform 0.3s ease' },
  icon: { fontSize: '2.2rem' },
  name: { fontSize: '0.95rem', fontWeight: '700', color: 'var(--text-primary)' }
};

export default CategoryExplore;
