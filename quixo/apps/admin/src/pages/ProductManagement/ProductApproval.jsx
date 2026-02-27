import React from 'react';

const mockProductApprovals = [
  { id: 'PRD-882', name: 'Organic Honey 500g', vendor: 'FreshMarts', price: 'NPR 450', stock: 100, issue: 'Requires image update' },
  { id: 'PRD-883', name: 'Smartphone XYZ', vendor: 'TechGadgets', price: 'NPR 25,000', stock: 10, issue: 'Price check needed' },
  { id: 'PRD-884', name: 'Whole Wheat Bread', vendor: 'Daily Needs', price: 'NPR 60', stock: 50, issue: 'New Listing' },
];

const ProductApproval = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Product Approvals</h1>
          <p className="text-secondary">Review queued products before they go live on Doko.</p>
        </div>
        <button className="btn btn-outline">Bulk Approve Selected</button>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th style={{ width: '40px' }}><input type="checkbox" /></th>
              <th>Product Code</th>
              <th>Product Name</th>
              <th>Vendor (Store)</th>
              <th>Price</th>
              <th>Stock Listed</th>
              <th>Flags / Issues</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockProductApprovals.map(req => (
              <tr key={req.id}>
                <td><input type="checkbox" /></td>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{req.id}</td>
                <td style={{ fontWeight: '600' }}>{req.name}</td>
                <td style={{ color: 'var(--info)' }}>{req.vendor}</td>
                <td>{req.price}</td>
                <td>{req.stock} units</td>
                <td>
                  {req.issue === 'New Listing'
                    ? <span className="badge badge-success">Clean</span>
                    : <span className="badge badge-warning">{req.issue}</span>}
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>✓</button>
                    <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>✕</button>
                    <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>View</button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default ProductApproval;
