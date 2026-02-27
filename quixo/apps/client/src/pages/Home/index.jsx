import React, { useState } from 'react';
import HeroBanner from './HeroBanner';
import CategoryExplore from './CategoryExplore';
import FeaturedProducts from './FeaturedProducts';

const Home = () => {
  const [deliveryMode, setDeliveryMode] = useState('quick'); // 'quick' | 'ecommerce'

  return (
    <div className="page-wrapper animate-fade-in" style={{ paddingBottom: '80px' }}>

      {/* Commerce Mode Toggle Section */}
      <div className="container" style={{ paddingTop: '20px' }}>
        <div style={{ display: 'flex', backgroundColor: '#e2e8f0', padding: '6px', borderRadius: '100px', width: 'fit-content', margin: '0 auto 20px auto' }}>
          <button
            onClick={() => setDeliveryMode('quick')}
            style={{
              padding: '12px 32px',
              borderRadius: '100px',
              border: 'none',
              fontWeight: '700',
              fontSize: '1rem',
              cursor: 'pointer',
              transition: 'all 0.3s ease',
              backgroundColor: deliveryMode === 'quick' ? 'white' : 'transparent',
              color: deliveryMode === 'quick' ? 'var(--primary)' : 'var(--text-secondary)',
              boxShadow: deliveryMode === 'quick' ? '0 4px 6px -1px rgb(0 0 0 / 0.1)' : 'none'
            }}
          >
            <span style={{ marginRight: '8px' }}>⚡</span> Quick Commerce
          </button>
          <button
            onClick={() => setDeliveryMode('ecommerce')}
            style={{
              padding: '12px 32px',
              borderRadius: '100px',
              border: 'none',
              fontWeight: '700',
              fontSize: '1rem',
              cursor: 'pointer',
              transition: 'all 0.3s ease',
              backgroundColor: deliveryMode === 'ecommerce' ? 'white' : 'transparent',
              color: deliveryMode === 'ecommerce' ? 'var(--secondary)' : 'var(--text-secondary)',
              boxShadow: deliveryMode === 'ecommerce' ? '0 4px 6px -1px rgb(0 0 0 / 0.1)' : 'none'
            }}
          >
            <span style={{ marginRight: '8px' }}>📦</span> E-Commerce
          </button>
        </div>
      </div>

      <HeroBanner mode={deliveryMode} />

      <CategoryExplore mode={deliveryMode} />

      {/* We pass the simulated selected mode down so Featured Products knows what to query */}
      <FeaturedProducts mode={deliveryMode} />

      {/* Why Choose Doko */}
      <section className="container section" style={{ textAlign: 'center' }}>
        <h2 style={{ fontSize: '2.5rem', marginBottom: '12px', color: 'var(--text-primary)' }}>Why Choose Doko?</h2>
        <p style={{ color: 'var(--text-secondary)', marginBottom: '48px', fontSize: '1.1rem' }}>Nepal's most trusted hybrid commerce platform</p>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(250px, 1fr))', gap: '32px' }}>
          <div style={{ padding: '40px 24px', backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' }}>
            <div style={{ fontSize: '4rem', marginBottom: '16px' }}>⚡</div>
            <h3 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>Lightning Fast</h3>
            <p style={{ color: 'var(--text-secondary)', lineHeight: '1.6' }}>Quick commerce orders delivered in 10-30 minutes. Guaranteed.</p>
          </div>
          <div style={{ padding: '40px 24px', backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' }}>
            <div style={{ fontSize: '4rem', marginBottom: '16px' }}>✅</div>
            <h3 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>Fresh & Verified</h3>
            <p style={{ color: 'var(--text-secondary)', lineHeight: '1.6' }}>Hand-picked products from verified vendors across Nepal.</p>
          </div>
          <div style={{ padding: '40px 24px', backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' }}>
            <div style={{ fontSize: '4rem', marginBottom: '16px' }}>💳</div>
            <h3 style={{ fontSize: '1.3rem', marginBottom: '8px' }}>Easy Payments</h3>
            <p style={{ color: 'var(--text-secondary)', lineHeight: '1.6' }}>Pay with Khalti, eSewa, FonePay, or Cash on Delivery.</p>
          </div>
        </div>
      </section>

      {/* Dynamic Download Banner */}
      <section className="container section" style={{ marginTop: '60px' }}>
        <div style={{
          background: deliveryMode === 'quick'
            ? 'linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%)'
            : 'linear-gradient(135deg, var(--secondary) 0%, #0f766e 100%)',
          borderRadius: 'var(--radius-lg)',
          padding: '60px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          color: 'white',
          boxShadow: 'var(--shadow-lg)',
          transition: 'background 0.5s ease'
        }}>
          <div style={{ maxWidth: '50%' }}>
            <h2 style={{ fontSize: '2.5rem', marginBottom: '16px' }}>Ready to get started?</h2>
            <p style={{ fontSize: '1.1rem', marginBottom: '24px', opacity: 0.9 }}>
              {deliveryMode === 'quick'
                ? 'Get the Doko app now and experience quick commerce like never before. 15-minute delivery guaranteed!'
                : 'Download the Doko app to browse thousands of products across all categories with nationwide shipping.'}
            </p>
            <div style={{ display: 'flex', gap: '16px' }}>
              <button className="btn" style={{ backgroundColor: 'white', color: deliveryMode === 'quick' ? 'var(--primary-dark)' : '#0f766e', padding: '12px 24px', borderRadius: 'var(--radius-md)', fontWeight: '700' }}>
                Download for iOS
              </button>
              <button className="btn" style={{ backgroundColor: 'white', color: deliveryMode === 'quick' ? 'var(--primary-dark)' : '#0f766e', padding: '12px 24px', borderRadius: 'var(--radius-md)', fontWeight: '700' }}>
                Download for Android
              </button>
            </div>
          </div>
          <div style={{ background: 'rgba(255,255,255,0.1)', height: '200px', width: '200px', borderRadius: '50%', display: 'flex', justifyContent: 'center', alignItems: 'center' }}>
            <span style={{ fontSize: '8rem' }}>📱</span>
          </div>
        </div>
      </section>
    </div>
  );
};

export default Home;
