import React from 'react';
import { useParams, Link } from 'react-router-dom';

const RiderDetail = () => {
  const { id } = useParams();

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px' }}>
        <Link to="/riders">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Rider Pro le: {id || 'RDR-ACT-01'}</h1>
          <span className="badge badge-info">Online (Kathmandu Zone)</span>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '30px' }}>
        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Rider Information</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Full Name</span><strong>Ram Bahadur</strong></div>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Vehicle</span><strong>Bike - BA 41 PA 1024</strong></div>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Rating</span><strong style={{ color: 'var(--warning)' }}>4.8 ⭐ (120 reviews)</strong></div>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Total Deliveries</span><strong>842</strong></div>
          </div>

          <div style={{ display: 'flex', gap: '12px', marginTop: '30px' }}>
            <button className="btn btn-primary" style={{ flex: 1 }}>Message Rider</button>
            <button className="btn btn-danger" style={{ flex: 1 }}>Suspend Rider</button>
          </div>
        </div>

        <div className="card">
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Recent Deliveries</h3>
          <table className="data-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Date</th>
                <th>Earning</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>DOKO-R1</td><td>Today 14:30</td><td>NPR 150</td></tr>
              <tr><td>DOKO-R2</td><td>Today 12:15</td><td>NPR 120</td></tr>
              <tr><td>DOKO-R3</td><td>Yesterday</td><td>NPR 80</td></tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
};

export default RiderDetail;
