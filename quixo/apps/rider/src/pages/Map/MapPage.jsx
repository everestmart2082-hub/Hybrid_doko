import React from 'react';

const MapPage = () => {
  return (
    <div className="view-container animate-fade-in" style={{ padding: 0, minHeight: '100vh', display: 'flex', flexDirection: 'column' }}>

      <div style={{ padding: '20px', backgroundColor: 'var(--surface)', position: 'absolute', top: 0, left: 0, right: 0, zIndex: 10, boxShadow: 'var(--shadow-sm)' }}>
        <h1 style={{ fontSize: '1.5rem', margin: 0 }}>Demand Hotspots</h1>
        <p className="text-secondary" style={{ fontSize: '0.85rem', marginTop: '4px' }}>Move to red zones to increase order chances.</p>
      </div>

      {/* Map Placeholder */}
      <div style={{ flex: 1, backgroundColor: '#e2e8f0', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', position: 'relative' }}>

        <div style={{ fontSize: '4rem', opacity: 0.3, marginBottom: '20px' }}>🗺️</div>
        <p style={{ color: 'var(--text-secondary)', fontWeight: '600' }}>Google Maps Integration Placeholder</p>

        {/* Heatmap rings mockup */}
        <div style={{ position: 'absolute', top: '40%', left: '50%', transform: 'translate(-50%, -50%)', width: '300px', height: '300px', borderRadius: '50%', backgroundColor: 'rgba(249, 115, 22, 0.1)' }}></div>
        <div style={{ position: 'absolute', top: '40%', left: '50%', transform: 'translate(-50%, -50%)', width: '150px', height: '150px', borderRadius: '50%', backgroundColor: 'rgba(239, 68, 68, 0.2)' }}></div>

        {/* Rider Loc Marker */}
        <div style={{ position: 'absolute', top: '45%', left: '50%', transform: 'translate(-50%, -50%)', zIndex: 5 }}>
          <div style={{ width: '40px', height: '40px', backgroundColor: 'white', borderRadius: '50%', display: 'flex', alignItems: 'center', justifyContent: 'center', boxShadow: 'var(--shadow-lg)' }}>
            🛵
          </div>
          <div style={{ width: '10px', height: '10px', backgroundColor: 'var(--primary)', borderRadius: '50%', margin: '0 auto', marginTop: '-5px', boxShadow: '0 0 10px var(--primary)' }}></div>
        </div>

      </div>

      {/* Bottom Info Widget */}
      <div style={{ position: 'absolute', bottom: '90px', left: '20px', right: '20px', backgroundColor: 'var(--surface)', padding: '20px', borderRadius: 'var(--radius-lg)', boxShadow: 'var(--shadow-lg)', zIndex: 10 }}>
        <h3 style={{ fontSize: '1.1rem', marginBottom: '8px' }}>High Demand in <span style={{ color: 'var(--primary)' }}>Baneshwor</span></h3>
        <p style={{ color: 'var(--text-secondary)', fontSize: '0.9rem', marginBottom: '16px' }}>+ NPR 50 bonus per delivery in this zone for the next hour.</p>
        <button className="btn btn-primary" style={{ width: '100%' }}>Navigate There</button>
      </div>

    </div>
  );
};

export default MapPage;
