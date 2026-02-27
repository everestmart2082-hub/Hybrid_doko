import React from 'react';

const mockInvoices = [
  { id: 'INV-441-A', date: 'Oct 28, 2026', totalOrders: 145, grossSales: 'NPR 145,000', platformFee: 'NPR 14,500', netPayout: 'NPR 130,500', status: 'Paid' },
  { id: 'INV-440-B', date: 'Oct 21, 2026', totalOrders: 132, grossSales: 'NPR 128,400', platformFee: 'NPR 12,840', netPayout: 'NPR 115,560', status: 'Paid' },
  { id: 'INV-439-C', date: 'Oct 14, 2026', totalOrders: 156, grossSales: 'NPR 162,000', platformFee: 'NPR 16,200', netPayout: 'NPR 145,800', status: 'Paid' },
  { id: 'INV-438-D', date: 'Oct 07, 2026', totalOrders: 110, grossSales: 'NPR 105,500', platformFee: 'NPR 10,550', netPayout: 'NPR 94,950', status: 'Failed' },
];

const InvoicePage = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Weekly Payouts & Invoices</h1>
          <p className="text-secondary">View your store's earning settlements and download tax invoices.</p>
        </div>
        <button className="btn btn-outline" style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <span>📥</span> Download YTD Summary
        </button>
      </div>

      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '24px', marginBottom: '30px' }}>
        <div className="card" style={{ padding: '24px', borderLeft: '4px solid var(--primary)' }}>
          <div style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '600', marginBottom: '8px' }}>Pending Payout (This Week)</div>
          <div style={{ fontSize: '1.8rem', fontWeight: '800', color: 'var(--text-primary)' }}>NPR 45,200</div>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '8px' }}>Expected settlement on Nov 04, 2026</p>
        </div>
        <div className="card" style={{ padding: '24px', borderLeft: '4px solid var(--success)' }}>
          <div style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', fontWeight: '600', marginBottom: '8px' }}>Total Earned (Oct 2026)</div>
          <div style={{ fontSize: '1.8rem', fontWeight: '800', color: 'var(--text-primary)' }}>NPR 486,810</div>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '8px' }}>Net of 10% Doko Platform Fees</p>
        </div>
        <div className="card" style={{ padding: '24px', backgroundColor: 'var(--bg-color)', display: 'flex', flexDirection: 'column', justifyContent: 'center' }}>
          <p style={{ fontWeight: '600', marginBottom: '4px' }}>Bank Account Setup</p>
          <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '12px' }}>NIC Asia Bank (End in 4512)</p>
          <button className="btn btn-outline" style={{ fontSize: '0.8rem', padding: '6px 12px', alignSelf: 'flex-start' }}>Update Details</button>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Invoice Number</th>
              <th>Settlement Date</th>
              <th>Total Orders</th>
              <th>Gross Sales</th>
              <th>Platform Fee (10%)</th>
              <th>Net Payout</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {mockInvoices.map(inv => (
              <tr key={inv.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{inv.id}</td>
                <td>{inv.date}</td>
                <td>{inv.totalOrders}</td>
                <td>{inv.grossSales}</td>
                <td style={{ color: 'var(--danger)' }}>-{inv.platformFee}</td>
                <td style={{ fontWeight: '600', color: 'var(--success)' }}>{inv.netPayout}</td>
                <td>
                  <span className={`badge ${inv.status === 'Paid' ? 'badge-success' : 'badge-danger'}`}>
                    {inv.status}
                  </span>
                </td>
                <td>
                  <button className="btn btn-outline" style={{ padding: '4px 12px', fontSize: '0.8rem' }}>View PDF</button>
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
