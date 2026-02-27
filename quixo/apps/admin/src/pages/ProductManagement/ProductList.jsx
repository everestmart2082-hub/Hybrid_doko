import React from 'react';

const mockProducts = [
  { id: 'PRD-101', name: 'Amul Taza Milk 1L', vendor: 'KTM Fresh', stock: 45, price: 'NPR 100', status: 'Active' },
  { id: 'PRD-102', name: 'Wai Wai Chicken Noodles', vendor: 'KTM Fresh', stock: 120, price: 'NPR 25', status: 'Active' },
  { id: 'PRD-103', name: 'Real Apple Juice 1L', vendor: 'Daily Needs', stock: 0, price: 'NPR 250', status: 'Out of Stock' },
  { id: 'PRD-104', name: 'Samsung USB-C Cable', vendor: 'TechGadgets', stock: 15, price: 'NPR 800', status: 'Active' },
];

const ProductList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Global Product Inventory</h1>
          <p className="text-secondary">View and manage all active and inactive products on Doko.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <select className="form-input" style={{ width: 'auto' }}>
            <option>All Inventory</option>
            <option>Low Stock</option>
            <option>Out of Stock</option>
          </select>
          <input type="text" className="form-input" placeholder="Search product name or ID..." style={{ width: '300px' }} />
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Product Name</th>
              <th>Vendor</th>
              <th>Price</th>
              <th>Global Stock</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockProducts.map(prod => (
              <tr key={prod.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{prod.id}</td>
                <td style={{ fontWeight: '600' }}>{prod.name}</td>
                <td>{prod.vendor}</td>
                <td style={{ fontWeight: '600' }}>{prod.price}</td>
                <td>
                  <span style={{ color: prod.stock === 0 ? 'var(--danger)' : prod.stock < 20 ? 'var(--warning)' : 'inherit' }}>
                    {prod.stock} units
                  </span>
                </td>
                <td>
                  <span className={`badge ${prod.status === 'Active' ? 'badge-success' : 'badge-danger'}`}>
                    {prod.status}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem' }}>View</button>
                    <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem', color: 'var(--danger)', borderColor: 'var(--danger)' }}>Delist</button>
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

export default ProductList;
