import React, { useContext } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { CartContext } from '../../context/CartContext';

const CartPage = () => {
  const { cart, removeFromCart, clearCart } = useContext(CartContext);
  const navigate = useNavigate();
  const items = cart?.items || [];

  if (items.length === 0) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center', minHeight: 'calc(100vh - 70px)' }}>
        <div style={{ fontSize: '4rem', marginBottom: '16px' }}>🛒</div>
        <h2 style={{ marginBottom: '8px' }}>Your cart is empty</h2>
        <p style={{ color: 'var(--text-secondary)', marginBottom: '24px' }}>Add some products to get started!</p>
        <Link to="/products"><button className="btn btn-primary">Browse Products</button></Link>
      </div>
    );
  }

  const quickItems = items.filter(i => (i.type || i.product?.deliveryType || i.deliveryType) === 'quick');
  const ecoItems = items.filter(i => (i.type || i.product?.deliveryType || i.deliveryType) !== 'quick');

  const subtotal = items.reduce((sum, item) => {
    const price = item.product?.price || item.price || 0;
    const qty = item.qty || item.quantity || 1;
    return sum + price * qty;
  }, 0);

  const quickFee = quickItems.length > 0 ? 50 : 0;
  const ecoFee = ecoItems.length > 0 ? 100 : 0;
  const grandTotal = subtotal + quickFee + ecoFee;

  const handleRemove = async (itemId) => {
    try { await removeFromCart(itemId); }
    catch (err) { console.error('Failed to remove:', err); }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px 20px', minHeight: 'calc(100vh - 70px)' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px', flexWrap: 'wrap', gap: '12px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', margin: '0 0 4px 0' }}>🛒 Your Cart</h1>
          <p style={{ color: 'var(--text-secondary)' }}>{items.length} item{items.length !== 1 ? 's' : ''}</p>
        </div>
        <button className="btn" style={{ border: '1px solid #ef4444', color: '#ef4444', padding: '8px 16px', fontSize: '0.9rem' }} onClick={clearCart}>
          Clear Cart
        </button>
      </div>

      <div className="cart-layout">
        <div className="cart-items-col">
          {/* Quick Commerce Items */}
          {quickItems.length > 0 && (
            <div style={{ backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)', overflow: 'hidden', marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 20px', backgroundColor: '#fff7ed', borderBottom: '1px solid #fed7aa' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '1.3rem' }}>⚡</span>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '1rem', color: '#c2410c' }}>Quick Delivery</h3>
                    <p style={{ margin: 0, fontSize: '0.8rem', color: '#c2410c', opacity: 0.8 }}>15-30 minutes</p>
                  </div>
                </div>
              </div>
              <div style={{ padding: '12px 20px' }}>
                {quickItems.map(item => <CartItem key={item._id || item.product?._id} item={item} onRemove={handleRemove} />)}
              </div>
            </div>
          )}

          {/* E-Commerce Items */}
          {ecoItems.length > 0 && (
            <div style={{ backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)', overflow: 'hidden', marginBottom: '20px' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '14px 20px', backgroundColor: '#ecfdf5', borderBottom: '1px solid #a7f3d0' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '1.3rem' }}>📦</span>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '1rem', color: '#065f46' }}>Standard Shipping</h3>
                    <p style={{ margin: 0, fontSize: '0.8rem', color: '#065f46', opacity: 0.8 }}>2-3 business days</p>
                  </div>
                </div>
              </div>
              <div style={{ padding: '12px 20px' }}>
                {ecoItems.map(item => <CartItem key={item._id || item.product?._id} item={item} onRemove={handleRemove} />)}
              </div>
            </div>
          )}
        </div>

        {/* Summary Sidebar */}
        <div className="cart-summary-col">
          <div style={{ backgroundColor: 'var(--surface)', padding: '24px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)', position: 'sticky', top: '90px' }}>
            <h3 style={{ fontSize: '1.3rem', marginBottom: '20px' }}>Order Summary</h3>
            <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px', color: 'var(--text-secondary)' }}><span>Subtotal</span><span>Rs. {subtotal.toFixed(0)}</span></div>
            {quickFee > 0 && <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px', color: 'var(--text-secondary)' }}><span>Quick Delivery ⚡</span><span>Rs. {quickFee}</span></div>}
            {ecoFee > 0 && <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '12px', color: 'var(--text-secondary)' }}><span>Standard Shipping 📦</span><span>Rs. {ecoFee}</span></div>}
            <div style={{ height: '2px', backgroundColor: 'var(--border)', margin: '16px 0' }}></div>
            <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '1.4rem', fontWeight: '800', marginBottom: '24px' }}><span>Total</span><span>Rs. {grandTotal.toFixed(0)}</span></div>
            <button className="btn btn-primary" style={{ width: '100%', padding: '16px', fontSize: '1.05rem' }} onClick={() => navigate('/checkout')}>
              Proceed to Checkout
            </button>
            <p style={{ textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '16px' }}>
              Items from different categories will be shipped separately.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
};

const CartItem = ({ item, onRemove }) => {
  const name = item.product?.name || item.name || 'Product';
  const price = item.product?.price || item.price || 0;
  const qty = item.qty || item.quantity || 1;
  const image = item.product?.images?.[0];

  return (
    <div style={{ display: 'flex', alignItems: 'center', padding: '14px 0', borderBottom: '1px solid var(--border)', gap: '16px', flexWrap: 'wrap' }}>
      <div style={{ width: '60px', height: '60px', borderRadius: 'var(--radius-sm)', backgroundColor: '#f8fafc', display: 'flex', justifyContent: 'center', alignItems: 'center', flexShrink: 0, overflow: 'hidden' }}>
        {image ? <img src={image} alt={name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} /> : <span style={{ fontSize: '2rem' }}>📦</span>}
      </div>
      <div style={{ flex: 1, minWidth: '120px' }}>
        <h4 style={{ fontSize: '1rem', margin: '0 0 4px 0', fontWeight: '600' }}>{name}</h4>
        <div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Rs. {price} × {qty}</div>
      </div>
      <div style={{ fontWeight: '700', fontSize: '1.05rem', minWidth: '80px', textAlign: 'right' }}>Rs. {(price * qty).toFixed(0)}</div>
      <button onClick={() => onRemove(item._id)} style={{ background: 'none', border: 'none', color: '#ef4444', fontSize: '1.2rem', cursor: 'pointer', padding: '8px', marginLeft: '4px' }}>✕</button>
    </div>
  );
};

export default CartPage;
