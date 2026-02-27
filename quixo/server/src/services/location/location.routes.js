const express = require('express');
const router = express.Router();
const ctrl = require('./location.controller');
const { authGuard, isAdmin } = require('../../shared/middleware/authGuard');

router.get('/geocode', authGuard, ctrl.geocode);           // geocode address
router.get('/distance', authGuard, ctrl.getDistance);       // distance between two points
router.get('/nearby-riders', authGuard, isAdmin, ctrl.findNearbyRiders); // find available riders near a point
router.get('/delivery-fee', authGuard, ctrl.getDeliveryFee);    // calculate delivery fee by distance

module.exports = router;
