import React from 'react';
import { Link, useNavigate } from 'react-router-dom';

const AddProduct = () => {
  const navigate = useNavigate();

  const handleSave = (e) => {
    e.preventDefault();
    console.log("Saving new product...");
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
          <h1 style={{ fontSize: '2rem', marginBottom: '4px' }}>Add New Product</h1>
          <p className="text-secondary">Create a new listing in your store catalog.</p>
        </div>
      </div>

      <div className="card">
        <form onSubmit={handleSave} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px' }}>Basic Details</h3>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Product Name</label>
            <input type="text" className="form-input" placeholder="e.g. Fresh Red Apples 1kg" required />
          </div>

          <div className="form-group" style={{ marginBottom: 0 }}>
            <label className="form-label">Product Description</label>
            <textarea className="form-input" rows="4" placeholder="Describe the item, sourced from, dietary info..." required></textarea>
          </div>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Category</label>
              <select className="form-input" required>
                <option value="">Select Category</option>
                <option value="veg">Vegetables & Fruits</option>
                <option value="dairy">Dairy & Bakery</option>
                <option value="packaged">Packaged Food</option>
                <option value="meat">Meat & Fish</option>
              </select>
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Status</label>
              <select className="form-input" required>
                <option value="active">Active (Visible)</option>
                <option value="draft">Draft (Hidden)</option>
              </select>
            </div>
          </div>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginTop: '20px' }}>Pricing & Inventory</h3>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Selling Price (NPR)</label>
              <input type="number" className="form-input" placeholder="0.00" min="0" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Discounted Price (Optional)</label>
              <input type="number" className="form-input" placeholder="0.00" min="0" />
            </div>
          </div>

          <div style={{ display: 'flex', gap: '20px' }}>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Available Stock Quantity</label>
              <input type="number" className="form-input" placeholder="0" min="0" required />
            </div>
            <div className="form-group" style={{ flex: 1, marginBottom: 0 }}>
              <label className="form-label">Unit of Measure</label>
              <select className="form-input" required>
                <option value="piece">Piece / Packet</option>
                <option value="kg">Kilogram (kg)</option>
                <option value="g">Gram (g)</option>
                <option value="l">Liter (L)</option>
              </select>
            </div>
          </div>

          <h3 style={{ fontSize: '1.1rem', borderBottom: '1px solid var(--border)', paddingBottom: '12px', marginTop: '20px' }}>Media</h3>

          <div className="form-group" style={{ border: '2px dashed var(--border)', borderRadius: 'var(--radius-sm)', padding: '30px', textAlign: 'center', backgroundColor: 'var(--bg-color)', marginBottom: 0 }}>
            <span style={{ fontSize: '2rem', display: 'block', marginBottom: '12px' }}>📸</span>
            <p style={{ fontWeight: '600', marginBottom: '4px' }}>Upload Product Images</p>
            <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '16px' }}>JPG or PNG up to 2MB (1:1 Ratio recommended)</p>
            <button type="button" className="btn btn-outline" style={{ backgroundColor: 'white' }}>Browse Files</button>
          </div>

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'flex-end', marginTop: '30px', paddingTop: '20px', borderTop: '1px solid var(--border)' }}>
            <Link to="/products">
              <button type="button" className="btn btn-outline">Cancel</button>
            </Link>
            <button type="submit" className="btn btn-primary" style={{ padding: '10px 30px' }}>Publish Product</button>
          </div>

        </form>
      </div>

    </div>
  );
};

export default AddProduct;
