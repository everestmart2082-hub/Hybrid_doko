import React from 'react';
import { Link, useLocation } from 'react-router-dom';

const BottomNav = () => {
    const location = useLocation();
    const currentPath = location.pathname;

    // Don't show nav on auth pages
    if (currentPath === '/login' || currentPath === '/register') {
        return null;
    }

    return (
        <nav className="bottom-nav">
            <Link to="/" className={`nav-item ${currentPath === '/' ? 'active' : ''}`}>
                <span className="nav-icon">🏠</span>
                <span>Home</span>
            </Link>

            <Link to="/orders/available" className={`nav-item ${currentPath.includes('/orders') ? 'active' : ''}`}>
                <span className="nav-icon">📦</span>
                <span>Orders</span>
            </Link>

            <Link to="/earnings" className={`nav-item ${currentPath === '/earnings' ? 'active' : ''}`}>
                <span className="nav-icon">💰</span>
                <span>Earnings</span>
            </Link>

            <Link to="/map" className={`nav-item ${currentPath === '/map' ? 'active' : ''}`}>
                <span className="nav-icon">🗺️</span>
                <span>Map</span>
            </Link>

            <Link to="/profile" className={`nav-item ${currentPath === '/profile' ? 'active' : ''}`}>
                <span className="nav-icon">👤</span>
                <span>Profile</span>
            </Link>
        </nav>
    );
};

export default BottomNav;
