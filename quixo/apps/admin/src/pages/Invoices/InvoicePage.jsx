import React from 'react';

const mockInvoices = [
  { id: 'INV-2026-661', type: 'Vendor Payout', entity: 'KTM Fresh', amount: 'NPR 85,000', date: 'Oct 28, 2026', status: 'Cleared' },
  { id: 'INV-2026-662', type: 'Rider Payout', entity: 'Ram Bahadur', amount: 'NPR 12,500', date: 'Oct 28, 2026', status: 'Cleared' },
  { id: 'INV-2026-663', type: 'Platform Fee', entity: 'Khalti Gateway', amount: 'NPR 4,500', date: 'Oct 29, 2026', status: 'Pending' },
  { id: 'INV-2026-664', type: 'Platform Fee', entity: 'eSewa', amount: 'NPR 2,100', date: 'Oct 29, 2026', status: 'Pending' },
];

const InvoicePage = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Invoices & Settlements</h1>
          <p className="text-secondary">View system-generated payouts, gateway fees, and financial settlements.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <select className="form-input" style={{ width: 'auto' }}>
            <option>All Invoices</option>
            <option>Payouts</option>
            <option>Platform Fees</option>
          </select>
          <button className="btn btn-outline">Export Records</button>
        </div>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: '20px', marginBottom: '30px' }}>
        <div className="card" style={{ padding: '20px', borderLeft: '4px solid var(--success)' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Total Cleared (This Month)</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>NPR 1.4M</div></div>
        <div className="card" style={{ padding: '20px', borderLeft: '4px solid var(--warning)' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Pending Settlements</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>NPR 245K</div></div>
        <div className="card" style={{ padding: '20px', borderLeft: '4px solid var(--danger)' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Gateway Fees</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>NPR 18,500</div></div>
        <div className="card" style={{ padding: '20px', borderLeft: '4px solid var(--info)' }}><div style={{ color: 'var(--text-secondary)', fontSize: '0.85rem' }}>Total Generated</div><div style={{ fontSize: '1.5rem', fontWeight: 'bold' }}>1,245</div></div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Invoice Number</th>
              <th>Transaction Type</th>
              <th>Entity / Gateway</th>
              <th>Total Amount</th>
              <th>Invoice Date</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockInvoices.map(inv => (
              <tr key={inv.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{inv.id}</td>
                <td><span className={`badge ${inv.type.includes('Fee') ? 'badge-danger' : 'badge-info'}`}>{inv.type}</span></td>
                <td style={{ fontWeight: '600' }}>{inv.entity}</td>
                <td style={{ fontWeight: '600' }}>{inv.amount}</td>
                <td>{inv.date}</td>
                <td>
                  <span className={`badge ${inv.status === 'Cleared' ? 'badge-success' : 'badge-warning'}`}>
                    {inv.status}
                  </span>
                </td>
                <td>
                  <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem' }}>View PDF</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default InvoicePage;
