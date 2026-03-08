import React, { useState, useEffect, useContext } from 'react';
import { useParams, Link } from 'react-router-dom';
import { productAPI } from '../../services/api';
import { CartContext } from '../../context/CartContext';

const ProductDetail = () => {
  const { id } = useParams();
  const [product, setProduct] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [quantity, setQuantity] = useState(1);
  const [addedMsg, setAddedMsg] = useState('');
  const { addToCart } = useContext(CartContext);

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        setLoading(true);
        const { data } = await productAPI.getById(id);
        setProduct(data.message || data.data || data.product || data);
      } catch (err) {
        setError('Product not found or failed to load.');
      } finally {
        setLoading(false);
      }
    };
    fetchProduct();
  }, [id]);

  const handleAddToCart = async () => {
    const result = await addToCart(product._id || id, quantity);
    if (result?.success) {
      setAddedMsg('✓ Added to cart!');
      setTimeout(() => setAddedMsg(''), 2000);
    } else {
      setAddedMsg(result?.message || 'Please log in first');
      setTimeout(() => setAddedMsg(''), 2000);
    }
  };

  if (loading) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center', minHeight: 'calc(100vh - 70px)' }}>
        <div style={{ fontSize: '3rem', marginBottom: '16px' }}>⏳</div>
        <p style={{ color: 'var(--text-secondary)' }}>Loading product...</p>
      </div>
    );
  }

  if (error || !product) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center', minHeight: 'calc(100vh - 70px)' }}>
        <div style={{ fontSize: '3rem', marginBottom: '16px' }}>😕</div>
        <h2>{error || 'Product not found'}</h2>
        <Link to="/products"><button className="btn btn-primary" style={{ marginTop: '20px' }}>Browse Products</button></Link>
      </div>
    );
  }

  const name = product.name || 'Product';
  const price = product.pricePerUnit || product.price || 0;
  const oldPrice = product.comparePrice || product.oldPrice;
  const description = product.description || product.shortDescription || '';
  const category = product.deliveryCategory || product.category || '';
  const stock = product.stock ?? product.countInStock ?? 0;
  const image = product.photos?.[0] || product.images?.[0];

  return (
    <div className="container animate-fade-in" style={styles.page}>

      {/* Breadcrumbs */}
      <div style={styles.breadcrumbs}>
        <Link to="/" style={styles.crumb}>Home</Link>
        <span style={styles.crumbSeparator}>/</span>
        <Link to="/products" style={styles.crumb}>Products</Link>
        <span style={styles.crumbSeparator}>/</span>
        <span style={styles.crumbActive}>{name}</span>
      </div>

      <div className="tracking-layout">
        {/* Visual Section */}
        <div className="tracking-map-col">
          <div style={styles.mainImage}>
            {image
              ? <img src={image} alt={name} style={{ width: '100%', height: '100%', objectFit: 'cover', borderRadius: 'var(--radius-md)' }} />
              : <span style={{ fontSize: '10rem' }}>📦</span>
            }
          </div>
        </div>

        {/* Details Section */}
        <div className="tracking-sidebar-col" style={{ backgroundColor: 'var(--surface)', padding: '30px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' }}>
          {category && <div style={styles.categoryBadge}>{category}</div>}
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>{name}</h1>
          {stock > 0 && <div style={{ color: 'var(--success)', fontWeight: '600', fontSize: '0.9rem', marginBottom: '16px' }}>✓ In Stock ({stock} available)</div>}
          {stock === 0 && <div style={{ color: 'var(--danger)', fontWeight: '600', fontSize: '0.9rem', marginBottom: '16px' }}>Out of Stock</div>}

          <div style={styles.priceContainer}>
            <div style={styles.currentPrice}>Rs. {price}</div>
            {oldPrice && <div style={styles.oldPrice}>Rs. {oldPrice}</div>}
            {oldPrice && (
              <div style={styles.discountBadge}>
                {Math.round(((oldPrice - price) / oldPrice) * 100)}% OFF
              </div>
            )}
          </div>

          <div style={{ height: '1px', backgroundColor: 'var(--border)', margin: '0 0 24px 0' }}></div>

          {description && <p style={{ color: 'var(--text-secondary)', fontSize: '1rem', lineHeight: '1.7', marginBottom: '30px' }}>{description}</p>}

          <div style={{ display: 'flex', gap: '16px', marginBottom: '24px', flexWrap: 'wrap' }}>
            <div style={styles.quantityPicker}>
              <button style={styles.qtyBtn} onClick={() => setQuantity(Math.max(1, quantity - 1))}>-</button>
              <span style={styles.qtyValue}>{quantity}</span>
              <button style={styles.qtyBtn} onClick={() => setQuantity(Math.min(stock || 99, quantity + 1))}>+</button>
            </div>
            <button className="btn btn-primary" style={{ flex: '1', fontSize: '1rem' }} onClick={handleAddToCart} disabled={stock === 0}>
              {stock === 0 ? 'Out of Stock' : `Add to Cart — Rs. ${price * quantity}`}
            </button>
          </div>

          {addedMsg && (
            <div style={{ padding: '10px 16px', backgroundColor: addedMsg.includes('✓') ? '#ecfdf5' : '#fef2f2', color: addedMsg.includes('✓') ? '#065f46' : '#dc2626', borderRadius: 'var(--radius-sm)', textAlign: 'center', fontWeight: '600', marginBottom: '16px' }}>
              {addedMsg}
            </div>
          )}

          <div style={{ backgroundColor: '#f8fafc', padding: '20px', borderRadius: 'var(--radius-md)', border: '1px dashed #cbd5e1', display: 'flex', flexDirection: 'column', gap: '10px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontWeight: '500' }}>⚡ 15-Minute Delivery</div>
            <div style={{ display: 'flex', alignItems: 'center', gap: '10px', fontWeight: '500' }}>❄️ Temperature Controlled</div>
          </div>
        </div>
      </div>

      {/* Reviews Section */}
      <div style={{ marginTop: '40px', backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', padding: '30px', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' }}>
        <h2 style={{ fontSize: '1.5rem', marginBottom: '20px' }}>Reviews ({reviews.length})</h2>
        {reviews.length === 0 ? (
          <p style={{ color: 'var(--text-secondary)', padding: '20px 0' }}>No reviews yet. Be the first to review this product!</p>
        ) : (
          reviews.map((review, i) => (
            <div key={review._id || i} style={{ padding: '16px 0', borderBottom: i < reviews.length - 1 ? '1px solid var(--border)' : 'none' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '6px' }}>
                <div style={{ fontWeight: '700' }}>{review.user?.name || 'Customer'}</div>
                <div style={{ color: '#f59e0b' }}>{'⭐'.repeat(review.rating || 5)}</div>
              </div>
              <p style={{ color: 'var(--text-secondary)', lineHeight: '1.5' }}>{review.comment || review.text}</p>
            </div>
          ))
        )}
      </div>
    </div>
  );
};

const styles = {
  page: { paddingTop: '20px', paddingBottom: '80px', minHeight: 'calc(100vh - 70px)' },
  breadcrumbs: { display: 'flex', alignItems: 'center', marginBottom: '30px', fontSize: '0.9rem', flexWrap: 'wrap', gap: '4px' },
  crumb: { color: 'var(--text-secondary)' },
  crumbSeparator: { margin: '0 8px', color: '#d1d5db' },
  crumbActive: { color: 'var(--text-primary)', fontWeight: '500' },
  mainImage: { width: '100%', aspectRatio: '1 / 1', backgroundColor: '#f3f4f6', borderRadius: 'var(--radius-md)', display: 'flex', justifyContent: 'center', alignItems: 'center', border: '1px solid var(--border)', overflow: 'hidden' },
  categoryBadge: { display: 'inline-block', backgroundColor: '#eff6ff', color: '#2563eb', padding: '4px 12px', borderRadius: 'var(--radius-sm)', fontSize: '0.85rem', fontWeight: '600', marginBottom: '16px' },
  priceContainer: { display: 'flex', alignItems: 'center', gap: '16px', marginBottom: '24px', flexWrap: 'wrap' },
  currentPrice: { fontSize: '2rem', fontWeight: '800', color: 'var(--primary-dark)' },
  oldPrice: { fontSize: '1.2rem', color: 'var(--text-secondary)', textDecoration: 'line-through' },
  discountBadge: { backgroundColor: 'var(--secondary)', color: 'white', padding: '4px 8px', borderRadius: '4px', fontWeight: '700', fontSize: '0.9rem' },
  quantityPicker: { display: 'flex', alignItems: 'center', border: '1px solid var(--border)', borderRadius: 'var(--radius-md)', overflow: 'hidden' },
  qtyBtn: { backgroundColor: '#f9fafb', padding: '14px 20px', fontSize: '1.2rem', fontWeight: '600', color: 'var(--text-primary)' },
  qtyValue: { padding: '0 20px', fontSize: '1.2rem', fontWeight: '600' }
};

export default ProductDetail;
