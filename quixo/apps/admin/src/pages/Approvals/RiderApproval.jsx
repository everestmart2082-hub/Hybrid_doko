import React from 'react';

const mockRiderApprovals = [
  { id: 'RDR-204', name: 'Sunil Thapa', phone: '+977 9812345670', vehicle: 'Bike (BA 41 PA 1024)', status: 'Pending Verification' },
  { id: 'RDR-205', name: 'Krishna Gurung', phone: '+977 9812345671', vehicle: 'Scooter (BA 35 PA 400)', status: 'Pending Verification' }
];

const RiderApproval = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Rider Approvals</h1>
          <p className="text-secondary">Verify rider documents and vehicle registration before activation.</p>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Applicant ID</th>
              <th>Full Name</th>
              <th>Contact Phone</th>
              <th>Vehicle Details</th>
              <th>Required Documents</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockRiderApprovals.map(req => (
              <tr key={req.id}>
                <td style={{ fontWeight: '600' }}>{req.id}</td>
                <td style={{ fontWeight: '600', color: 'var(--primary-dark)' }}>{req.name}</td>
                <td>{req.phone}</td>
                <td>{req.vehicle}</td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <span className="badge badge-info" style={{ cursor: 'pointer' }}>License</span>
                    <span className="badge badge-info" style={{ cursor: 'pointer' }}>Bluebook</span>
                  </div>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-success" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Approve</button>
                    <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Reject</button>
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

export default RiderApproval;
