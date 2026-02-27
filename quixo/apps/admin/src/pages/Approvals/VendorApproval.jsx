import React from 'react';

const mockApprovals = [
  { id: 'VND-001', storeName: 'FreshMarts', owner: 'Rahul Sharma', date: 'Oct 24, 2026', type: 'Grocery', status: 'Pending' },
  { id: 'VND-002', storeName: 'TechGadgets', owner: 'Priya Patel', date: 'Oct 23, 2026', type: 'Electronics', status: 'Pending' },
  { id: 'VND-003', storeName: 'Daily Needs', owner: 'Amit Singh', date: 'Oct 24, 2026', type: 'Grocery', status: 'Pending' }
];

const VendorApproval = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Vendor Approvals</h1>
          <p className="text-secondary">Review and approve new vendor registrations.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <input type="text" className="form-input" placeholder="Search by name..." style={{ width: '250px' }} />
          <select className="form-input" style={{ width: 'auto' }}>
            <option>All Types</option>
            <option>Grocery</option>
            <option>Electronics</option>
          </select>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Vendor ID</th>
              <th>Store Name</th>
              <th>Owner Name</th>
              <th>Business Type</th>
              <th>Applied Date</th>
              <th>Documents</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockApprovals.map(req => (
              <tr key={req.id}>
                <td style={{ fontWeight: '600' }}>{req.id}</td>
                <td style={{ color: 'var(--primary-dark)', fontWeight: '600' }}>{req.storeName}</td>
                <td>{req.owner}</td>
                <td><span className="badge badge-neutral">{req.type}</span></td>
                <td>{req.date}</td>
                <td>
                  <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem' }}>View PAN & Reg.</button>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Approve</button>
                    <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Reject</button>
                  </div>
                </td>
              </tr>
            ))}
            {mockApprovals.length === 0 && (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No pending approvals at this time.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default VendorApproval;
