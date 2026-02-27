import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

const StoreSetupPage = () => {
  const navigate = useNavigate();
  const [step, setStep] = useState(1);

  const handleNext = (e) => {
    e.preventDefault();
    if (step === 1) setStep(2);
    else {
      // Final submission
      console.log('Store Profile created successfully!');
      navigate('/');
    }
  };

  return (
    <div className="container animate-fade-in" style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>

      <div style={{ textAlign: 'center', marginBottom: '40px' }}>
        <h1 style={{ fontSize: '2.5rem', marginBottom: '8px' }}>Store Onboarding</h1>
        <p className="text-secondary">Complete your profile to start receiving orders on Doko.</p>

        <div style={{ display: 'flex', justifyContent: 'center', gap: '16px', marginTop: '24px' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: 'var(--primary)', color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>1</div>
            <span style={{ fontWeight: step === 1 ? '700' : '400', color: step === 1 ? 'var(--text-primary)' : 'var(--text-secondary)' }}>Basic Info</span>
          </div>
          <div style={{ height: '2px', width: '40px', backgroundColor: step === 2 ? 'var(--primary)' : 'var(--border)', alignSelf: 'center' }}></div>
          <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
            <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: step === 2 ? 'var(--primary)' : 'var(--border)', color: step === 2 ? 'white' : 'var(--text-secondary)', display: 'flex', alignItems: 'center', justifyContent: 'center', fontWeight: 'bold' }}>2</div>
            <span style={{ fontWeight: step === 2 ? '700' : '400', color: step === 2 ? 'var(--text-primary)' : 'var(--text-secondary)' }}>Documents</span>
          </div>
        </div>
      </div>

      <div className="card" style={{ padding: '40px' }}>
        <form onSubmit={handleNext}>

          {step === 1 && (
            <div className="animate-fade-in">
              <h3 style={{ fontSize: '1.2rem', marginBottom: '24px', paddingBottom: '12px', borderBottom: '1px solid var(--border)' }}>Business Details</h3>

              <div className="form-group">
                <label className="form-label">Store / Business Name</label>
                <input type="text" className="form-input" placeholder="e.g. Kathmandu Fresh Mart" required />
              </div>

              <div style={{ display: 'flex', gap: '20px' }}>
                <div className="form-group" style={{ flex: 1 }}>
                  <label className="form-label">Primary Category</label>
                  <select className="form-input" required>
                    <option value="">Select Category...</option>
                    <option value="grocery">Grocery & Essentials (Quick)</option>
                    <option value="electronics">Electronics (1-Day)</option>
                    <option value="fashion">Fashion & Apparel (1-Day)</option>
                    <option value="pharmacy">Pharmacy & Health (Quick)</option>
                  </select>
                </div>
                <div className="form-group" style={{ flex: 1 }}>
                  <label className="form-label">Store Phone Number</label>
                  <input type="tel" className="form-input" placeholder="+977" required />
                </div>
              </div>

              <div className="form-group">
                <label className="form-label">Physical Store Address</label>
                <textarea className="form-input" rows="3" placeholder="Full address of your warehouse or retail location" required></textarea>
              </div>
            </div>
          )}

          {step === 2 && (
            <div className="animate-fade-in">
              <h3 style={{ fontSize: '1.2rem', marginBottom: '24px', paddingBottom: '12px', borderBottom: '1px solid var(--border)' }}>Legal & Bank KYC</h3>

              <div className="form-group">
                <label className="form-label">PAN / VAT Number</label>
                <input type="text" className="form-input" placeholder="Enter registration number" required />
              </div>

              <div className="form-group" style={{ border: '2px dashed var(--border)', borderRadius: 'var(--radius-sm)', padding: '30px', textAlign: 'center', backgroundColor: 'var(--bg-color)', marginBottom: '24px' }}>
                <span style={{ fontSize: '2rem', display: 'block', marginBottom: '12px' }}>📄</span>
                <p style={{ fontWeight: '600', marginBottom: '4px' }}>Upload Company Registration Document</p>
                <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '16px' }}>PDF, JPG or PNG up to 5MB</p>
                <button type="button" className="btn btn-outline" style={{ backgroundColor: 'white' }}>Select File</button>
              </div>

              <div className="form-group">
                <label className="form-label">Payout Bank Account Info</label>
                <textarea className="form-input" rows="3" placeholder="Bank Name:&#10;Account Name:&#10;Account Number:" required></textarea>
              </div>
            </div>
          )}

          <div style={{ display: 'flex', gap: '16px', justifyContent: 'space-between', marginTop: '40px', paddingTop: '24px', borderTop: '1px solid var(--border)' }}>
            {step === 2 ? (
              <button type="button" className="btn btn-outline" onClick={() => setStep(1)}>Back</button>
            ) : <div></div>}

            <button type="submit" className="btn btn-primary" style={{ padding: '12px 32px' }}>
              {step === 1 ? 'Continue to Documents' : 'Submit Application'}
            </button>
          </div>

        </form>
      </div>

    </div>
  );
};

export default StoreSetupPage;
