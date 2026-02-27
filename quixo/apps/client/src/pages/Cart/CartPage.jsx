import React from 'react';
import { Link } from 'react-router-dom';

const mockCart = [
  // Quick Commerce Items
  { id: 1, name: 'Fresh Organic Apples', price: 290, qty: 1, image: '🍎', type: 'quick' },
  { id: 3, name: 'Amul Taza Milk', price: 100, qty: 2, image: '🥛', type: 'quick' },
  // E-Commerce Items
  { id: 11, name: 'Wireless Noise Cancelling Earbuds', price: 3499, qty: 1, image: '🎧', type: 'ecommerce' }
];

const CartPage = () => {
  const quickItems = mockCart.filter(i => i.type === 'quick');
  const ecoItems = mockCart.filter(i => i.type === 'ecommerce');

  const quickTotal = quickItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
  const ecoTotal = ecoItems.reduce((sum, item) => sum + (item.price * item.qty), 0);
  const subtotal = quickTotal + ecoTotal;

  // Doko charges a flat delivery fee for quick, standard fee for eco
  const quickFee = quickItems.length > 0 ? 50 : 0;
  const ecoFee = ecoItems.length > 0 ? 100 : 0;
  const totalDelivery = quickFee + ecoFee;
  const grandTotal = subtotal + totalDelivery;

  return (
    <div className="container animate-fade-in" style={styles.page}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '30px' }}>
        <div>
          <h1 style={styles.pageTitle}>Your Hybrid Cart</h1>
          <p style={{ color: 'var(--text-secondary)' }}>You have items from different delivery categories.</p>
        </div>
      </div>

      <div style={styles.content}>

        <div style={styles.cartItemsContainer}>

          {/* Quick Commerce Section */}
          {quickItems.length > 0 && (
            <div style={styles.deliveryGroup}>
              <div style={{ ...styles.groupHeader, backgroundColor: '#ffedd5', borderBottom: '1px solid #fed7aa', color: 'var(--primary-dark)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '1.5rem' }}>⚡</span>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Instant Delivery</h3>
                    <p style={{ margin: 0, fontSize: '0.85rem', opacity: 0.9 }}>Delivered in 15-30 minutes</p>
                  </div>
                </div>
                <div style={{ fontWeight: '700' }}>Rs. {quickTotal}</div>
              </div>
              <div style={styles.groupItems}>
                {quickItems.map(item => <CartItemRow key={item.id} item={item} />)}
              </div>
            </div>
          )}

          {/* E-Commerce Section */}
          {ecoItems.length > 0 && (
            <div style={styles.deliveryGroup}>
              <div style={{ ...styles.groupHeader, backgroundColor: '#f0fdfa', borderBottom: '1px solid #99f6e4', color: '#0f766e' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                  <span style={{ fontSize: '1.5rem' }}>📦</span>
                  <div>
                    <h3 style={{ margin: 0, fontSize: '1.1rem' }}>Standard Shipping</h3>
                    <p style={{ margin: 0, fontSize: '0.85rem', opacity: 0.9 }}>Delivered in 2-3 Business Days</p>
                  </div>
                </div>
                <div style={{ fontWeight: '700' }}>Rs. {ecoTotal}</div>
              </div>
              <div style={styles.groupItems}>
                {ecoItems.map(item => <CartItemRow key={item.id} item={item} />)}
              </div>
            </div>
          )}

        </div>

        <div style={styles.summarySidebar}>
          <h3 style={styles.summaryTitle}>Order Summary</h3>

          <div style={styles.summaryRow}>
            <span>Items Subtotal</span>
            <span>Rs. {subtotal}</span>
          </div>

          {quickFee > 0 && (
            <div style={styles.summaryRow}>
              <span>Quick Delivery Fee ⚡</span>
              <span>Rs. {quickFee}</span>
            </div>
          )}

          {ecoFee > 0 && (
            <div style={styles.summaryRow}>
              <span>Standard Shipping Fee 📦</span>
              <span>Rs. {ecoFee}</span>
            </div>
          )}

          <div style={styles.divider}></div>
          <div style={styles.totalRow}>
            <span>Grand Total</span>
            <span>Rs. {grandTotal}</span>
          </div>

          <Link to="/checkout" style={{ display: 'block', textDecoration: 'none' }}>
            <button className="btn btn-primary" style={styles.checkoutBtn}>
              Proceed to Multiple Checkouts
            </button>
          </Link>

          <div style={{ marginTop: '20px', fontSize: '0.85rem', color: 'var(--text-secondary)', textAlign: 'center' }}>
            Orders with different delivery speeds will be processed as separate shipments.
          </div>
        </div>

      </div>
    </div>
  );
};

const CartItemRow = ({ item }) => (
  <div style={styles.cartItem}>
    <div style={{ ...styles.itemImageRoot, backgroundColor: item.type === 'quick' ? '#fff7ed' : '#f8fafc' }}>
      <span style={{ fontSize: '2.5rem' }}>{item.image}</span>
    </div>
    <div style={styles.itemDetails}>
      <h3 style={styles.itemName}>{item.name}</h3>
      <div style={styles.itemPrice}>Rs. {item.price}</div>
    </div>
    <div style={styles.quantityControl}>
      <button style={styles.qtyBtn}>-</button>
      <span style={styles.qtyValue}>{item.qty}</span>
      <button style={styles.qtyBtn}>+</button>
    </div>
    <div style={styles.itemTotal}>
      Rs. {item.price * item.qty}
    </div>
    <button style={styles.removeBtn}>✕</button>
  </div>
);

const styles = {
  page: { padding: '40px 20px', minHeight: 'calc(100vh - 70px)' },
  pageTitle: { fontSize: '2.2rem', margin: '0 0 8px 0' },
  content: { display: 'flex', gap: '30px', alignItems: 'flex-start' },
  cartItemsContainer: { flex: '1', display: 'flex', flexDirection: 'column', gap: '24px' },

  deliveryGroup: {
    backgroundColor: 'var(--surface)',
    borderRadius: 'var(--radius-lg)',
    boxShadow: 'var(--shadow-md)',
    overflow: 'hidden',
    border: '1px solid var(--border)'
  },
  groupHeader: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: '16px 24px',
  },
  groupItems: {
    padding: '8px 24px 24px 24px'
  },

  cartItem: {
    display: 'flex',
    alignItems: 'center',
    padding: '16px 0',
    borderBottom: '1px solid var(--border)',
  },
  itemImageRoot: {
    width: '70px',
    height: '70px',
    borderRadius: 'var(--radius-sm)',
    display: 'flex',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: '20px'
  },
  itemDetails: { flex: '1' },
  itemName: { fontSize: '1.1rem', marginBottom: '4px', fontWeight: '600' },
  itemPrice: { color: 'var(--text-secondary)', fontWeight: '500' },
  quantityControl: {
    display: 'flex',
    alignItems: 'center',
    border: '1px solid var(--border)',
    borderRadius: 'var(--radius-sm)',
    marginRight: '30px',
    backgroundColor: 'var(--surface)'
  },
  qtyBtn: { padding: '6px 12px', background: 'none', fontSize: '1.1rem', cursor: 'pointer' },
  qtyValue: { padding: '0 12px', fontWeight: '700' },
  itemTotal: { fontWeight: '800', fontSize: '1.15rem', marginRight: '20px', width: '90px', textAlign: 'right', color: 'var(--text-primary)' },
  removeBtn: { background: 'none', color: '#ef4444', fontSize: '1.2rem', padding: '8px', cursor: 'pointer', border: 'none' },

  summarySidebar: {
    width: '360px',
    backgroundColor: 'var(--surface)',
    padding: '30px',
    borderRadius: 'var(--radius-lg)',
    boxShadow: 'var(--shadow-md)',
    border: '1px solid var(--border)',
    position: 'sticky',
    top: '90px'
  },
  summaryTitle: { fontSize: '1.4rem', marginBottom: '24px' },
  summaryRow: { display: 'flex', justifyContent: 'space-between', marginBottom: '16px', color: 'var(--text-secondary)', fontWeight: '500' },
  divider: { height: '2px', backgroundColor: 'var(--border)', margin: '20px 0' },
  totalRow: { display: 'flex', justifyContent: 'space-between', fontSize: '1.5rem', fontWeight: '800', marginBottom: '30px', color: 'var(--text-primary)' },
  checkoutBtn: { width: '100%', padding: '16px', fontSize: '1.1rem', fontWeight: '800', borderRadius: 'var(--radius-md)', border: 'none', cursor: 'pointer' }
};

export default CartPage;
