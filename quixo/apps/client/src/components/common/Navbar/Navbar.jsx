import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import styles from './Navbar.module.css';

const Navbar = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const location = useLocation();
  const navigate = useNavigate();

  const toggleMenu = () => setIsMenuOpen(!isMenuOpen);

  const handleSearch = (e) => {
    e.preventDefault();
    if (searchQuery.trim()) {
      navigate(`/products?search=${encodeURIComponent(searchQuery)}`);
      setSearchQuery('');
    }
  };

  const navLinks = [
    { name: 'Home', path: '/' },
    { name: 'Products', path: '/products' },
    { name: 'Orders', path: '/orders' },
  ];

  const isActive = (path) => {
    if (path === '/' && location.pathname !== '/') return false;
    return location.pathname.startsWith(path);
  };

  return (
    <header className={styles.navbar}>
      <div className={`container ${styles.navContainer}`}>

        {/* Logo */}
        <Link to="/" className={styles.logo}>
          <span className={styles.logoIcon}>🛍️</span>
          <span className={styles.logoText}>DOKO</span>
        </Link>

        {/* Search Bar (desktop) */}
        <form onSubmit={handleSearch} className={styles.searchForm} style={{
          flex: 1, maxWidth: '480px', margin: '0 32px', display: 'flex'
        }}>
          <div style={{ position: 'relative', width: '100%' }}>
            <input
              type="text"
              placeholder="Search products, brands..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              style={{
                width: '100%', padding: '10px 42px 10px 16px',
                border: '2px solid var(--border)', borderRadius: '100px',
                fontSize: '0.95rem', fontFamily: 'inherit', outline: 'none',
                transition: 'border-color 0.2s'
              }}
              onFocus={(e) => e.target.style.borderColor = 'var(--primary)'}
              onBlur={(e) => e.target.style.borderColor = 'var(--border)'}
            />
            <button type="submit" style={{
              position: 'absolute', right: '4px', top: '50%', transform: 'translateY(-50%)',
              background: 'var(--primary)', border: 'none', borderRadius: '50%',
              width: '34px', height: '34px', display: 'flex', alignItems: 'center',
              justifyContent: 'center', cursor: 'pointer', fontSize: '1rem'
            }}>🔍</button>
          </div>
        </form>

        {/* Desktop Links */}
        <nav className={styles.desktopNav}>
          {navLinks.map((link) => (
            <Link
              key={link.name}
              to={link.path}
              className={`${styles.navLink} ${isActive(link.path) ? styles.active : ''}`}
            >
              {link.name}
            </Link>
          ))}
        </nav>

        {/* Right Actions */}
        <div className={styles.actions}>
          <Link to="/wishlist" className={styles.iconBtn} title="Wishlist">
            ❤️
          </Link>
          <Link to="/login" className={styles.iconBtn} title="Login / Profile">
            👤
          </Link>
          <Link to="/cart" className={styles.iconBtn} title="Cart">
            🛒 <span className={styles.cartBadge}>3</span>
          </Link>

          <button className={styles.mobileMenuBtn} onClick={toggleMenu}>
            {isMenuOpen ? '✕' : '☰'}
          </button>
        </div>
      </div>

      {/* Mobile Menu */}
      {isMenuOpen && (
        <div className={styles.mobileNav}>
          {/* Mobile Search */}
          <form onSubmit={(e) => { handleSearch(e); setIsMenuOpen(false); }} style={{ padding: '8px 20px 16px' }}>
            <input
              type="text" placeholder="Search products..."
              value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)}
              style={{ width: '100%', padding: '10px 16px', border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)', fontSize: '0.95rem', fontFamily: 'inherit' }}
            />
          </form>
          {navLinks.map((link) => (
            <Link key={link.name} to={link.path} className={styles.mobileLink} onClick={() => setIsMenuOpen(false)}>
              {link.name}
            </Link>
          ))}
          <Link to="/wishlist" className={styles.mobileLink} onClick={() => setIsMenuOpen(false)}>Wishlist</Link>
          <Link to="/login" className={styles.mobileLink} onClick={() => setIsMenuOpen(false)}>Login / Profile</Link>
        </div>
      )}
    </header>
  );
};

export default Navbar;
