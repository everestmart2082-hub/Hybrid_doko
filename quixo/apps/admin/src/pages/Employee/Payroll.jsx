import React from 'react';
import { Link } from 'react-router-dom';

const mockPayroll = [
  { id: 'PR-26-Oct-01', name: 'Sarita Poudel', role: 'Support Agent', base: 'NPR 35,000', bonus: 'NPR 5,000', total: 'NPR 40,000', status: 'Paid', date: 'Oct 28, 2026' },
  { id: 'PR-26-Oct-02', name: 'Rabin Shrestha', role: 'System Admin', base: 'NPR 65,000', bonus: '-', total: 'NPR 65,000', status: 'Pending', date: '-' },
];

const Payroll = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px', alignItems: 'center' }}>
        <Link to="/employees">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div style={{ flex: 1 }}>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Staff Payroll System</h1>
          <p className="text-secondary">Process and review monthly employee compensation.</p>
        </div>
        <button className="btn btn-success">Run October Payroll</button>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Payroll Ref</th>
              <th>Employee Name</th>
              <th>Role Base Salary</th>
              <th>Allowances / Bonus</th>
              <th>Total Disbursed</th>
              <th>Payment Status</th>
              <th>Date Paid</th>
            </tr>
          </thead>
          <tbody>
            {mockPayroll.map(pr => (
              <tr key={pr.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{pr.id}</td>
                <td style={{ fontWeight: '600' }}>{pr.name}</td>
                <td>{pr.base}</td>
                <td>{pr.bonus}</td>
                <td style={{ fontWeight: '600', color: 'var(--primary-dark)' }}>{pr.total}</td>
                <td>
                  <span className={`badge ${pr.status === 'Paid' ? 'badge-success' : 'badge-warning'}`}>
                    {pr.status}
                  </span>
                </td>
                <td>{pr.date}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default Payroll;
