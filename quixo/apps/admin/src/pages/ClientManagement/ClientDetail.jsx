import React from 'react';
import { useParams, Link } from 'react-router-dom';

const ClientDetail = () => {
  const { id } = useParams();

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px' }}>
        <Link to="/clients">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Client Pro le: {id || 'USR-8891'}</h1>
          <span className="badge badge-success">Active Customer</span>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: '1fr 2fr', gap: '30px' }}>
        <div className="card" style={{ alignSelf: 'start' }}>
          <h3 style={{ fontSize: '1.2rem', marginBottom: '20px', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Customer Info</h3>
          <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Full Name</span><strong>Binod Chaudhary</strong></div>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Email</span><strong>binod@gmail.com</strong></div>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Phone</span><strong>+977 9801234567</strong></div>
            <div><span style={{ color: 'var(--text-secondary)', display: 'block', fontSize: '0.85rem' }}>Registered On</span><strong>Oct 10, 2026</strong></div>
          </div>

          <Link to={`/clients/${id}/suspend`}>
            <button className="btn btn-danger" style={{ width: '100%', marginTop: '30px' }}>Manage Suspension</button>
          </Link>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(2, 1fr)', gap: '16px' }}>
            <div className="card" style={{ padding: '20px' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Lifetime Value</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>NPR 45,000</div></div>
            <div className="card" style={{ padding: '20px' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Total Orders</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>15</div></div>
          </div>

          <div className="card" style={{ flex: '1' }}>
            <h3 style={{ fontSize: '1.2rem', marginBottom: '20px' }}>Order History</h3>
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
                <tr><td>DOKO-C1</td><td>Oct 20, 2026</td><td>NPR 1,500</td><td><span className="badge badge-success">Delivered</span></td></tr>
                <tr><td>DOKO-C2</td><td>Oct 15, 2026</td><td>NPR 8,200</td><td><span className="badge badge-success">Delivered</span></td></tr>
                <tr><td>DOKO-C3</td><td>Oct 05, 2026</td><td>NPR 400</td><td><span className="badge badge-success">Delivered</span></td></tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  );
};

export default ClientDetail;
