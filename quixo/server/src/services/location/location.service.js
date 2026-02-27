const axios = require('axios');
const Rider = require('../rider/rider.model');

/**
 * Geocode an address to lat/lng using Google Maps API.
 */
exports.geocode = async (address) => {
  try {
    const key = process.env.GOOGLE_MAPS_API_KEY;
    if (!key || key === 'your_maps_key') {
      return { lat: 27.7172, lng: 85.3240, note: 'Default Kathmandu coordinates (no Maps API key)' };
    }
    const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(address)}&key=${key}`;
    const res = await axios.get(url);
    if (res.data.results?.length > 0) {
      return res.data.results[0].geometry.location;
    }
    return null;
  } catch (err) {
    console.error('Geocode error:', err.message);
    return null;
  }
};

/**
 * Get distance and duration between two points using Google Maps Distance Matrix.
 */
exports.getDistance = async (origin, destination) => {
  try {
    const key = process.env.GOOGLE_MAPS_API_KEY;
    if (!key || key === 'your_maps_key') {
      return { distance: { text: 'N/A' }, duration: { text: 'N/A' }, note: 'No Maps API key configured' };
    }
    const url = `https://maps.googleapis.com/maps/api/distancematrix/json` +
      `?origins=${encodeURIComponent(origin)}&destinations=${encodeURIComponent(destination)}&key=${key}`;
    const res = await axios.get(url);
    return res.data.rows[0]?.elements[0] || null;
  } catch (err) {
    console.error('Maps error:', err.message);
    return null;
  }
};

/**
 * Find nearby available riders within a rough radius (in km).
 * Uses simple bounding box calculation, not actual road distance.
 */
exports.findNearbyRiders = async (lat, lng, radiusKm = 5) => {
  // Approximate 1 degree = 111km
  const delta = radiusKm / 111;

  const riders = await Rider.find({
    isAvailable: true,
    status: 'approved',
    'location.lat': { $gte: lat - delta, $lte: lat + delta },
    'location.lng': { $gte: lng - delta, $lte: lng + delta },
  })
    .populate('userId', 'name phone')
    .select('name phone location rating deliveredOrders')
    .limit(20);

  return riders;
};

/**
 * Calculate delivery fee based on distance (simple tier-based).
 */
exports.calculateDeliveryFee = (distanceKm) => {
  if (distanceKm <= 2) return 50;
  if (distanceKm <= 5) return 80;
  if (distanceKm <= 10) return 120;
  if (distanceKm <= 20) return 180;
  return 250; // max fee
};
