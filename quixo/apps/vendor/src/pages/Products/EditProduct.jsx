import React from 'react';
import { Link, useNavigate, useParams } from 'react-router-dom';

const EditProduct = () => {
  const { id } = useParams();
  const navigate = useNavigate();

  const handleUpdate = (e) => {
    e.preventDefault();
    console.log("Updating product...", id);
    navigate('/products');
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>

      <div style={{ display: 'flex', gap: '30px', marginBottom: '30px', alignItems: 'center' }}>
        <Link to="/products">
          <button className="btn btn-outline" style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', width: '40px', height: '40px', padding: 0, borderRadius: '50%' }}>
            ←
          </button>
        </Link>
        <div>
          <h1 style={{ fontSize: '2rem', marginBottom: '4px' }}>Edit Product: {id || 'PRD-102'}</h1>
          <p className="text-secondary">Modify existing details and inventory stock.</p>
        </div>
      </div>

      <div className="card">
        <form onSubmit={handleUpdate} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Basic Details</h3>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Product Name</label>
            <input type="text" className="form-input" defaultValue="Wai Wai Noodles (Chicken)" required />
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Product Description</label>
            <textarea className="form-input" rows="4" defaultValue="Instant noodles ready in 2 minutes. Chicken flavor." required></textarea>
          </div>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Category</label>
              <select className="form-input" defaultValue="packaged" required>
                <option value="veg">Vegetables & Fruits</option>
                <option value="dairy">Dairy & Bakery</option>
                <option value="packaged">Packaged Food</option>
                <option value="meat">Meat & Fish</option>
              </select>
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Status</label>
              <select className="form-input" defaultValue="active" required>
                <option value="active">Active (Visible)</option>
                <option value="draft">Draft (Hidden)</option>
              </select>
            </div>
          </div>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginTop: '20px' }}>Pricing & Inventory</h3>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Selling Price (NPR)</label>
              <input type="number" className="form-input" defaultValue="25" min="0" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Discounted Price (Optional)</label>
              <input type="number" className="form-input" placeholder="0.00" min="0" />
            </div>
          </div>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Available Stock Quantity</label>
              <input type="number" className="form-input" defaultValue="200" min="0" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Unit of Measure</label>
              <select className="form-input" defaultValue="piece" required>
                <option value="piece">Piece / Packet</option>
                <option value="kg">Kilogram (kg)</option>
                <option value="g">Gram (g)</option>
                <option value="l">Liter (L)</option>
              </select>
            </div>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end', marginTop: '30px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <button type="button" className="btn btn-outline" style={{ color: 'var(--danger)', borderColor: 'var(--danger)', marginRight: 'auto' }}>
              Delete Product
            </button>
            <Link to="/products">
              <button type="button" className="btn btn-outline">Cancel</button>
            </Link>
            <button type="submit" className="btn btn-primary" style={{ padding: '10px 30px' }}>Update Save</button>
          </div>

        </form>
      </div>

    </div>
  );
};

export default EditProduct;
