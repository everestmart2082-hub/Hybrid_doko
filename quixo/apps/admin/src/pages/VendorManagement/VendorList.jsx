import React from 'react';
import { Link } from 'react-router-dom';

const mockVendors = [
  { id: 'VND-ACTIVE-01', store: 'KTM Fresh Groceries', category: 'Grocery', joined: 'Oct 01, 2026', status: 'Active', revenue: 'NPR 120,500' },
  { id: 'VND-ACTIVE-02', store: 'SneakerHead Nepal', category: 'Ecommerce', joined: 'Oct 15, 2026', status: 'Active', revenue: 'NPR 85,000' },
  { id: 'VND-SUSPEND-01', store: 'Daily Milk Dairy', category: 'Grocery', joined: 'Sep 20, 2026', status: 'Suspended', revenue: 'NPR 5,000' }
];

const VendorList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Vendor Directory</h1>
          <p className="text-secondary">Manage and monitor all onboarded vendors on the platform.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <input type="text" className="form-input" placeholder="Search vendors..." style={{ width: '250px' }} />
          <button className="btn btn-primary">Export CSV</button>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Vendor ID</th>
              <th>Store Name</th>
              <th>Category</th>
              <th>Joined Date</th>
              <th>Gross Revenue</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockVendors.map(vendor => (
              <tr key={vendor.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{vendor.id}</td>
                <td style={{ fontWeight: '600' }}>{vendor.store}</td>
                <td><span className="badge badge-neutral">{vendor.category}</span></td>
                <td>{vendor.joined}</td>
                <td style={{ fontWeight: '600', color: 'var(--success)' }}>{vendor.revenue}</td>
                <td>
                  <span className={`badge ${vendor.status === 'Active' ? 'badge-success' : 'badge-danger'}`}>
                    {vendor.status}
                  </span>
                </td>
                <td>
                  <Link to={`/vendors/${vendor.id}`}>
                    <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>View Profile</button>
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

export default VendorList;
