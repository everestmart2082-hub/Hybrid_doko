import React from 'react';
import { Link } from 'react-router-dom';

const mockClients = [
  { id: 'USR-8891', name: 'Binod Chaudhary', email: 'binod@gmail.com', orders: 15, value: 'NPR 45,000', status: 'Active' },
  { id: 'USR-8892', name: 'Sita Giri', email: 'sita.g@outlook.com', orders: 2, value: 'NPR 1,200', status: 'Active' },
  { id: 'USR-8893', name: 'Nabin Shrestha', email: 'nabin@yahoo.com', orders: 0, value: 'NPR 0', status: 'Suspended' },
];

const ClientList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Client Database</h1>
          <p className="text-secondary">View registered users and monitor customer lifetime value.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <input type="text" className="form-input" placeholder="Search email or phone..." style={{ width: '300px' }} />
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Client ID</th>
              <th>Full Name</th>
              <th>Email Address</th>
              <th>Total Orders</th>
              <th>Lifetime Value</th>
              <th>Account Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockClients.map(client => (
              <tr key={client.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{client.id}</td>
                <td style={{ fontWeight: '600' }}>{client.name}</td>
                <td>{client.email}</td>
                <td style={{ fontWeight: '600' }}>{client.orders}</td>
                <td style={{ color: 'var(--success)', fontWeight: '600' }}>{client.value}</td>
                <td>
                  <span className={`badge ${client.status === 'Active' ? 'badge-success' : 'badge-danger'}`}>
                    {client.status}
                  </span>
                </td>
                <td>
                  <Link to={`/clients/${client.id}`}>
                    <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Details</button>
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default ClientList;
