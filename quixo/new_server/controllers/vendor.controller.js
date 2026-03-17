const Vendor = require('../models/Vendor.model');
const { generateToken, generateOTP } = require('./auth.helper');
const jwt = require('jsonwebtoken');

// /api/vender/registration/
const registerVendor = async (req, res) => {
    try {
        const { name, number, pan, storeName, address, email, businessType, description, geolocation } = req.body;
        let vendor = await Vendor.findOne({ number });

        if (vendor) {
            return res.json({ success: false, message: "already registered" });
        }

        const otp = generateOTP();
        vendor = new Vendor({
            name, number, pan, storeName, address, email,
            businessType, description, geolocation, otp
        });

        await vendor.save();
        res.json({ success: true });
    } catch (error) {
        res.json({ success: false });
    }
};

// /api/vender/registration/otp
const verifyVendorRegistrationOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;
        const vendor = await Vendor.findOne({ number: phone });

        if (!vendor || vendor.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        vendor.otp = null;
        await vendor.save();

        res.json({
            success: true,
            message: "application submitted",
            token: generateToken(vendor._id, 'vendor')
        });
    } catch (error) {
        res.json({ success: false });
    }
}

// /api/vender/login/
const loginVendor = async (req, res) => {
    try {
        const { phone } = req.body;
        const vendor = await Vendor.findOne({ number: phone });

        if (!vendor || vendor.suspended) {
            return res.json({ success: false, message: "login failure" });
        }

        vendor.otp = generateOTP();
        await vendor.save();

        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/vender/login/otp
const verifyVendorLoginOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;
        const vendor = await Vendor.findOne({ number: phone });

        if (!vendor || vendor.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        vendor.otp = null;
        await vendor.save();

        res.json({
            success: true,
            message: "success",
            token: generateToken(vendor._id, 'vendor')
        });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/vender/profile/get
const getVendorProfile = async (req, res) => {
    try {
        const { token } = req.body;
        if (!token) return res.json({ success: false, message: "token has expire" });
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const vendor = await Vendor.findById(decoded.id);
        if (!vendor) return res.json({ success: false, message: "token has expire" });
        if (vendor.suspended) return res.json({ success: false, message: "account has been suspended + violation..." });
        if (vendor.violations && vendor.violations.includes("blacklisted")) return res.json({ success: false, message: "account has been blacklisted+ violation..." });

        res.json({
            success: true,
            message: {
                name: vendor.name,
                number: vendor.number,
                Pan: vendor.pan,
                storeName: vendor.storeName,
                Address: vendor.address,
                email: vendor.email,
                BusinessType: vendor.businessType,
                Description: vendor.description,
                geolocations: vendor.geolocation
            }
        });
    } catch (error) {
        res.json({ success: false, message: "token has expire" });
    }
}

// /api/vender/profile/update
const updateVendorProfile = async (req, res) => {
    try {
        const { token, number, name, description, address, geolocation } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const vendor = await Vendor.findById(decoded.id);
        if (vendor.suspended) return res.json({ success: false, message: "suspended account" });

        if (number) vendor.number = number;
        if (name) vendor.name = name;
        if (description) vendor.description = description;
        if (address) vendor.address = address;
        if (geolocation) vendor.geolocation = geolocation;

        vendor.verified = false; // re-verify perhaps
        await vendor.save();

        res.json({ success: true, message: "applied for verification" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/vender/profile/delete
const deleteVendorProfile = async (req, res) => {
    try {
        // reason, options {pause, delete}
        const { token, reason, options } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const vendor = await Vendor.findById(decoded.id);
        if (!vendor) return res.json({ success: false, message: "server error" });

        if (options === 'pause') {
            vendor.suspended = true; // reusing suspended for pause since schema lacks 'deactivate' here
            await vendor.save();
            return res.json({ success: true, message: "successfully paused/delete" });
        } else if (options === 'delete') {
            await Vendor.findByIdAndDelete(decoded.id);
            return res.json({ success: true, message: "successfully paused/delete" });
        }
        res.json({ success: false, message: "server error" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/vender/profile/otp
const verifyVendorProfileOtp = async (req, res) => {
    try {
        const { token, otp, phone } = req.body;
        // The token verification makes 'phone' redundant structurally, but the prompt says 'phone' so let's match spec format
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const vendor = await Vendor.findById(decoded.id);
        if (!vendor || vendor.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        vendor.otp = null;
        await vendor.save();
        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "otp verification failure" });
    }
}

// Product Management Logic
const addVendorProduct = async (req, res) => {
    try {
        const { token, product: { name, brand, "short descriptions": shortDescription, description, "price per unit": pricePerUnit, "unit ": unit, discount, "product catagory (link to category id)": category, "stock ": stock, "Photos ": photos, required, others }, type } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Creating the product exactly with the payload's keys but mapping them cleanly to our schema fields
        const Product = require('../models/Product.model'); // Inline require for simplicity assuming it's loaded globally later 
        const newProduct = new Product({
            name, brand, shortDescription, description, pricePerUnit, unit, discount, category, stock, photos,
            vendorId: decoded.id, // Linking vendor directly
            rating: 0,
            approved: false, // Default to false
            required, others, type
        });

        await newProduct.save();

        res.json({ success: true, message: "successfully submitted to verify" }); // Payload specified string
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const editVendorProduct = async (req, res) => {
    try {
        const { token, "product id": productId, product: { name, brand, "short descriptions": shortDescription, description, "price per unit": pricePerUnit, "unit ": unit, discount, "product catagory (link to category id)": category, "stock ": stock, "Photos ": photos, required, others }, type } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const Product = require('../models/Product.model');
        const updatedProduct = await Product.findOneAndUpdate({ _id: productId, vendorId: decoded.id }, {
            name, brand, shortDescription, description, pricePerUnit, unit, discount, category, stock, photos,
            required, others, type,
            approved: false // Force re-verify on edit as implicit good practice, spec message implies this
        }, { new: true });

        if (!updatedProduct) return res.json({ success: false, message: "server error" });

        res.json({ success: true, message: "successfully submitted to verify" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const deleteVendorProduct = async (req, res) => {
    try {
        const { token, "product id": productId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const Product = require('../models/Product.model');
        await Product.findOneAndDelete({ _id: productId, vendorId: decoded.id });

        res.json({ success: true, message: "successfully deleted" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// Order Management Logic
const Order = require('../models/Order.model');

const getAllVendorOrders = async (req, res) => {
    try {
        const { token, filter } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        let query = { vendorId: decoded.id };
        if (filter) query.status = filter;

        const orders = await Order.find(query)
            .populate('customerId', 'name number')
            .populate('products.productId', 'name photos pricePerUnit')
            .sort({ createdAt: -1 });
        res.json({ success: true, message: orders });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// Mark a SINGLE product inside an order as prepared.
// When ALL products are prepared → auto-mark order as 'prepared'.
const setOrderPrepared = async (req, res) => {
    try {
        const { token, "order id": orderId, "product id": productId, time } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const order = await Order.findOne({ _id: orderId, vendorId: decoded.id });
        if (!order) return res.json({ success: false, message: "order not found" });

        if (productId) {
            // Mark specific product as prepared
            let found = false;
            order.products.forEach(p => {
                if (p.productId.toString() === productId) {
                    p.status = 'prepared';
                    found = true;
                }
            });
            if (!found) return res.json({ success: false, message: "product not found in order" });

            // Check if ALL products are now prepared
            const allPrepared = order.products.every(p => p.status === 'prepared');
            if (allPrepared) {
                order.status = 'prepared';
            }
        } else {
            // Legacy: no productId → mark entire order as prepared
            order.products.forEach(p => { p.status = 'prepared'; });
            order.status = 'prepared';
        }

        await order.save();
        res.json({ success: true, message: "success" });
    } catch (error) {
        console.error("setOrderPrepared Error:", error);
        res.json({ success: false, message: "server error" });
    }
}

// Auxiliary (Dashboard/Charts, etc)
const getVendorChart = async (req, res) => {
    try {
        const { token } = req.body;
        jwt.verify(token, process.env.JWT_SECRET);
        // Stub for graph data
        res.json({ success: true, message: { labels: [], datasets: [] } });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const getAllVendors = async (req, res) => {
    try {
        const vendors = await Vendor.find();
        res.json({ success: true, message: vendors });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

module.exports = {
    registerVendor,
    verifyVendorRegistrationOtp,
    loginVendor,
    verifyVendorLoginOtp,
    getVendorProfile,
    updateVendorProfile,
    deleteVendorProfile,
    verifyVendorProfileOtp,
    addVendorProduct,
    editVendorProduct,
    deleteVendorProduct,
    getAllVendorOrders,
    setOrderPrepared,
    getVendorChart,
    getAllVendors
};
