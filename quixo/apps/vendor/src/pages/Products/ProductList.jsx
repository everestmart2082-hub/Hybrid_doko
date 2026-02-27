import React from 'react';
import { Link } from 'react-router-dom';

const mockProducts = [
  { id: 'PRD-101', name: 'Fresh Organic Tomatoes', category: 'Vegetables', price: 'NPR 120/kg', stock: 45, status: 'Active' },
  { id: 'PRD-102', name: 'Wai Wai Noodles (Chicken)', category: 'Packaged Food', price: 'NPR 25', stock: 200, status: 'Active' },
  { id: 'PRD-103', name: 'Amul Butter 500g', category: 'Dairy', price: 'NPR 450', stock: 4, status: 'Low Stock' },
  { id: 'PRD-104', name: 'Local Farm Eggs (Tray)', category: 'Dairy', price: 'NPR 400', stock: 0, status: 'Out of Stock' },
];

const ProductList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>My Products</h1>
          <p className="text-secondary">Manage your store's catalog and monitor stock levels.</p>
        </div>
        <div style={{ display: 'flex', gap: '16px' }}>
          <button className="btn btn-outline">Export List</button>
          <Link to="/products/add">
            <button className="btn btn-primary">+ Add New Product</button>
          </Link>
        </div>
      </div>

      <div className="card" style={{ marginBottom: '24px', padding: '16px 24px' }}>
        <div style={{ display: 'flex', gap: '16px' }}>
          <input type="text" className="form-input" placeholder="Search by product name or ID..." style={{ flex: 1 }} />
          <select className="form-input" style={{ width: '200px' }}>
            <option value="">All Categories</option>
            <option value="veg">Vegetables</option>
            <option value="dairy">Dairy</option>
            <option value="packaged">Packaged Food</option>
          </select>
          <select className="form-input" style={{ width: '200px' }}>
            <option value="">All Statuses</option>
            <option value="active">Active</option>
            <option value="low">Low Stock</option>
            <option value="out">Out of Stock</option>
          </select>
        </div>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>Image</th>
              <th>Product Name</th>
              <th>Category</th>
              <th>Price</th>
              <th>Current Stock</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockProducts.map(product => (
              <tr key={product.id}>
                <td>
                  <div style={{ width: '40px', height: '40px', backgroundColor: '#e2e8f0', borderRadius: '4px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    📦
                  </div>
                </td>
                <td style={{ fontWeight: '600' }}>
                  {product.name}
                  <div style={{ fontSize: '0.8rem', color: 'var(--text-secondary)', fontWeight: 'normal' }}>{product.id}</div>
                </td>
                <td>{product.category}</td>
                <td style={{ fontWeight: '500' }}>{product.price}</td>
                <td>
                  <span style={{
                    fontWeight: 'bold',
                    color: product.stock === 0 ? 'var(--danger)' : product.stock < 10 ? 'var(--warning)' : 'var(--text-primary)'
                  }}>
                    {product.stock} units
                  </span>
                </td>
                <td>
                  <span className={`badge ${product.status === 'Active' ? 'badge-success' :
                      product.status === 'Low Stock' ? 'badge-warning' : 'badge-danger'
                    }`}>
                    {product.status}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <Link to={`/products/${product.id}`}>
                      <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem' }}>Edit</button>
                    </Link>
                    <button className="btn btn-outline" style={{ padding: '4px 8px', fontSize: '0.8rem', color: 'var(--danger)', borderColor: 'var(--danger)' }}>Delete</button>
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
