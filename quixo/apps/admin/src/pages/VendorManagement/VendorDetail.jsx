import React from 'react';
import { useParams, Link } from 'react-router-dom';

const VendorDetail = () => {
  const { id } = useParams();

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px' }}>
        <Link to="/vendors">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Vendor Pro le: {id || 'VND-001'}</h1>
          <span className="badge badge-success">Active Vendor</span>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '30px' }}>

        {/* Left Column: Details */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div className="card">
            <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Business Info</h3>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Store Name</span><strong>KTM Fresh Groceries</strong></div>
              <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Owner Name</span><strong>Rahul Sharma</strong></div>
              <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Category</span><strong>Grocery / Quick Commerce</strong></div>
              <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Phone</span><strong>+977 9800000000</strong></div>
              <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Address</span><strong>Kupondole, Lalitpur</strong></div>
            </div>
            <button className="btn btn-outline" style={{ marginTop: '24px', width: '100%' }}>View Documents</button>
          </div>

          <div className="card">
            <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px', color: 'var(--danger)' }}>Danger Zone</h3>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '16px' }}>Suspending a vendor will hide all their active products and stop incoming orders.</p>
            <button className="btn btn-danger" style={{ width: '100%' }}>Suspend Vendor</button>
          </div>
        </div>

        {/* Right Column: Analytics & Products */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '16px' }}>
            <div className="card" style={{ padding: '20px' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Total Sales</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>NPR 120,500</div></div>
            <div className="card" style={{ padding: '20px' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Total Orders</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>842</div></div>
            <div className="card" style={{ padding: '20px' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Active Products</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>145 items</div></div>
          </div>

          <div className="card" style={{ flex: '1' }}>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '20px' }}>Recent Orders</h3>
            <table className="data-table">
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Date</th>
                  <th>Amount</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr><td>DOKO-X1</td><td>Today</td><td>NPR 1,200</td><td><span className="badge badge-success">Delivered</span></td></tr>
                <tr><td>DOKO-X2</td><td>Yesterday</td><td>NPR 450</td><td><span className="badge badge-success">Delivered</span></td></tr>
                <tr><td>DOKO-X3</td><td>Yesterday</td><td>NPR 2,100</td><td><span className="badge badge-danger">Cancelled</span></td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>

    </div>
  );
};

export default VendorDetail;
