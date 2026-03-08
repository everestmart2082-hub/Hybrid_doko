import React, { useState, useContext, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { CartContext } from '../../context/CartContext';
import { AuthContext } from '../../context/AuthContext';
import { orderAPI, addressAPI } from '../../services/api';

const CheckoutPage = () => {
  const { cart, clearCart } = useContext(CartContext);
  const { user } = useContext(AuthContext);
  const navigate = useNavigate();

  const [addresses, setAddresses] = useState([]);
  const [selectedAddress, setSelectedAddress] = useState(null);
  const [newAddr, setNewAddr] = useState({ address: '', city: '', landmark: '', phone: '' });
  const [payment, setPayment] = useState('khalti');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  useEffect(() => {
    if (user) {
      addressAPI.getAll().then(res => {
        const addrs = res.data.addresses || [];
        setAddresses(addrs);
        if (res.data.defaultAddress) {
          setSelectedAddress(res.data.defaultAddress);
        } else if (addrs.length > 0) {
          setSelectedAddress(addrs[0]._id);
        }
      }).catch(() => { });
    }
  }, [user]);

  if (!user) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}>
        <h2>Please log in to continue checkout</h2>
        <button className="btn btn-primary" style={{ marginTop: '20px' }} onClick={() => navigate('/login')}>Log In</button>
      </div>
    );
  }

  const items = cart?.items || [];
  if (items.length === 0) {
    return (
      <div className="container animate-fade-in" style={{ padding: '80px 20px', textAlign: 'center' }}>
        <h2>Your cart is empty</h2>
        <button className="btn btn-primary" style={{ marginTop: '20px' }} onClick={() => navigate('/products')}>Browse Products</button>
      </div>
    );
  }

  const quickItems = items.filter(i => (i.type || i.product?.deliveryType || i.deliveryType) === 'quick');
  const ecoItems = items.filter(i => (i.type || i.product?.deliveryType || i.deliveryType) !== 'quick');

  const itemTotal = items.reduce((sum, item) => {
    const price = item.product?.price || item.price || 0;
    const qty = item.qty || item.quantity || 1;
    return sum + price * qty;
  }, 0);

  const hasQuick = quickItems.length > 0;
  const hasEco = ecoItems.length > 0;
  const quickFee = hasQuick ? 50 : 0;
  const ecoFee = hasEco ? 100 : 0;
  const grandTotal = itemTotal + quickFee + ecoFee;

  const paymentMap = { khalti: 'khalti', esewa: 'esewa', fonepay: 'fonepay', cod: 'cashOnDelivery' };

  const handleCheckout = async (e) => {
    e.preventDefault();
    const deliveryAddress = selectedAddress
      ? addresses.find(a => a._id === selectedAddress)
      : { address: newAddr.address, city: newAddr.city, landmark: newAddr.landmark, phone: newAddr.phone };

    if (!deliveryAddress?.address && !newAddr.address) {
      setError('Please enter your street address');
      return;
    }

    setLoading(true);
    setError('');

    try {
      const orderData = {
        items: items.map(item => ({
          productId: item.product?._id || item.productId,
          qty: item.qty || item.quantity || 1,
          name: item.product?.name || item.name,
          price: item.product?.price || item.price,
        })),
        address: deliveryAddress,
        paymentMethod: paymentMap[payment] || 'cashOnDelivery',
        deliveryType: hasQuick ? 'quick' : 'ecommerce',
        total: grandTotal,
        deliveryCharge: quickFee + ecoFee,
      };

      const { data } = await orderAPI.create(orderData);
      await clearCart();
      navigate(`/orders/${data.data?._id || data._id || 'placed'}`, { state: { justPlaced: true } });
    } catch (err) {
      setError(err.response?.data?.message || 'Failed to place order. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="container animate-fade-in" style={styles.page}>
      <div style={{ marginBottom: '30px' }}>
        <h1 style={styles.pageTitle}>Secure Checkout</h1>
        {hasQuick && hasEco && (
          <div style={{ backgroundColor: '#fff7ed', border: '1px solid #fed7aa', color: '#c2410c', padding: '12px 16px', borderRadius: 'var(--radius-sm)', marginTop: '10px', display: 'flex', alignItems: 'center', gap: '8px' }}>
            <span style={{ fontSize: '1.2rem' }}>ℹ️</span>
            <span>This order contains items from both Quick Commerce and standard E-Commerce. They will arrive in separate deliveries.</span>
          </div>
        )}
        {error && (
          <div style={{ backgroundColor: '#fef2f2', border: '1px solid #fecaca', color: '#dc2626', padding: '12px 16px', borderRadius: 'var(--radius-sm)', marginTop: '10px' }}>
            {error}
          </div>
        )}
      </div>

      <div className="checkout-layout">
        <div className="checkout-form-col">
          <form id="checkout-form" onSubmit={handleCheckout}>
            <div style={styles.card}>
              <h2 style={styles.cardTitle}>1. Delivery Address</h2>
              {addresses.length > 0 && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '16px' }}>
                  {addresses.map(addr => (
                    <label key={addr._id} style={styles.paymentOption(selectedAddress === addr._id)}>
                      <input type="radio" value={addr._id} checked={selectedAddress === addr._id} onChange={() => { setSelectedAddress(addr._id); }} style={{ marginRight: '12px' }} />
                      <span>{addr.label || addr.address} {addr.city ? `— ${addr.city}` : ''}</span>
                    </label>
                  ))}
                  <label style={styles.paymentOption(!selectedAddress)}>
                    <input type="radio" checked={!selectedAddress} onChange={() => setSelectedAddress(null)} style={{ marginRight: '12px' }} />
                    <span>Enter new address</span>
                  </label>
                </div>
              )}
              {(!selectedAddress || addresses.length === 0) && (
                <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
                  <div style={styles.inputGroup}>
                    <label style={styles.fieldLabel}>Street Address *</label>
                    <input
                      type="text"
                      required={!selectedAddress}
                      value={newAddr.address}
                      onChange={(e) => setNewAddr({ ...newAddr, address: e.target.value })}
                      placeholder="e.g. 123 Main Street, Apt 4B, Thamel"
                      style={styles.input}
                    />
                  </div>
                  <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap' }}>
                    <div style={{ ...styles.inputGroup, flex: 1, minWidth: '180px' }}>
                      <label style={styles.fieldLabel}>City / Area *</label>
                      <input
                        type="text"
                        required={!selectedAddress}
                        value={newAddr.city}
                        onChange={(e) => setNewAddr({ ...newAddr, city: e.target.value })}
                        placeholder="e.g. Kathmandu"
                        style={styles.input}
                      />
                    </div>
                    <div style={{ ...styles.inputGroup, flex: 1, minWidth: '180px' }}>
                      <label style={styles.fieldLabel}>Landmark</label>
                      <input
                        type="text"
                        value={newAddr.landmark}
                        onChange={(e) => setNewAddr({ ...newAddr, landmark: e.target.value })}
                        placeholder="e.g. Near City Center Mall"
                        style={styles.input}
                      />
                    </div>
                  </div>
                  <div style={{ ...styles.inputGroup, maxWidth: '280px' }}>
                    <label style={styles.fieldLabel}>Phone Number *</label>
                    <input
                      type="tel"
                      required={!selectedAddress}
                      value={newAddr.phone}
                      onChange={(e) => setNewAddr({ ...newAddr, phone: e.target.value })}
                      placeholder="e.g. 9801234567"
                      style={styles.input}
                    />
                  </div>
                </div>
              )}
            </div>

            <div style={{ ...styles.card, marginTop: '24px' }}>
              <h2 style={styles.cardTitle}>2. Payment Method</h2>
              <div style={styles.paymentOptions}>
                {[
                  { value: 'khalti', label: '💜 Khalti Wallet' },
                  { value: 'esewa', label: '💚 eSewa' },
                  { value: 'fonepay', label: '🔵 FonePay' },
                  { value: 'cod', label: '💵 Cash on Delivery' },
                ].map(opt => (
                  <label key={opt.value} style={styles.paymentOption(payment === opt.value)}>
                    <input type="radio" value={opt.value} checked={payment === opt.value} onChange={e => setPayment(e.target.value)} style={{ marginRight: '12px' }} />
                    <span>{opt.label}</span>
                  </label>
                ))}
              </div>
            </div>
          </form>
        </div>

        <div className="checkout-summary-col" style={{ backgroundColor: '#f8fafc', padding: '30px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)', position: 'sticky', top: '90px' }}>
          <h3 style={styles.summaryTitle}>Final Order Summary</h3>
          <div style={{ maxHeight: '200px', overflowY: 'auto', marginBottom: '16px' }}>
            {items.map((item, idx) => (
              <div key={idx} style={{ display: 'flex', justifyContent: 'space-between', marginBottom: '10px', fontSize: '0.9rem' }}>
                <span style={{ color: 'var(--text-secondary)' }}>{item.product?.name || item.name} × {item.qty || item.quantity || 1}</span>
                <span>Rs. {((item.product?.price || item.price || 0) * (item.qty || item.quantity || 1)).toFixed(0)}</span>
              </div>
            ))}
          </div>
          <div style={styles.summaryRow}><span>Items Subtotal</span><span>Rs. {itemTotal.toFixed(0)}</span></div>
          {hasQuick && <div style={styles.summaryRow}><span>Quick Delivery Fee ⚡</span><span>Rs. {quickFee}</span></div>}
          {hasEco && <div style={styles.summaryRow}><span>Standard Shipping Fee 📦</span><span>Rs. {ecoFee}</span></div>}
          <div style={styles.divider}></div>
          <div style={styles.totalRow}><span>Total to Pay</span><span style={{ color: 'var(--primary-dark)' }}>Rs. {grandTotal.toFixed(0)}</span></div>
          <button type="submit" form="checkout-form" className="btn btn-primary" style={styles.checkoutBtn} disabled={loading}>
            {loading ? 'Placing Order...' : `Confirm Order • Rs. ${grandTotal.toFixed(0)}`}
          </button>
          <p style={{ textAlign: 'center', fontSize: '0.8rem', color: 'var(--text-secondary)', marginTop: '20px' }}>
            By placing your order, you agree to Doko's Terms & Conditions.
          </p>
        </div>
      </div>
    </div>
  );
};

const styles = {
  page: { padding: '40px 20px', minHeight: 'calc(100vh - 70px)' },
  pageTitle: { fontSize: '2rem', margin: 0 },
  card: { backgroundColor: 'var(--surface)', padding: '30px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)' },
  cardTitle: { fontSize: '1.4rem', marginBottom: '20px' },
  input: { width: '100%', padding: '16px', borderRadius: 'var(--radius-sm)', border: '1px solid var(--border)', fontSize: '1rem', resize: 'vertical', fontFamily: 'inherit', outline: 'none', transition: 'var(--transition)' },
  paymentOptions: { display: 'flex', flexDirection: 'column', gap: '16px' },
  paymentOption: (isActive) => ({ display: 'flex', alignItems: 'center', padding: '16px 20px', border: `2px solid ${isActive ? 'var(--primary)' : 'var(--border)'}`, borderRadius: 'var(--radius-sm)', cursor: 'pointer', backgroundColor: isActive ? '#ecfdf5' : 'transparent', fontWeight: isActive ? '600' : '400', transition: 'var(--transition)' }),
  summarySidebar: { width: '380px', backgroundColor: '#f8fafc', padding: '30px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-md)', border: '1px solid var(--border)', position: 'sticky', top: '90px' },
  summaryTitle: { fontSize: '1.4rem', marginBottom: '24px' },
  summaryRow: { display: 'flex', justifyContent: 'space-between', marginBottom: '16px', color: 'var(--text-secondary)', fontWeight: '500' },
  divider: { height: '1px', backgroundColor: 'var(--border)', margin: '20px 0' },
  totalRow: { display: 'flex', justifyContent: 'space-between', fontSize: '1.6rem', fontWeight: '800', marginBottom: '30px' },
  checkoutBtn: { width: '100%', padding: '18px', fontSize: '1.15rem', boxShadow: '0 8px 20px rgba(16, 185, 129, 0.4)', borderRadius: 'var(--radius-md)' },
  inputGroup: { display: 'flex', flexDirection: 'column', gap: '6px' },
  fieldLabel: { fontSize: '0.85rem', fontWeight: '600', color: 'var(--text-primary)' }
};

export default CheckoutPage;
