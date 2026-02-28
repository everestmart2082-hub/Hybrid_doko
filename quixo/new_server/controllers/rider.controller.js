const Rider = require('../models/Rider.model');
const { generateToken, generateOTP } = require('./auth.helper');
const jwt = require('jsonwebtoken');

// /api/rider/registration/
const registerRider = async (req, res) => {
    try {
        const {
            name, number, email, rating, rcBook, citizenship,
            panCard, address, bikeModel, bikeNumber, bikeColor,
            type, bikeInsurancePaper
        } = req.body;

        let rider = await Rider.findOne({ number });

        if (rider) {
            return res.json({ success: false, message: "already registered" });
        }

        const otp = generateOTP();
        rider = new Rider({
            name, number, email, rating, rcBook, citizenship,
            panCard, address, bikeModel, bikeNumber, bikeColor,
            type, bikeInsurancePaper, otp
        });

        await rider.save();
        res.json({ success: true });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
};

// /api/rider/registration/otp
const verifyRiderRegistrationOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;
        const rider = await Rider.findOne({ number: phone });

        if (!rider || rider.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        rider.otp = null;
        await rider.save();

        res.json({
            success: true,
            message: "application submitted",
            token: generateToken(rider._id, 'rider')
        });
    } catch (error) {
        res.json({ success: false });
    }
}

// /api/rider/login/
const loginRider = async (req, res) => {
    try {
        const { phone } = req.body;
        const rider = await Rider.findOne({ number: phone });

        if (!rider || rider.suspended) {
            return res.json({ success: false, message: "login failure" });
        }

        rider.otp = generateOTP();
        await rider.save();

        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/rider/login/otp
const verifyRiderLoginOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;
        const rider = await Rider.findOne({ number: phone });

        if (!rider || rider.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        rider.otp = null;
        await rider.save();

        res.json({
            success: true,
            message: "success",
            token: generateToken(rider._id, 'rider')
        });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/rider/profile/get
const getRiderProfile = async (req, res) => {
    try {
        const { token } = req.body;
        if (!token) return res.json({ success: false, message: "token has expire" });
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const rider = await Rider.findById(decoded.id);
        if (!rider) return res.json({ success: false, message: "token has expire" });
        if (rider.suspended) return res.json({ success: false, message: "account has been suspended + violation..." });
        if (rider.violations && rider.violations.includes("blacklisted")) return res.json({ success: false, message: "account has been blacklisted+ violation..." });

        res.json({
            success: true,
            message: {
                name: rider.name,
                number: rider.number,
                defaultAddress: rider.address,
                email: rider.email,
                blueBook: rider.rcBook, // mapping schema fields to prompt spec
                bikeDetail: { model: rider.bikeModel, number: rider.bikeNumber, color: rider.bikeColor, type: rider.type },
                insurancePaper: rider.bikeInsurancePaper,
                panCard: rider.panCard,
                citizenship: rider.citizenship
            }
        });
    } catch (error) {
        res.json({ success: false, message: "token has expire" });
    }
}

// /api/rider/profile/update
const updateRiderProfile = async (req, res) => {
    try {
        const { token, number, description, defaultAddress } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const rider = await Rider.findById(decoded.id);
        if (rider.suspended) return res.json({ success: false, message: "suspended account" });

        if (number) rider.number = number;
        // schema does not explicitly have description out of the box, assuming it maps to nothing or handled elsewhere, but ignoring strictly is safest
        if (defaultAddress) rider.address = defaultAddress;

        rider.verified = false; // logic assuming structural change requires reverification
        await rider.save();

        res.json({ success: true, message: "successfully submitted" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/rider/profile/delete
const deleteRiderProfile = async (req, res) => {
    try {
        const { token, reason, options } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const rider = await Rider.findById(decoded.id);
        if (!rider) return res.json({ success: false, message: "server error" });

        if (options === 'pause') {
            rider.suspended = true;
            await rider.save();
            return res.json({ success: true, message: "successfully submitted for ..." });
        } else if (options === 'delete') {
            await Rider.findByIdAndDelete(decoded.id);
            return res.json({ success: true, message: "successfully submitted for ..." });
        }
        res.json({ success: false, message: "server error" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/rider/profile/otp
const verifyRiderProfileOtp = async (req, res) => {
    try {
        const { otp, phone } = req.body;

        const rider = await Rider.findOne({ number: phone });
        if (!rider || rider.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        rider.otp = null;
        await rider.save();
        res.json({ success: true, message: "successfully updated" });
    } catch (error) {
        res.json({ success: false, message: "otp verification failure" });
    }
}

// Dashboards, Metrics, Notifications, All Riders
const getRiderDashboard = async (req, res) => {
    try {
        const { token } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // This is a stubbed aggregator returning the explicit payload shape.
        // A real app would sum orders and earnings from DB based on decoded.id.
        res.json({
            success: true,
            message: {
                cards: {
                    "orders deliverd": 0, // Spelling preserved from spec
                    earnings: 0,
                    "pending ordere": 0
                }
            }
        });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const getRiderNotifications = async (req, res) => {
    try {
        const { token } = req.body;
        jwt.verify(token, process.env.JWT_SECRET);
        // Returning empty list as stub
        res.json({ success: true, message: [] });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const getAllRiders = async (req, res) => {
    try {
        const riders = await Rider.find();
        res.json({ success: true, message: riders });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

module.exports = {
    registerRider,
    verifyRiderRegistrationOtp,
    loginRider,
    verifyRiderLoginOtp,
    getRiderProfile,
    updateRiderProfile,
    deleteRiderProfile,
    verifyRiderProfileOtp,
    getRiderDashboard,
    getRiderNotifications,
    getAllRiders
};
