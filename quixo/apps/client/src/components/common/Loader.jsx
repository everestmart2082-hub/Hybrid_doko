import React from 'react';

const Loader = ({ text = 'Loading...' }) => (
    <div style={styles.wrapper}>
        <div style={styles.spinner}></div>
        <p style={styles.text}>{text}</p>
        <style>{`
      @keyframes spin {
        0% { transform: rotate(0deg); }
        100% { transform: rotate(360deg); }
      }
    `}</style>
    </div>
);

const styles = {
    wrapper: {
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
        minHeight: '300px',
        padding: '60px',
    },
    spinner: {
        width: '48px',
        height: '48px',
        border: '4px solid var(--border)',
        borderTop: '4px solid var(--primary)',
        borderRadius: '50%',
        animation: 'spin 0.8s linear infinite',
        marginBottom: '16px'
    },
    text: {
        color: 'var(--text-secondary)',
        fontSize: '1rem',
        fontWeight: '500'
    }
};

export default Loader;
