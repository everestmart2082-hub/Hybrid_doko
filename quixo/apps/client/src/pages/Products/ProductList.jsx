import React, { useState, useEffect, useContext } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { productAPI } from '../../services/api';
import { CartContext } from '../../context/CartContext';

const defaultCategories = ['All', 'Fruits', 'Vegetables', 'Dairy', 'Bakery', 'Electronics', 'Fashion', 'Home Appliances', 'Sports'];

const ProductList = () => {
  const location = useLocation();
  const { addToCart } = useContext(CartContext);
  const [addedId, setAddedId] = useState(null);

  const params = new URLSearchParams(location.search);
  const initialCat = params.get('category') || 'All';
  const initialSearch = params.get('search') || '';

  const [activeCategory, setActiveCategory] = useState(initialCat);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchProducts();
  }, [activeCategory]);

  const fetchProducts = async () => {
    try {
      setLoading(true);
      const queryParams = {};
      if (activeCategory !== 'All') queryParams.category = activeCategory;
      if (initialSearch) queryParams.search = initialSearch;

      const { data } = await productAPI.getAll(queryParams);
      setProducts(data.message || data.data || data.products || []);
    } catch (err) {
      console.error('Failed to fetch products:', err);
      setProducts([]);
    } finally {
      setLoading(false);
    }
  };

  const handleAddToCart = async (e, productId) => {
    e.preventDefault();
    e.stopPropagation();
    const result = await addToCart(productId, 1);
    if (result?.success) {
      setAddedId(productId);
      setTimeout(() => setAddedId(null), 1200);
    }
  };

  return (
    <div className="container animate-fade-in" style={styles.page}>

      {/* Sidebar Filters */}
      <aside style={styles.sidebar} className="product-sidebar">
        <h3 style={styles.sidebarTitle}>Categories</h3>
        <ul style={styles.categoryList}>
          {defaultCategories.map(cat => (
            <li key={cat}>
              <button
                onClick={() => setActiveCategory(cat)}
                style={{
                  ...styles.categoryBtn,
                  ...(activeCategory.toLowerCase() === cat.toLowerCase()
                    ? { backgroundColor: '#ecfdf5', color: 'var(--primary-dark)', fontWeight: '700' }
                    : {})
                }}
              >
                {cat}
              </button>
            </li>
          ))}
        </ul>
      </aside>

      {/* Main Content */}
      <main style={styles.mainContent}>
        <div style={styles.header}>
          <h1 style={{ fontSize: '1.8rem', margin: 0 }}>
            {activeCategory === 'All' ? 'All Products' : `${activeCategory}`}
          </h1>
          <span style={styles.resultCount}>
            {loading ? 'Loading...' : `${products.length} results`}
          </span>
        </div>

        {!loading && products.length === 0 && (
          <div style={{ textAlign: 'center', padding: '60px 20px' }}>
            <div style={{ fontSize: '4rem', marginBottom: '16px' }}>🔍</div>
            <h2>No products found</h2>
            <p style={{ color: 'var(--text-secondary)' }}>Try a different category or check back later.</p>
          </div>
        )}

        <div style={styles.grid}>
          {products.map((product) => (
            <Link to={`/products/${product._id}`} key={product._id} style={{ textDecoration: 'none' }}>
              <div style={styles.card} className="product-card-hover">
                <div style={styles.imagePlaceholder}>
                  {(product.photos?.[0] || product.images?.[0])
                    ? <img src={product.photos?.[0] || product.images?.[0]} alt={product.name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                    : <span style={{ fontSize: '4rem' }}>📦</span>
                  }
                </div>
                <div style={styles.cardBody}>
                  <div style={styles.weight}>{product.deliveryCategory || product.category || ''}</div>
                  <h3 style={styles.name}>{product.name}</h3>
                  <div style={styles.priceRow}>
                    <span style={styles.price}>Rs. {product.pricePerUnit || product.price}</span>
                    <button
                      style={{
                        ...styles.addBtn,
                        backgroundColor: addedId === product._id ? '#ecfdf5' : '#fff7ed',
                        color: addedId === product._id ? 'var(--primary-dark)' : 'var(--primary-dark)',
                        borderColor: addedId === product._id ? 'var(--primary)' : '#fed7aa'
                      }}
                      onClick={(e) => handleAddToCart(e, product._id)}
                    >
                      {addedId === product._id ? '✓ Added' : 'Add'}
                    </button>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </main>
    </div>
  );
};

const styles = {
  page: { display: 'flex', gap: '30px', paddingTop: '40px', paddingBottom: '80px', minHeight: 'calc(100vh - 70px)' },
  sidebar: { width: '240px', flexShrink: '0', backgroundColor: 'var(--surface)', padding: '24px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)', height: 'fit-content', position: 'sticky', top: '90px' },
  sidebarTitle: { fontSize: '1.2rem', marginBottom: '20px', paddingBottom: '10px', borderBottom: '1px solid var(--border)' },
  categoryList: { display: 'flex', flexDirection: 'column', gap: '6px' },
  categoryBtn: { width: '100%', textAlign: 'left', padding: '10px 16px', backgroundColor: 'transparent', borderRadius: 'var(--radius-sm)', color: 'var(--text-secondary)', fontWeight: '500', fontSize: '0.95rem', transition: 'var(--transition)', border: 'none', cursor: 'pointer' },
  mainContent: { flex: '1' },
  header: { display: 'flex', justifyContent: 'space-between', alignItems: 'baseline', marginBottom: '24px', flexWrap: 'wrap', gap: '8px' },
  resultCount: { color: 'var(--text-secondary)', fontSize: '0.9rem' },
  grid: { display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(220px, 1fr))', gap: '24px' },
  card: { backgroundColor: 'var(--surface)', borderRadius: 'var(--radius-md)', overflow: 'hidden', boxShadow: 'var(--shadow-sm)', border: '1px solid var(--border)', display: 'flex', flexDirection: 'column', position: 'relative' },
  imagePlaceholder: { height: '180px', backgroundColor: '#f9fafb', display: 'flex', justifyContent: 'center', alignItems: 'center', borderBottom: '1px solid var(--border)', overflow: 'hidden' },
  cardBody: { padding: '16px', display: 'flex', flexDirection: 'column', flex: '1' },
  weight: { color: 'var(--text-secondary)', fontSize: '0.8rem', marginBottom: '6px' },
  name: { fontSize: '1.05rem', fontWeight: '600', marginBottom: 'auto', color: 'var(--text-primary)', paddingBottom: '16px', minHeight: '48px', lineHeight: '1.3' },
  priceRow: { display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginTop: '10px' },
  price: { fontSize: '1.15rem', fontWeight: '700', color: 'var(--text-primary)' },
  addBtn: { border: '1px solid', padding: '6px 16px', borderRadius: '100px', fontWeight: '700', fontSize: '0.9rem', cursor: 'pointer', transition: 'all 0.2s' }
};

export default ProductList;
