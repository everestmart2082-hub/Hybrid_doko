import React, { useState, useEffect, useContext } from 'react';
import { Link } from 'react-router-dom';
import { wishlistAPI } from '../../services/api';
import { CartContext } from '../../context/CartContext';

const WishlistPage = () => {
  const [items, setItems] = useState([]);
  const [loading, setLoading] = useState(true);
  const { addToCart } = useContext(CartContext);

  useEffect(() => {
    fetchWishlist();
  }, []);

  const fetchWishlist = async () => {
    try {
      setLoading(true);
      const { data } = await wishlistAPI.get();
      setItems(data.data || data.wishlist || data.items || []);
    } catch (err) {
      console.error('Failed to fetch wishlist:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleRemove = async (productId) => {
    try {
      await wishlistAPI.remove(productId);
      setItems(prev => prev.filter(item => (item._id || item.product?._id) !== productId));
    } catch (err) {
      console.error('Failed to remove:', err);
    }
  };

  const handleAddToCart = async (productId) => {
    await addToCart(productId, 1);
  };

  if (loading) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center', minHeight: 'calc(100vh - 70px)' }}>
        <p style={{ color: 'var(--text-secondary)' }}>Loading wishlist...</p>
      </div>
    );
  }

  return (
    <div className="container animate-fade-in" style={{ paddingTop: '40px', paddingBottom: '80px', minHeight: 'calc(100vh - 70px)' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', margin: 0 }}>❤️ My Wishlist</h1>
          <p style={{ color: 'var(--text-secondary)', marginTop: '4px' }}>{items.length} saved item{items.length !== 1 ? 's' : ''}</p>
        </div>
      </div>

      {items.length === 0 ? (
        <div style={{ textAlign: 'center', padding: '80px 20px' }}>
          <div style={{ fontSize: '5rem', marginBottom: '20px' }}>💔</div>
          <h2 style={{ marginBottom: '12px' }}>Your wishlist is empty</h2>
          <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>Browse products and tap the heart icon to save items here.</p>
          <Link to="/products"><button className="btn btn-primary">Browse Products</button></Link>
        </div>
      ) : (
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(260px, 1fr))', gap: '24px' }}>
          {items.map(item => {
            const product = item.product || item;
            const productId = product._id || item._id;
            const name = product.name || 'Product';
            const price = product.price || 0;
            const image = product.images?.[0];

            return (
              <div key={productId} className="product-card-hover" style={{ backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-md)', overflow: 'hidden', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)', position: 'relative' }}>
                <button onClick={() => handleRemove(productId)} style={{ position: 'absolute', top: '12px', right: '12px', background: 'white', border: 'none', borderRadius: '50%', width: '36px', height: '36px', fontSize: '1.1rem', cursor: 'pointer', boxShadow: 'var(--shadow-sm)', zIndex: 2 }}>
                  ❌
                </button>

                <Link to={`/products/${productId}`}>
                  <div style={{ height: '180px', backgroundColor: '#f8fafc', display: 'flex', justifyContent: 'center', alignItems: 'center', borderBottom: '1px solid var(--border)', overflow: 'hidden' }}>
                    {image
                      ? <img src={image} alt={name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                      : <span style={{ fontSize: '5rem' }}>📦</span>
                    }
                  </div>
                </Link>

                <div style={{ padding: '16px' }}>
                  <h3 style={{ fontSize: '1.05rem', fontWeight: '700', marginBottom: '12px', minHeight: '42px', lineHeight: '1.3' }}>{name}</h3>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
                    <span style={{ fontSize: '1.2rem', fontWeight: '800' }}>Rs. {price}</span>
                    <button className="btn btn-primary" style={{ padding: '8px 16px', fontSize: '0.85rem' }} onClick={() => handleAddToCart(productId)}>Add to Cart</button>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
};

export default WishlistPage;
