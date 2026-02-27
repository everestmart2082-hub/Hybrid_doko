import React from 'react';

const AnalyticsPage = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Store Analytics</h1>
          <p className="text-secondary">Analyze your sales performance and top selling items.</p>
        </div>
        <select className="form-input" style={{ width: '200px' }}>
          <option>Last 7 Days</option>
          <option>Last 30 Days</option>
          <option>This Year</option>
        </select>
      </div>

      {/* Main Charts Mockup */}
      <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: '24px', marginBottom: '24px' }}>

        <div className="card" style={{ height: '400px', display: 'flex', flexDirection: 'column' }}>
          <h3 style={{ fontSize: '1.2rem', marginBottom: '24px' }}>Revenue Trend (Past 7 Days)</h3>

          <div style={{ flex: 1, display: 'flex', alignItems: 'flex-end', gap: '8%', padding: '20px 0', borderBottom: '1px solid var(--border)', borderLeft: '1px solid var(--border)', position: 'relative' }}>
            <div style={{ position: 'absolute', top: 0, left: '-40px', color: 'var(--text-secondary)', fontSize: '0.8rem' }}>40k</div>
            <div style={{ position: 'absolute', top: '50%', left: '-40px', color: 'var(--text-secondary)', fontSize: '0.8rem' }}>20k</div>
            <div style={{ position: 'absolute', bottom: 0, left: '-30px', color: 'var(--text-secondary)', fontSize: '0.8rem' }}>0</div>

            <div style={{ width: '100%', height: '40%', backgroundColor: 'var(--primary-light)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
            <div style={{ width: '100%', height: '60%', backgroundColor: 'var(--primary-light)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
            <div style={{ width: '100%', height: '80%', backgroundColor: 'var(--primary-light)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
            <div style={{ width: '100%', height: '50%', backgroundColor: 'var(--primary-light)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
            <div style={{ width: '100%', height: '90%', backgroundColor: 'var(--primary-light)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
            <div style={{ width: '100%', height: '100%', backgroundColor: 'var(--primary)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
            <div style={{ width: '100%', height: '70%', backgroundColor: 'var(--primary-light)', borderRadius: '4px 4px 0 0', margin: '0 10px' }}></div>
          </div>
          <div style={{ display: 'flex', justifyContent: 'space-between', padding: '10px 10px 0 10px', color: 'var(--text-secondary)', fontSize: '0.85rem' }}>
            <span>Mon</span>
            <span>Tue</span>
            <span>Wed</span>
            <span>Thu</span>
            <span>Fri</span>
            <span>Sat</span>
            <span>Sun</span>
          </div>
        </div>

        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '24px' }}>Top Selling Products</h3>
          <ul style={{ listStyle: 'none', padding: 0, display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <li style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '16px', borderBottom: '1px solid var(--border)' }}>
              <div>
                <span style={{ fontWeight: '600', display: 'block' }}>Fresh Organic Tomatoes</span>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Vegetables</span>
              </div>
              <div style={{ textAlign: 'right' }}>
                <span style={{ fontWeight: '600', display: 'block' }}>145 kg</span>
                <span style={{ color: 'var(--primary)', fontSize: '0.85rem' }}>NPR 17,400</span>
              </div>
            </li>
            <li style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', paddingBottom: '16px', borderBottom: '1px solid var(--border)' }}>
              <div>
                <span style={{ fontWeight: '600', display: 'block' }}>Onions (Local)</span>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Vegetables</span>
              </div>
              <div style={{ textAlign: 'right' }}>
                <span style={{ fontWeight: '600', display: 'block' }}>112 kg</span>
                <span style={{ color: 'var(--primary)', fontSize: '0.85rem' }}>NPR 8,960</span>
              </div>
            </li>
            <li style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <div>
                <span style={{ fontWeight: '600', display: 'block' }}>Amul Butter 500g</span>
                <span style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Dairy</span>
              </div>
              <div style={{ textAlign: 'right' }}>
                <span style={{ fontWeight: '600', display: 'block' }}>89 units</span>
                <span style={{ color: 'var(--primary)', fontSize: '0.85rem' }}>NPR 40,050</span>
              </div>
            </li>
          </ul>
        </div>

      </div>

    </div>
  );
};

export default AnalyticsPage;
