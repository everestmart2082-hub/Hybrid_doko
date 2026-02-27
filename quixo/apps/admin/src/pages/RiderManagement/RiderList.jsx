import React from 'react';
import { Link } from 'react-router-dom';

const mockRiders = [
  { id: 'RDR-ACT-01', name: 'Ram Bahadur', area: 'Kathmandu Central', deliveries: 124, rating: 4.8, status: 'Online' },
  { id: 'RDR-ACT-02', name: 'Shyam Karki', area: 'Lalitpur', deliveries: 89, rating: 4.5, status: 'Offline' },
  { id: 'RDR-ACT-03', name: 'Hari Bista', area: 'Bhaktapur', deliveries: 210, rating: 4.9, status: 'On Delivery' }
];

const RiderList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Rider Fleet Management</h1>
          <p className="text-secondary">Track rider status, performance, and assignments.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <select className="form-input" style={{ width: 'auto' }}>
            <option>All Zones</option>
            <option>Kathmandu</option>
            <option>Lalitpur</option>
          </select>
          <input type="text" className="form-input" placeholder="Search riders..." style={{ width: '250px' }} />
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Rider ID</th>
              <th>Full Name</th>
              <th>Operating Zone</th>
              <th>Total Deliveries</th>
              <th>Rating</th>
              <th>Current Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockRiders.map(rider => (
              <tr key={rider.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{rider.id}</td>
                <td style={{ fontWeight: '600' }}>{rider.name}</td>
                <td>{rider.area}</td>
                <td style={{ fontWeight: '600' }}>{rider.deliveries}</td>
                <td style={{ color: 'var(--warning)', fontWeight: 'bold' }}>{rider.rating} ⭐</td>
                <td>
                  <span className={`badge ${rider.status === 'Online' ? 'badge-info' : rider.status === 'On Delivery' ? 'badge-success' : 'badge-neutral'}`}>
                    {rider.status}
                  </span>
                </td>
                <td>
                  <Link to={`/riders/${rider.id}`}>
                    <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Track</button>
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

export default RiderList;
