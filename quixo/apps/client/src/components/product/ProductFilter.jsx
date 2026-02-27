import React from 'react';

const ProductFilter = ({ filters, onFilterChange, isQuick = true }) => {
    const accentColor = isQuick ? 'var(--primary)' : 'var(--secondary)';
    const bgActive = isQuick ? '#ecfdf5' : '#f0fdfa';

    return (
        <div style={styles.container}>
            <h3 style={styles.title}>🔍 Filters</h3>

            {/* Price Range */}
            <div style={styles.section}>
                <h4 style={styles.sectionTitle}>Price Range</h4>
                <div style={styles.priceInputs}>
                    <input
                        type="number" placeholder="Min"
                        value={filters.minPrice || ''}
                        onChange={(e) => onFilterChange({ ...filters, minPrice: e.target.value })}
                        style={styles.input}
                    />
                    <span style={{ color: 'var(--text-secondary)' }}>—</span>
                    <input
                        type="number" placeholder="Max"
                        value={filters.maxPrice || ''}
                        onChange={(e) => onFilterChange({ ...filters, maxPrice: e.target.value })}
                        style={styles.input}
                    />
                </div>
            </div>

            {/* Rating */}
            <div style={styles.section}>
                <h4 style={styles.sectionTitle}>Minimum Rating</h4>
                <div style={styles.ratingButtons}>
                    {[4, 3, 2, 1].map(r => (
                        <button
                            key={r}
                            onClick={() => onFilterChange({ ...filters, rating: filters.rating === r ? null : r })}
                            style={{
                                ...styles.ratingBtn,
                                borderColor: filters.rating === r ? accentColor : 'var(--border)',
                                backgroundColor: filters.rating === r ? bgActive : 'transparent',
                                fontWeight: filters.rating === r ? '700' : '500'
                            }}
                        >
                            {'⭐'.repeat(r)} & up
                        </button>
                    ))}
                </div>
            </div>

            {/* Stock */}
            <div style={styles.section}>
                <h4 style={styles.sectionTitle}>Availability</h4>
                <label style={styles.checkbox}>
                    <input
                        type="checkbox"
                        checked={filters.inStock || false}
                        onChange={(e) => onFilterChange({ ...filters, inStock: e.target.checked })}
                        style={{ marginRight: '8px', accentColor }}
                    />
                    In Stock Only
                </label>
            </div>

            {/* Clear Filters */}
            <button
                onClick={() => onFilterChange({ minPrice: '', maxPrice: '', rating: null, inStock: false })}
                style={{ ...styles.clearBtn, color: accentColor }}
            >
                Clear All Filters
            </button>
        </div>
    );
};

const styles = {
    container: {
        backgroundColor: 'var(--surface)',
        padding: '24px',
        borderRadius: 'var(--radius-lg)',
        boxShadow: 'var(--shadow-sm)',
        border: '1px solid var(--border)'
    },
    title: { fontSize: '1.2rem', marginBottom: '24px', paddingBottom: '12px', borderBottom: '1px solid var(--border)' },
    section: { marginBottom: '24px' },
    sectionTitle: { fontSize: '0.95rem', color: 'var(--text-secondary)', marginBottom: '12px', fontWeight: '600' },
    priceInputs: { display: 'flex', alignItems: 'center', gap: '8px' },
    input: {
        flex: 1, padding: '10px 12px', border: '1px solid var(--border)', borderRadius: 'var(--radius-sm)',
        fontSize: '0.9rem', outline: 'none', fontFamily: 'inherit'
    },
    ratingButtons: { display: 'flex', flexDirection: 'column', gap: '8px' },
    ratingBtn: {
        textAlign: 'left', padding: '10px 14px', border: '1.5px solid', borderRadius: 'var(--radius-sm)',
        fontSize: '0.85rem', cursor: 'pointer', transition: 'all 0.2s', backgroundColor: 'transparent'
    },
    checkbox: { display: 'flex', alignItems: 'center', fontSize: '0.95rem', cursor: 'pointer' },
    clearBtn: {
        width: '100%', padding: '10px', backgroundColor: 'transparent', border: 'none',
        fontSize: '0.9rem', fontWeight: '700', cursor: 'pointer', marginTop: '8px'
    }
};

export default ProductFilter;
