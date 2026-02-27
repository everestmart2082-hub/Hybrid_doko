import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

const CreateCategory = () => {
  const navigate = useNavigate();

  const handleSave = (e) => {
    e.preventDefault();
    navigate('/categories');
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>

      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px' }}>
        <Link to="/categories">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '8px' }}>Create New Category</h1>
          <p className="text-secondary">Add a new product category to the platform directory.</p>
        </div>
      </div>

      <div className="card">
        <form onSubmit={handleSave}>
          <div className="form-group">
            <label className="form-label">Category Name</label>
            <input type="text" className="form-input" placeholder="e.g. Frozen Foods" required />
          </div>

          <div style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Delivery Speed Model</label>
              <select className="form-input" required>
                <option value="quick">Quick Commerce (10-30m)</option>
                <option value="1day">Next Day Delivery</option>
              </select>
            </div>

            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Category Icon (Emoji)</label>
              <input type="text" className="form-input" placeholder="e.g. 🧊" required />
            </div>
          </div>

          <div className="form-group">
            <label className="form-label">Status</label>
            <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
              <input type="checkbox" defaultChecked style={{ width: '18px', height: '18px' }} />
              <span>Enable Category Immediately</span>
            </label>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end', marginTop: '30px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <Link to="/categories">
              <button type="button" className="btn btn-outline">Cancel</button>
            </Link>
            <button type="submit" className="btn btn-primary" style={{ padding: '10px 30px' }}>Save Category</button>
          </div>
        </form>
      </div>

    </div>
  );
};

export default CreateCategory;
