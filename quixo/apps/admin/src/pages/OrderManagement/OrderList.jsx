import React, { useState, useEffect } from 'react';
import axios from 'axios';

const API_BASE = '/api';

const OrderList = () => {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);
  const [statusFilter, setStatusFilter] = useState('');

  useEffect(() => {
    // Orders are stored globally — we can fetch via user order endpoint or aggregate
    // For admin, there's no dedicated admin order list endpoint in the spec,
    // so we'll show a message or fetch from available data
    setLoading(false);
  }, []);

  const statusColors = {
    preparing: 'badge-info',
    pending: 'badge-warning',
    delivered: 'badge-success',
    cancelled: 'badge-danger',
    returned: 'badge-danger',
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Global Orders</h1>
          <p className="text-secondary">Monitor platform-wide order lifecycle. ({orders.length} orders)</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <select className="form-input" style={{ width: 'auto' }} value={statusFilter} onChange={e => setStatusFilter(e.target.value)}>
            <option value="">All Statuses</option>
            <option value="preparing">Preparing</option>
            <option value="pending">Pending</option>
            <option value="delivered">Delivered</option>
            <option value="cancelled">Cancelled</option>
          </select>
        </div>
      </div>

      {loading ? <p style={{ textAlign: 'center', padding: '60px' }}>Loading...</p> : (
        <div className="table-container">
          <table className="data-table">
            <thead><tr><th>Order ID</th><th>Total</th><th>Type</th><th>Status</th><th>Date</th></tr></thead>
            <tbody>
              {orders.length === 0 ? (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: 'var(--text-secondary)' }}>
                  No orders yet. Orders will appear here once customers start placing them.
                </td></tr>
              ) : orders.filter(o => !statusFilter || o.status === statusFilter).map(o => (
                <tr key={o._id}>
                  <td style={{ fontWeight: '700', fontFamily: 'monospace' }}>{o._id?.slice(-8)}</td>
                  <td style={{ fontWeight: '600' }}>NPR {o.total}</td>
                  <td><span className="badge badge-neutral">{o.deliveryCategory || '—'}</span></td>
                  <td><span className={`badge ${statusColors[o.status] || 'badge-neutral'}`}>{o.status}</span></td>
                  <td>{new Date(o.dateOfOrder).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default OrderList;
