import React, { useState } from 'react';

const mockEarnings = [
  { id: 'TRX-101', date: 'Today, 2:30 PM', description: 'Order ORD-11A Delivery', amount: '+ NPR 120', type: 'credit' },
  { id: 'TRX-102', date: 'Today, 1:15 PM', description: 'Order ORD-09B Delivery', amount: '+ NPR 150', type: 'credit' },
  { id: 'TRX-103', date: 'Yesterday', description: 'Weekly Bonus', amount: '+ NPR 500', type: 'credit' },
  { id: 'TRX-104', date: 'Oct 24, 2026', description: 'Payout to Bank', amount: '- NPR 4,500', type: 'debit' },
];

const EarningsPage = () => {
  const [filter, setFilter] = useState('weekly');

  return (
    <div className="view-container animate-fade-in">

      <div style={{ backgroundColor: 'var(--primary)', backgroundImage: 'linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%)', color: 'white', padding: '30px 20px', paddingBottom: '50px' }}>
        <h1 style={{ fontSize: '1.5rem', margin: 0, marginBottom: '20px' }}>Earnings</h1>

        <div style={{ display: 'flex', gap: '10px', marginBottom: '30px', overflowX: 'auto', paddingBottom: '10px' }}>
          <button onClick={() => setFilter('daily')} style={{ ...styles.filterBtn, ...(filter === 'daily' ? styles.filterBtnActive : {}) }}>Today</button>
          <button onClick={() => setFilter('weekly')} style={{ ...styles.filterBtn, ...(filter === 'weekly' ? styles.filterBtnActive : {}) }}>This Week</button>
          <button onClick={() => setFilter('monthly')} style={{ ...styles.filterBtn, ...(filter === 'monthly' ? styles.filterBtnActive : {}) }}>This Month</button>
        </div>

        <div style={{ textAlign: 'center' }}>
          <p style={{ margin: 0, opacity: 0.9, fontSize: '0.9rem' }}>Net Earnings (This Week)</p>
          <div style={{ fontSize: '3rem', fontWeight: '800', margin: '4px 0' }}>NPR 4,250</div>
          <div className="badge" style={{ backgroundColor: 'rgba(255,255,255,0.2)', color: 'white' }}>↑ 15% vs Last Week</div>
        </div>
      </div>

      <div className="container" style={{ marginTop: '-30px' }}>

        <div className="card" style={{ marginBottom: '24px', display: 'flex', justifyContent: 'space-around', padding: '20px 10px' }}>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.2rem', fontWeight: '800', color: 'var(--text-primary)' }}>34</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Deliveries</div>
          </div>
          <div style={{ width: '1px', backgroundColor: 'var(--border)' }}></div>
          <div style={{ textAlign: 'center' }}>
            <div style={{ fontSize: '1.2rem', fontWeight: '800', color: 'var(--text-primary)' }}>28h</div>
            <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)' }}>Online Time</div>
          </div>
        </div>

        <h3 style={{ fontSize: '1.1rem', marginBottom: '16px', marginLeft: '8px' }}>Recent Transactions</h3>

        <div className="card" style={{ padding: 0, overflow: 'hidden' }}>
          <div style={{ display: 'flex', flexDirection: 'column' }}>
            {mockEarnings.map((trx, i) => (
              <div key={trx.id} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '16px', borderBottom: i === mockEarnings.length - 1 ? 'none' : '1px solid var(--border)' }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                  <div style={{ width: '40px', height: '40px', borderRadius: '50%', backgroundColor: trx.type === 'credit' ? '#dcfce7' : '#f1f5f9', display: 'flex', alignItems: 'center', justifyContent: 'center', color: trx.type === 'credit' ? 'var(--success)' : 'var(--text-secondary)' }}>
                    {trx.type === 'credit' ? '📈' : '🏦'}
                  </div>
                  <div>
                    <h4 style={{ margin: 0, fontSize: '0.95rem' }}>{trx.description}</h4>
                    <p style={{ margin: 0, fontSize: '0.75rem', color: 'var(--text-secondary)' }}>{trx.date}</p>
                  </div>
                </div>
                <div style={{ fontWeight: '800', color: trx.type === 'credit' ? 'var(--success)' : 'var(--text-primary)' }}>
                  {trx.amount}
                </div>
              </div>
            ))}
          </div>
        </div>

        <div style={{ textAlign: 'center', marginTop: '20px' }}>
          <button className="btn btn-primary" style={{ width: '100%', maxWidth: '300px' }}>Request Payout</button>
        </div>

      </div>
    </div>
  );
};

const styles = {
  filterBtn: {
    backgroundColor: 'rgba(255,255,255,0.2)',
    color: 'white',
    border: 'none',
    padding: '8px 16px',
    borderRadius: '100px',
    fontSize: '0.85rem',
    fontWeight: '600',
    cursor: 'pointer',
    whiteSpace: 'nowrap'
  },
  filterBtnActive: {
    backgroundColor: 'white',
    color: 'var(--primary)',
  }
};

export default EarningsPage;
