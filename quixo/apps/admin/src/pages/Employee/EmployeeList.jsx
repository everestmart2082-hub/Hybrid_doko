import React from 'react';
import { Link } from 'react-router-dom';

const mockEmployees = [
  { id: 'EMP-001', name: 'Sarita Poudel', role: 'Support Agent', department: 'Customer Success', joined: 'Jan 15, 2025', status: 'Active' },
  { id: 'EMP-002', name: 'Rabin Shrestha', role: 'System Admin', department: 'IT', joined: 'Mar 10, 2025', status: 'Active' },
  { id: 'EMP-003', name: 'Alina Karki', role: 'Data Analyst', department: 'Operations', joined: 'Feb 05, 2026', status: 'On Leave' },
];

const EmployeeList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Internal Staff Directory</h1>
          <p className="text-secondary">Manage Doko internal employees and their system access roles.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <Link to="/employees/payroll">
            <button className="btn btn-outline">Payroll System</button>
          </Link>
          <Link to="/employees/add">
            <button className="btn btn-primary">+ Add Employee</button>
          </Link>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Employee ID</th>
              <th>Full Name</th>
              <th>System Role</th>
              <th>Department</th>
              <th>Date Joined</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockEmployees.map(emp => (
              <tr key={emp.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{emp.id}</td>
                <td style={{ fontWeight: '600' }}>{emp.name}</td>
                <td><span className="badge badge-info">{emp.role}</span></td>
                <td>{emp.department}</td>
                <td>{emp.joined}</td>
                <td>
                  <span className={`badge ${emp.status === 'Active' ? 'badge-success' : 'badge-warning'}`}>
                    {emp.status}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem' }}>Edit Access</button>
                    <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem', color: 'var(--danger)', borderColor: 'var(--danger)' }}>Revoke</button>
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

export default EmployeeList;
