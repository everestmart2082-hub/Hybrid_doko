const express = require('express');
const router = express.Router();

router.get('/all', (req, res) => res.json({ success: true, message: "Route reached" }));
router.get('/id', (req, res) => res.json({ success: true, message: "Route reached" }));
router.get('/recommended', (req, res) => res.json({ success: true, message: "Route reached" }));

module.exports = router;
