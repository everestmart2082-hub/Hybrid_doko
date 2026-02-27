import React from 'react';

const mockOrders = [
  { id: 'DOKO-A1K9P-J29', customer: 'Binod Chaudhary', vendor: 'KTM Fresh', amount: 'NPR 2,450', type: 'Quick', status: 'Delivered', date: 'Just now' },
  { id: 'DOKO-B2L0Q-K31', customer: 'Sita Giri', vendor: 'SneakerHead Nepal', amount: 'NPR 15,000', type: '1Day', status: 'Pending', date: '30 mins ago' },
  { id: 'DOKO-C3M1R-L42', customer: 'Ram Thapa', vendor: 'Daily Milk Dairy', amount: 'NPR 500', type: 'Quick', status: 'Preparing', date: '1 hr ago' },
  { id: 'DOKO-D4N2S-M53', customer: 'Priya Joshi', vendor: 'TechGadgets', amount: 'NPR 45,000', type: '1Day', status: 'Cancelled', date: '2 hrs ago' }
];

const OrderList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Global Orders</h1>
          <p className="text-secondary">Monitor platform-wide order lifecycle in real-time.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <select className="form-input" style={{ width: 'auto' }}>
            <option>All Statuses</option>
            <option>Pending</option>
            <option>Preparing</option>
            <option>Delivered</option>
            <option>Cancelled</option>
          </select>
          <input type="text" className="form-input" placeholder="Search Order ID..." style={{ width: '250px' }} />
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Order Tracking ID</th>
              <th>Customer</th>
              <th>Vendor</th>
              <th>Type</th>
              <th>Total Amount</th>
              <th>Order Time</th>
              <th>Live Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockOrders.map(order => (
              <tr key={order.id}>
                <td style={{ fontWeight: '700', fontFamily: 'monospace', letterSpacing: '0.5px' }}>{order.id}</td>
                <td>{order.customer}</td>
                <td style={{ color: 'var(--primary-dark)', fontWeight: '500' }}>{order.vendor}</td>
                <td><span className="badge badge-neutral">{order.type}</span></td>
                <td style={{ fontWeight: '600' }}>{order.amount}</td>
                <td style={{ color: 'var(--text-secondary)' }}>{order.date}</td>
                <td>
                  <span className={`badge ${order.status === 'Delivered' ? 'badge-success' :
                      order.status === 'Cancelled' ? 'badge-danger' :
                        order.status === 'Pending' ? 'badge-warning' : 'badge-info'
                    }`}>
                    {order.status}
                  </span>
                </td>
                <td>
                  <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Trace</button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default OrderList;
