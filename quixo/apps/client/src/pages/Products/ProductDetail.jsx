import React, { useState } from 'react';
import { useParams, Link } from 'react-router-dom';

const mockProduct = {
  id: 1,
  name: 'Fresh Organic Apples',
  price: 290,
  oldPrice: 350,
  weight: '1 kg',
  image: '🍎',
  category: 'Fruits',
  description: 'Crisp, sweet, and locally sourced organic apples. Perfect for healthy snacking or baking. Delivered farm-fresh directly to your doorstep in under 15 minutes!',
  nutritionalInfo: { Calories: '52', Carbs: '14g', Fiber: '2.4g' },
  stock: 24
};

const ProductDetail = () => {
  const { id } = useParams();
  const [quantity, setQuantity] = useState(1);

  // In a real app we would fetch the product by id
  const product = mockProduct;

  return (
    <div className="container animate-fade-in" style={styles.page}>

      {/* Breadcrumbs */}
      <div style={styles.breadcrumbs}>
        <Link to="/" style={styles.crumb}>Home</Link>
        <span style={styles.crumbSeparator}>/</span>
        <Link to="/products" style={styles.crumb}>Products</Link>
        <span style={styles.crumbSeparator}>/</span>
        <span style={styles.crumbActive}>{product.name}</span>
      </div>

      <div style={styles.content}>
        {/* Visual Section */}
        <div style={styles.visualSection}>
          <div style={styles.mainImage}>
            <span style={{ fontSize: '10rem' }}>{product.image}</span>
          </div>
        </div>

        {/* Details Section */}
        <div style={styles.detailsSection}>
          <div style={styles.categoryBadge}>{product.category}</div>
          <h1 style={styles.title}>{product.name}</h1>
          <div style={styles.weight}>{product.weight}</div>

          <div style={styles.priceContainer}>
            <div style={styles.currentPrice}>Rs. {product.price}</div>
            {product.oldPrice && <div style={styles.oldPrice}>Rs. {product.oldPrice}</div>}
            {product.oldPrice && (
              <div style={styles.discountBadge}>
                {Math.round(((product.oldPrice - product.price) / product.oldPrice) * 100)}% OFF
              </div>
            )}
          </div>

          <div style={styles.divider}></div>

          <p style={styles.description}>{product.description}</p>

          <div style={styles.actions}>
            <div style={styles.quantityPicker}>
              <button
                style={styles.qtyBtn}
                onClick={() => setQuantity(Math.max(1, quantity - 1))}
              >-</button>
              <span style={styles.qtyValue}>{quantity}</span>
              <button
                style={styles.qtyBtn}
                onClick={() => setQuantity(Math.min(product.stock, quantity + 1))}
              >+</button>
            </div>
            <button className="btn btn-primary" style={styles.addToCartBtn}>
              Add to Cart - Rs. {product.price * quantity}
            </button>
          </div>

          <div style={styles.deliveryInfo}>
            <div style={styles.deliveryItem}>
              <span>⚡</span> 15-Minute Delivery
            </div>
            <div style={styles.deliveryItem}>
              <span>❄️</span> Temperature Controlled
            </div>
          </div>
        </div>
      </div>

      {/* Reviews Section */}
      <div style={{ marginTop: '40px', backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', padding: '40px', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)' }}>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
          <h2 style={{ fontSize: '1.8rem' }}>Ratings & Reviews</h2>
          <button className="btn btn-primary" style={{ padding: '10px 24px' }}>Write a Review</button>
        </div>

        {/* Rating Summary */}
        <div style={{ display: 'flex', gap: '40px', marginBottom: '30px', padding: '24px', backgroundColor: '#f8fafc', borderRadius: 'var(--radius-md)' }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '3rem', fontWeight: '800', color: 'var(--text-primary)' }}>4.5</div>
            <div style={{ color: '#f59e0b', fontSize: '1.2rem' }}>⭐⭐⭐⭐⭐</div>
            <div style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginTop: '4px' }}>Based on 24 reviews</div>
          </div>
          <div style={{ flex: 1 }}>
            {[5, 4, 3, 2, 1].map(star => (
              <div key={star} style={{ display: 'flex', alignItems: 'center', gap: '8px', marginBottom: '6px' }}>
                <span style={{ fontSize: '0.85rem', width: '20px' }}>{star}⭐</span>
                <div style={{ flex: 1, height: '8px', backgroundColor: '#e5e7eb', borderRadius: '4px', overflow: 'hidden' }}>
                  <div style={{ height: '100%', backgroundColor: '#f59e0b', borderRadius: '4px', width: star === 5 ? '60%' : star === 4 ? '25%' : star === 3 ? '10%' : '3%' }}></div>
                </div>
                <span style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', width: '24px' }}>{star === 5 ? 14 : star === 4 ? 6 : star === 3 ? 3 : 1}</span>
              </div>
            ))}
          </div>
        </div>

        {/* Individual Reviews */}
        {[
          { name: 'Sita R.', rating: 5, date: '2 days ago', text: 'Very fresh and crunchy! Delivered within 12 minutes. Will order again.' },
          { name: 'Ramesh K.', rating: 4, date: '1 week ago', text: 'Good quality but one apple was slightly bruised. Overall happy with the purchase.' },
          { name: 'Priya S.', rating: 5, date: '2 weeks ago', text: 'Best organic apples in Kathmandu. The Doko app is so convenient!' }
        ].map((review, i) => (
          <div key={i} style={{ padding: '20px 0', borderBottom: i < 2 ? '1px solid var(--border)' : 'none' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                <div style={{ width: '36px', height: '36px', borderRadius: '50%', backgroundColor: 'var(--primary)', color: 'white', display: 'flex', justifyContent: 'center', alignItems: 'center', fontWeight: '700', fontSize: '0.9rem' }}>{review.name[0]}</div>
                <div>
                  <div style={{ fontWeight: '700' }}>{review.name}</div>
                  <div style={{ color: '#f59e0b', fontSize: '0.85rem' }}>{'⭐'.repeat(review.rating)}</div>
                </div>
              </div>
              <span style={{ fontSize: '0.85rem', color: 'var(--text-secondary)' }}>{review.date}</span>
            </div>
            <p style={{ color: 'var(--text-secondary)', lineHeight: '1.6', marginLeft: '48px' }}>{review.text}</p>
          </div>
        ))}
      </div>

    </div>
  );
};

const styles = {
  page: {
    paddingTop: '20px',
    paddingBottom: '80px',
    minHeight: 'calc(100vh - 70px)'
  },
  breadcrumbs: {
    display: 'flex',
    alignItems: 'center',
    marginBottom: '30px',
    fontSize: '0.9rem'
  },
  crumb: {
    color: 'var(--text-secondary)',
    transition: 'color 0.2s'
  },
  crumbSeparator: {
    margin: '0 8px',
    color: '#d1d5db'
  },
  crumbActive: {
    color: 'var(--text-primary)',
    fontWeight: '500'
  },
  content: {
    display: 'flex',
    gap: '40px',
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-lg)',
    padding: '40px',
    boxShadow: 'var(--shadow-md)',
    border: '1px solid var(--border)'
  },
  visualSection: {
    flex: '1',
    display: 'flex',
    flexDirection: 'column',
    gap: '20px'
  },
  mainImage: {
    width: '100%',
    aspectRatio: '1 / 1',
    backgroundColor: '#f3f4f6',
    borderRadius: 'var(--radius-md)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    border: '1px solid var(--border)'
  },
  detailsSection: {
    flex: '1',
    display: 'flex',
    flexDirection: 'column'
  },
  categoryBadge: {
    display: 'inline-block',
    backgroundColor: '#eff6ff',
    color: '#2563eb',
    padding: '4px 12px',
    borderRadius: 'var(--radius-sm)',
    fontSize: '0.85rem',
    fontWeight: '600',
    marginBottom: '16px',
    alignSelf: 'flex-start'
  },
  title: {
    fontSize: '2.5rem',
    marginBottom: '8px'
  },
  weight: {
    color: 'var(--text-secondary)',
    fontSize: '1.1rem',
    marginBottom: '24px'
  },
  priceContainer: {
    display: 'flex',
    alignItems: 'center',
    gap: '16px',
    marginBottom: '32px'
  },
  currentPrice: {
    fontSize: '2rem',
    fontWeight: '800',
    color: 'var(--primary-dark)'
  },
  oldPrice: {
    fontSize: '1.2rem',
    color: 'var(--text-secondary)',
    textDecoration: 'line-through'
  },
  discountBadge: {
    backgroundColor: 'var(--secondary)',
    color: 'white',
    padding: '4px 8px',
    borderRadius: '4px',
    fontWeight: '700',
    fontSize: '0.9rem'
  },
  divider: {
    height: '1px',
    backgroundColor: 'var(--border)',
    margin: '0 0 32px 0'
  },
  description: {
    color: 'var(--text-secondary)',
    fontSize: '1.1rem',
    lineHeight: '1.7',
    marginBottom: '40px'
  },
  actions: {
    display: 'flex',
    gap: '20px',
    marginBottom: '40px'
  },
  quantityPicker: {
    display: 'flex',
    alignItems: 'center',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius-md)',
    overflow: 'hidden'
  },
  qtyBtn: {
    backgroundColor: '#f9fafb',
    padding: '16px 24px',
    fontSize: '1.2rem',
    fontWeight: '600',
    color: 'var(--text-primary)'
  },
  qtyValue: {
    padding: '0 24px',
    fontSize: '1.2rem',
    fontWeight: '600'
  },
  addToCartBtn: {
    flex: '1',
    fontSize: '1.1rem'
  },
  deliveryInfo: {
    marginTop: 'auto',
    backgroundColor: '#f8fafc',
    padding: '24px',
    borderRadius: 'var(--radius-md)',
    border: '1px dashed #cbd5e1',
    display: 'flex',
    flexDirection: 'column',
    gap: '12px'
  },
  deliveryItem: {
    display: 'flex',
    alignItems: 'center',
    gap: '12px',
    fontWeight: '500',
    color: 'var(--text-primary)'
  }
};

export default ProductDetail;
