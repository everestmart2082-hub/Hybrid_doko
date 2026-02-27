const locationService = require('./location.service');

exports.geocode = async (req, res) => {
  try {
    const { address } = req.query;
    if (!address) return res.status(400).json({ success: false, message: 'Address query parameter is required' });
    const data = await locationService.geocode(address);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getDistance = async (req, res) => {
  try {
    const { origin, destination } = req.query;
    if (!origin || !destination) {
      return res.status(400).json({ success: false, message: 'Both origin and destination are required' });
    }
    const data = await locationService.getDistance(origin, destination);
    res.json({ success: true, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.findNearbyRiders = async (req, res) => {
  try {
    const { lat, lng, radius } = req.query;
    if (!lat || !lng) {
      return res.status(400).json({ success: false, message: 'Latitude and longitude are required' });
    }
    const data = await locationService.findNearbyRiders(
      parseFloat(lat), parseFloat(lng), parseFloat(radius) || 5
    );
    res.json({ success: true, count: data.length, data });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};

exports.getDeliveryFee = async (req, res) => {
  try {
    const { distance } = req.query;
    if (!distance) return res.status(400).json({ success: false, message: 'Distance (km) is required' });
    const fee = locationService.calculateDeliveryFee(parseFloat(distance));
    res.json({ success: true, fee, distance: parseFloat(distance) });
  } catch (err) { res.status(500).json({ success: false, message: err.message }); }
};
