import React from 'react';
import { Link } from 'react-router-dom';

const mockOrders = [
  { id: 'ORD-91A', customer: 'Ramesh Thapa', items: 3, total: 'NPR 1,250', time: '10 mins ago', status: 'Pending' },
  { id: 'ORD-92B', customer: 'Sita Sharma', items: 8, total: 'NPR 4,500', time: '45 mins ago', status: 'Preparing' },
  { id: 'ORD-93C', customer: 'Hari Bahadur', items: 1, total: 'NPR 250', time: '1.5 hrs ago', status: 'Ready for Pickup' },
  { id: 'ORD-94D', customer: 'Gita Karki', items: 5, total: 'NPR 2,800', time: '2 hrs ago', status: 'Completed' },
  { id: 'ORD-95E', customer: 'Bikash Rai', items: 2, total: 'NPR 850', time: '3 hrs ago', status: 'Cancelled' },
];

const OrderList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Store Orders</h1>
          <p className="text-secondary">Process live incoming orders and manage historical data.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <button className="btn btn-outline">Export CSV</button>
        </div>
      </div>

      <div className="card" style={{ marginBottom: '24px', padding: '16px 24px', display: 'flex', gap: '16px' }}>
        <input type="text" className="form-input" placeholder="Search Order ID or Customer Name..." style={{ flex: 1 }} />
        <input type="date" className="form-input" style={{ width: '200px' }} />
        <select className="form-input" style={{ width: '200px' }}>
          <option value="">All Statuses</option>
          <option value="pending">Pending</option>
          <option value="preparing">Preparing</option>
          <option value="ready">Ready for Pickup</option>
          <option value="completed">Completed</option>
          <option value="cancelled">Cancelled</option>
        </select>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Order ID</th>
              <th>Time Received</th>
              <th>Customer</th>
              <th>Items</th>
              <th>Total Amount</th>
              <th>Status</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {mockOrders.map(order => (
              <tr key={order.id}>
                <td style={{ fontWeight: '600' }}>{order.id}</td>
                <td>{order.time}</td>
                <td>{order.customer}</td>
                <td>{order.items} items</td>
                <td style={{ fontWeight: '600' }}>{order.total}</td>
                <td>
                  <span className={`badge ${order.status === 'Pending' ? 'badge-danger' :
                      order.status === 'Preparing' ? 'badge-warning' :
                        order.status === 'Ready for Pickup' ? 'badge-info' :
                          order.status === 'Completed' ? 'badge-success' : 'badge-neutral'
                    }`}>
                    {order.status}
                  </span>
                </td>
                <td>
                  <Link to={`/orders/${order.id}`}>
                    <button className="btn btn-outline" style={{ padding: '6px 16px', fontSize: '0.85rem' }}>View Details</button>
                  </Link>
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
