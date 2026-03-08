import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import axios from 'axios';

const API_BASE = '/api';
const getToken = () => localStorage.getItem('admin_token');

const EmployeeList = () => {
  const [employees, setEmployees] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // No dedicated "get all employees" endpoint in spec — would need to add one
    // For now we'll show any data we can retrieve
    setLoading(false);
  }, []);

  const handleDelete = async (id) => {
    if (!window.confirm('Are you sure you want to delete this employee?')) return;
    try {
      await axios.delete(`${API_BASE}/admin/employee/delete`, { data: { token: getToken(), 'employee id': id } });
      setEmployees(prev => prev.filter(e => e._id !== id));
    } catch (e) { alert('Delete failed'); }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Internal Staff Directory</h1>
          <p className="text-secondary">Manage Doko internal employees. ({employees.length} total)</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <Link to="/employees/payroll"><button className="btn btn-outline">Payroll System</button></Link>
          <Link to="/employees/add"><button className="btn btn-primary">+ Add Employee</button></Link>
        </div>
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Name</th><th>Position</th><th>Phone</th><th>Email</th><th>Salary</th><th>Actions</th></tr></thead>
            <tbody>
              {employees.length === 0 ? (
                <tr><td colSpan="6" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No employees added yet. Use the "+ Add Employee" button above.
                </td></tr>
              ) : employees.map(emp => (
                <tr key={emp._id}>
                  <td style={{ fontWeight: '600' }}>{emp.name}</td>
                  <td><span className="badge badge-info">{emp.position || '—'}</span></td>
                  <td>{emp.phone}</td>
                  <td>{emp.email || '—'}</td>
                  <td style={{ fontWeight: '600' }}>NPR {emp.salary?.toLocaleString() || '—'}</td>
                  <td>
                    <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem', color: 'var(--danger)', borderColor: 'var(--danger)' }} onClick={() => handleDelete(emp._id)}>Remove</button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default EmployeeList;
