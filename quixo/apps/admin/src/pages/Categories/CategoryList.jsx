import React from 'react';

const mockCategories = [
  { id: 'CAT-01', name: 'Groceries', type: 'Quick', active: true, products: 1250 },
  { id: 'CAT-02', name: 'Vegetables', type: 'Quick', active: true, products: 430 },
  { id: 'CAT-03', name: 'Electronics', type: '1-Day', active: true, products: 890 },
  { id: 'CAT-04', name: 'Bakery', type: 'Quick', active: false, products: 120 }
];

const CategoryList = () => {
  return (
    <div className="container animate-fade-in" style={{ padding: '40px' }}>

      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '30px' }}>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Product Categories</h1>
          <p className="text-secondary">Manage main platform categories for the frontend navigation.</p>
        </div>
        <button className="btn btn-primary">+ Create New Category</button>
      </div>

      <div className="table-container">
        <table className="data-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Category Name</th>
              <th>Delivery Speed</th>
              <th>Listed Products</th>
              <th>Status</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {mockCategories.map(cat => (
              <tr key={cat.id}>
                <td style={{ fontWeight: '500', color: 'var(--text-secondary)' }}>{cat.id}</td>
                <td style={{ fontWeight: '600', fontSize: '1.1rem' }}>{cat.name}</td>
                <td><span className="badge badge-neutral">{cat.type}</span></td>
                <td>{cat.products} products</td>
                <td>
                  <span className={`badge ${cat.active ? 'badge-success' : 'badge-danger'}`}>
                    {cat.active ? 'Active' : 'Disabled'}
                  </span>
                </td>
                <td>
                  <div style={{ display: 'flex', gap: '8px' }}>
                    <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>Edit</button>
                    <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.85rem' }}>{cat.active ? 'Disable' : 'Enable'}</button>
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

export default CategoryList;
