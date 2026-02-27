import React from 'react';
import { Link } from 'react-router-dom';

const Footer = () => (
    <footer style={styles.footer}>
        <div className="container" style={styles.container}>

            <div style={styles.grid}>
                {/* Brand */}
                <div>
                    <h3 style={styles.brand}>🛍️ DOKO</h3>
                    <p style={styles.tagline}>Nepal's hybrid quick-commerce & e-commerce platform. Get groceries in 15 minutes or shop electronics nationwide.</p>
                    <div style={styles.social}>
                        <a href="#" style={styles.socialLink}>📘</a>
                        <a href="#" style={styles.socialLink}>📷</a>
                        <a href="#" style={styles.socialLink}>🐦</a>
                    </div>
                </div>

                {/* Quick Links */}
                <div>
                    <h4 style={styles.heading}>Quick Links</h4>
                    <Link to="/products?mode=quick" style={styles.link}>Quick Commerce</Link>
                    <Link to="/products?mode=ecommerce" style={styles.link}>E-Commerce</Link>
                    <Link to="/orders" style={styles.link}>Track Orders</Link>
                    <Link to="/wishlist" style={styles.link}>Wishlist</Link>
                </div>

                {/* Help */}
                <div>
                    <h4 style={styles.heading}>Help & Support</h4>
                    <a href="#" style={styles.link}>FAQs</a>
                    <a href="#" style={styles.link}>Shipping Policy</a>
                    <a href="#" style={styles.link}>Returns & Refunds</a>
                    <a href="#" style={styles.link}>Contact Us</a>
                </div>

                {/* Contact */}
                <div>
                    <h4 style={styles.heading}>Contact</h4>
                    <p style={styles.contactLine}>📍 Kathmandu, Nepal</p>
                    <p style={styles.contactLine}>📞 +977 9800000000</p>
                    <p style={styles.contactLine}>✉️ support@doko.com.np</p>
                </div>
            </div>

            <div style={styles.bottom}>
                <p>© 2026 Doko Platform. All rights reserved.</p>
                <div style={{ display: 'flex', gap: '24px' }}>
                    <a href="#" style={styles.bottomLink}>Privacy Policy</a>
                    <a href="#" style={styles.bottomLink}>Terms of Service</a>
                </div>
            </div>
        </div>
    </footer>
);

const styles = {
    footer: {
        backgroundColor: '#111827',
        color: '#9ca3af',
        paddingTop: '60px',
        marginTop: '80px'
    },
    container: {
        maxWidth: '1280px',
        margin: '0 auto',
        padding: '0 20px'
    },
    grid: {
        display: 'grid',
        gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))',
        gap: '40px',
        paddingBottom: '40px',
        borderBottom: '1px solid #1f2937'
    },
    brand: {
        fontSize: '1.8rem',
        color: 'white',
        marginBottom: '16px'
    },
    tagline: {
        fontSize: '0.9rem',
        lineHeight: '1.6',
        marginBottom: '16px'
    },
    social: {
        display: 'flex',
        gap: '12px'
    },
    socialLink: {
        fontSize: '1.5rem',
        textDecoration: 'none',
        transition: 'transform 0.2s',
        display: 'inline-block'
    },
    heading: {
        color: 'white',
        fontSize: '1.1rem',
        marginBottom: '16px',
        fontWeight: '700'
    },
    link: {
        display: 'block',
        color: '#9ca3af',
        textDecoration: 'none',
        marginBottom: '10px',
        fontSize: '0.95rem',
        transition: 'color 0.2s'
    },
    contactLine: {
        marginBottom: '10px',
        fontSize: '0.95rem'
    },
    bottom: {
        display: 'flex',
        justifyContent: 'space-between',
        alignItems: 'center',
        padding: '24px 0',
        fontSize: '0.85rem'
    },
    bottomLink: {
        color: '#9ca3af',
        textDecoration: 'none',
        fontSize: '0.85rem'
    }
};

export default Footer;
