import React, { useState } from 'react';

const mockInventory = [
  { id: 'ITM-001', name: 'Fresh Organic Tomatoes', category: 'Vegetables', currentStock: 45, alertThreshold: 10, status: 'Healthy' },
  { id: 'ITM-002', name: 'Wai Wai Noodles (Chicken)', category: 'Packaged Food', currentStock: 200, alertThreshold: 50, status: 'Healthy' },
  { id: 'ITM-003', name: 'Amul Butter 500g', category: 'Dairy', currentStock: 4, alertThreshold: 10, status: 'Low Stock' },
  { id: 'ITM-004', name: 'Local Farm Eggs (Tray)', category: 'Dairy', currentStock: 0, alertThreshold: 5, status: 'Out of Stock' },
];

const InventoryPage = () => {
  const [inventory] = useState(mockInventory);

  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Inventory Management</h1>
          <p className="text-secondary">Bulk update your product stock and set low-stock alert thresholds.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <button className="btn btn-primary">Save All Changes</button>
        </div>
      </div>

      <div className="card" style={{ marginBottom: '24px', padding: '16px 24px', display: 'flex', gap: '16px', alignItems: 'center' }}>
        <input type="text" className="form-input" placeholder="Search product name or SKU..." style={{ flex: 1 }} />
        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <span style={{ fontSize: '0.9rem', fontWeight: '600' }}>Filter:</span>
          <button className="btn" style={{ backgroundColor: 'var(--primary-light)', color: 'var(--primary-dark)', padding: '6px 16px', fontSize: '0.85rem' }}>All Items</button>
          <button className="btn btn-outline" style={{ padding: '6px 16px', fontSize: '0.85rem' }}>Low Stock</button>
          <button className="btn btn-outline" style={{ padding: '6px 16px', fontSize: '0.85rem' }}>Out of Stock</button>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Product Code</th>
              <th>Product Name</th>
              <th>Category</th>
              <th style={{ width: '150px' }}>Alert Threshold</th>
              <th style={{ width: '150px' }}>Current Stock</th>
              <th>Status</th>
            </tr>
          </thead>
          <tbody>
            {inventory.map(item => (
              <tr key={item.id} style={{ backgroundColor: item.currentStock === 0 ? '#fef2f2' : item.status === 'Low Stock' ? '#fffbeb' : 'transparent' }}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{item.id}</td>
                <td style={{ fontWeight: '600' }}>{item.name}</td>
                <td>{item.category}</td>
                <td>
                  <input type="number" className="form-input" defaultValue={item.alertThreshold} style={{ padding: '8px', width: '100px' }} />
                </td>
                <td>
                  <input type="number" className="form-input" defaultValue={item.currentStock} style={{ padding: '8px', width: '100px', borderColor: item.currentStock === 0 ? 'var(--danger)' : item.status === 'Low Stock' ? 'var(--warning)' : 'var(--border)' }} />
                </td>
                <td>
                  <span className={`badge ${item.status === 'Healthy' ? 'badge-success' :
                      item.status === 'Low Stock' ? 'badge-warning' : 'badge-danger'
                    }`}>
                    {item.status}
                  </span>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

    </div>
  );
};

export default InventoryPage;
