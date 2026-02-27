import React, { useState } from 'react';
import { useParams, Link, useNavigate } from 'react-router-dom';

const SuspendCustomer = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [reason, setReason] = useState('');

  const handleSuspend = (e) => {
    e.preventDefault();
    console.log(`Suspending client ${id} for: ${reason}`);
    navigate('/clients');
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '600px', margin: '0 auto' }}>

      <div style={{ marginBottom: '30px' }}>
        <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Suspend Client Action</h1>
        <p className="text-secondary">You are about to suspend client {id || 'USR-8891'}.</p>
      </div>

      <div className="card" style={{ borderTop: '4px solid var(--danger)' }}>
        <p style={{ marginBottom: '20px', fontSize: '0.95rem', lineHeight: '1.5' }}>
          Suspending a customer account will immediately log them out, invalidate their active sessions, and prevent them from placing new orders or accessing their profile. This action is reversible.
        </p>

        <form onSubmit={handleSuspend}>
          <div className="form-group" style={{ marginBottom: '24px' }}>
            <label className="form-label">Reason for Suspension (Visible to user)</label>
            <textarea
              className="form-input"
              rows="4"
              required
              placeholder="e.g., Suspicious activity detected, violation of terms of service..."
              value={reason}
              onChange={(e) => setReason(e.target.value)}
            ></textarea>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end' }}>
            <Link to={`/clients/${id}`}>
              <button type="button" className="btn btn-outline" style={{ padding: '12px 24px' }}>Cancel</button>
            </Link>
            <button type="submit" className="btn btn-danger" style={{ padding: '12px 24px' }}>Con rm Suspension</button>
          </div>
        </form>
      </div>

    </div>
  );
};

export default SuspendCustomer;
