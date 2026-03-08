import React from 'react';
import { useNavigate } from 'react-router-dom';

const HeroBanner = ({ mode = 'quick' }) => {
  const isQuick = mode === 'quick';
  const navigate = useNavigate();

  return (
    <div className="hero-section container" style={{
      ...styles.section,
      background: isQuick
        ? 'linear-gradient(to right, var(--surface) 50%, #fff7ed 50%)'
        : 'linear-gradient(to right, var(--surface) 50%, #f0fdfa 50%)'
    }}>
      <div className="hero-content" style={styles.content}>

        <div key={mode} className="animate-fade-in" style={{
          ...styles.badge,
          backgroundColor: isQuick ? '#ffedd5' : '#ccfbf1',
          color: isQuick ? 'var(--primary-dark)' : '#0f766e',
          border: isQuick ? '1px solid #fed7aa' : '1px solid #99f6e4'
        }}>
          {isQuick ? '🚀 15-Minute Guaranteed Delivery' : '📦 Platform Nationwide Shipping'}
        </div>

        <h1 key={`title-${mode}`} className="hero-title animate-fade-in" style={styles.title}>
          {isQuick ? (
            <>Groceries in <span style={{ color: 'var(--primary)' }}>Minutes</span></>
          ) : (
            <>Everything you need, <span style={{ color: 'var(--secondary)' }}>Delivered</span></>
          )}
        </h1>

        <p key={`sub-${mode}`} className="hero-subtitle animate-fade-in" style={styles.subtitle}>
          {isQuick
            ? 'Fresh produce, daily essentials, and cravings delivered straight to your door instantly.'
            : 'Shop electronics, clothing, beauty products, and more from thousands of verified vendors across Nepal.'}
        </p>

        <div className="hero-actions animate-fade-in" style={styles.actions}>
          <button className="btn" style={{
            ...styles.primaryBtn,
            backgroundColor: isQuick ? 'var(--primary)' : 'var(--secondary)',
            boxShadow: isQuick ? '0 4px 14px 0 rgba(249, 115, 22, 0.39)' : '0 4px 14px 0 rgba(20, 184, 166, 0.39)'
          }}
            onClick={() => navigate('/products')}
          >            {isQuick ? 'Shop Groceries Now' : 'Start Browsing'}
          </button>
        </div>
      </div>

      <div key={`img-${mode}`} className="hero-image-wrapper animate-fade-in" style={styles.imageWrapper}>
        {isQuick ? (
          <img
            src="https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&q=80&w=800"
            alt="Fresh Groceries"
            style={styles.image}
          />
        ) : (
          <img
            src="https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?auto=format&fit=crop&q=80&w=800"
            alt="E-commerce shopping"
            style={styles.image}
          />
        )}

        <div style={styles.floatingCard}>
          <span style={{ fontSize: '24px', marginRight: '12px' }}>{isQuick ? '⏱️' : '🚚'}</span>
          <div>
            <div style={{ fontWeight: '700', color: 'var(--text-primary)' }}>
              {isQuick ? 'Under 15 mins' : 'Standard Delivery'}
            </div>
            <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>
              {isQuick ? 'Delivery guaranteed' : '2-3 Business Days'}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

const styles = {
  section: {
    display: 'flex',
    alignItems: 'center',
    justifyContent: 'space-between',
    padding: '80px 40px',
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-lg)',
    marginTop: '10px',
    marginBottom: '60px',
    boxShadow: 'var(--shadow-md)',
    gap: '40px',
    overflow: 'hidden',
    position: 'relative'
  },
  content: {
    flex: '1',
    maxWidth: '600px',
    zIndex: '2',
  },
  badge: {
    display: 'inline-block',
    padding: '8px 16px',
    borderRadius: '100px',
    fontWeight: '700',
    fontSize: '0.9rem',
    marginBottom: '24px',
  },
  title: {
    fontSize: '3.5rem',
    fontWeight: '800',
    letterSpacing: '-1px',
    marginBottom: '20px',
    color: 'var(--text-primary)',
    lineHeight: '1.2'
  },
  subtitle: {
    fontSize: '1.2rem',
    color: 'var(--text-secondary)',
    marginBottom: '40px',
    lineHeight: '1.6',
  },
  actions: {
    display: 'flex',
    alignItems: 'center',
  },
  primaryBtn: {
    color: 'white',
    fontSize: '1.1rem',
    padding: '16px 36px',
    border: 'none'
  },
  imageWrapper: {
    flex: '1',
    position: 'relative',
    display: 'flex',
    justifyContent: 'flex-end',
  },
  image: {
    width: '100%',
    maxWidth: '500px',
    height: '400px',
    objectFit: 'cover',
    borderRadius: 'var(--radius-lg)',
    boxShadow: 'var(--shadow-lg)'
  },
  floatingCard: {
    position: 'absolute',
    bottom: '-20px',
    left: '0px',
    backgroundColor: 'var(--surface)',
    padding: '16px 24px',
    borderRadius: 'var(--radius-md)',
    boxShadow: 'var(--shadow-lg)',
    display: 'flex',
    alignItems: 'center',
    animation: 'fadeIn 0.6s ease-out forwards 0.2s',
  }
};

export default HeroBanner;
