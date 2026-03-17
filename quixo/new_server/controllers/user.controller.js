const User = require('../models/User.model');
const { generateToken, generateOTP } = require('./auth.helper');
const jwt = require('jsonwebtoken');

// /api/user/registration/
const registerUser = async (req, res) => {
    try {
        const { phone, email } = req.body;
        let user = await User.findOne({ number: phone });

        if (user) {
            if (user.suspended) return res.json({ success: false, message: "suspended account" });
            return res.json({ success: false, message: "already registered" });
        }

        const otp = generateOTP();
        user = new User({ number: phone, email, name: "User", otp });
        await user.save();

        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
};

// /api/user/registration/otp
const verifyRegistrationOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;
        const user = await User.findOne({ number: phone });

        if (!user || user.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        user.otp = null;
        await user.save();

        res.json({
            success: true,
            message: "success",
            token: generateToken(user._id, 'user')
        });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/user/login/
const loginUser = async (req, res) => {
    try {
        const { phone } = req.body;
        const user = await User.findOne({ number: phone });

        if (!user || user.suspended) {
            return res.json({ success: false, message: "login failure" });
        }

        user.otp = generateOTP();
        await user.save();

        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/user/login/otp
const verifyLoginOtp = async (req, res) => {
    try {
        const { phone, otp } = req.body;
        const user = await User.findOne({ number: phone });

        if (!user || user.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        user.otp = null;
        await user.save();

        res.json({
            success: true,
            message: "success",
            token: generateToken(user._id, 'user')
        });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/user/profile/get
const getUserProfile = async (req, res) => {
    try {
        const { token } = req.body;
        if (!token) return res.json({ success: false, message: "token has expire" });
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const user = await User.findById(decoded.id).populate('defaultAddress');
        if (!user) return res.json({ success: false, message: "token has expire" });
        if (user.suspended) return res.json({ success: false, message: "account has been suspended + violation..." });
        if (user.violations && user.violations.includes("blacklisted")) return res.json({ success: false, message: "account has been blacklisted+ violation..." });

        res.json({
            success: true,
            message: {
                name: user.name,
                number: user.number,
                defaultAddress: user.defaultAddress,
                email: user.email
            }
        });
    } catch (error) {
        res.json({ success: false, message: "token has expire" });
    }
}

// /api/user/profile/update
const updateUserProfile = async (req, res) => {
    try {
        const { token, number, name, description, defaultAddress } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const user = await User.findById(decoded.id);
        if (user.suspended) return res.json({ success: false, message: "suspended account" });

        if (number) user.number = number;
        if (name) user.name = name;
        if (defaultAddress) user.defaultAddress = defaultAddress;

        await user.save();
        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/user/profile/delete
const deleteUserProfile = async (req, res) => {
    try {
        const { token, reason, options } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const user = await User.findById(decoded.id);
        if (!user) return res.json({ success: false, message: "server error" });

        if (options === 'pause') {
            user.deactivate = true;
            await user.save();
            return res.json({ success: true, message: "successfully paused/delete" });
        } else if (options === 'delete') {
            await User.findByIdAndDelete(decoded.id);
            return res.json({ success: true, message: "successfully paused/delete" });
        }
        res.json({ success: false, message: "server error" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// /api/user/profile/otp
const verifyUserProfileOtp = async (req, res) => {
    try {
        const { token, otp, phone } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const user = await User.findById(decoded.id);
        if (!user || user.otp !== otp) {
            return res.json({ success: false, message: "otp verification failure" });
        }

        user.otp = null;
        await user.save();
        res.json({ success: true, message: "successfully updated" });
    } catch (error) {
        res.json({ success: false, message: "otp verification failure" });
    }
}

// ─── Cart & Orders ───────────────────────────────────────
const Cart = require('../models/Cart.model');
const Order = require('../models/Order.model');

const addToCart = async (req, res) => {
    try {
        const { token, product: productId, number } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // Flat cart model: one doc per user+product
        let cartItem = await Cart.findOne({ userId: decoded.id, productId });
        if (cartItem) {
            cartItem.number += (number || 1);
            await cartItem.save();
        } else {
            cartItem = new Cart({ userId: decoded.id, productId, number: number || 1 });
            await cartItem.save();
        }

        res.json({ success: true, message: "successfully added" });
    } catch (error) {
        console.error('addToCart error:', error.message);
        res.json({ success: false, message: "server error" });
    }
}

const removeFromCart = async (req, res) => {
    try {
        const { token, product: productId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        await Cart.findOneAndDelete({ userId: decoded.id, productId });
        res.json({ success: true, message: "successfully deleted" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// ─── CHECKOUT: Auto-splits by vendor + deliveryCategory ───
const checkoutCart = async (req, res) => {
    try {
        const address = req.body.address || req.body["address id"];
        const paymentMethod = req.body.paymentMethod || req.body["payment id/cash"] || 'cash on delivary';
        const token = req.body.token;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        // 1. Fetch all cart items with full product info
        const cartItems = await Cart.find({ userId: decoded.id }).populate('productId');
        if (!cartItems.length) return res.json({ success: false, message: "cart is empty" });

        // 2. Group by vendorId + deliveryCategory
        const groups = {};
        cartItems.forEach(item => {
            if (!item.productId) return;
            const vId = item.productId.vendorId.toString();
            const cat = item.productId.deliveryCategory === 'quick' ? 'quick' : 'ecommerce';
            const key = `${vId}__${cat}`;
            if (!groups[key]) groups[key] = { vendorId: vId, category: cat, items: [] };
            groups[key].items.push(item);
        });

        const orderIds = [];
        const otp = Math.floor(1000 + Math.random() * 9000).toString();

        // 3. Create one order per group
        for (const key in groups) {
            const group = groups[key];

            let subTotal = 0;
            const orderProducts = group.items.map(item => {
                const price = item.productId.pricePerUnit || 0;
                const discount = item.productId.discount || 0;
                const effectivePrice = Math.round(Math.max(0, price - (price * discount / 100)));
                subTotal += effectivePrice * item.number;
                return {
                    productId: item.productId._id,
                    number: item.number,
                    pricePerUnit: effectivePrice,
                    status: 'preparing'
                };
            });

            // Delivery charges: quick free above 300, ecommerce free above 1000
            let deliveryCharge = 0;
            if (group.category === 'quick') {
                deliveryCharge = subTotal >= 300 ? 0 : 50;
            } else {
                deliveryCharge = subTotal >= 1000 ? 0 : 100;
            }

            // Map payment method
            let payMethod = paymentMethod;
            if (payMethod === 'cashOnDelivery' || payMethod === 'cod') payMethod = 'cash on delivary';

            const order = new Order({
                customerId: decoded.id,
                vendorId: group.vendorId,
                products: orderProducts,
                deliveryAddress: typeof address === 'object' ? address : { address: address },
                paymentMethod: payMethod,
                deliveryCategory: group.category,
                subTotal: Math.round(subTotal),
                deliveryCharge,
                total: Math.round(subTotal + deliveryCharge),
                otp,
                status: 'preparing'
            });
            const saved = await order.save();
            orderIds.push(saved._id);
        }

        // 4. Clear user's entire cart
        await Cart.deleteMany({ userId: decoded.id });

        res.json({
            success: true,
            message: "order placement",
            orderId: orderIds[0],
            orderIds
        });
    } catch (error) {
        console.error("Checkout Error:", error);
        res.json({ success: false, message: "payment faliure" });
    }
}

const getPaymentLink = async (req, res) => {
    try {
        const { token, "order id": orderId, method } = req.body;
        jwt.verify(token, process.env.JWT_SECRET);
        res.json({ success: true, message: `https://mock.payment.gateway/${method}/${orderId}` });
    } catch (error) {
        res.json({ success: false, message: "payment faliure" });
    }
}

const getAllUserOrders = async (req, res) => {
    try {
        const { token, filter } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        let query = { customerId: decoded.id };
        if (filter) query.status = filter;

        const orders = await Order.find(query)
            .populate('products.productId', 'name photos')
            .populate('vendorId', 'storeName')
            .sort({ createdAt: -1 });
        res.json({ success: true, message: orders });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// Cancelled orders stay in DB with status='cancelled'
const cancelUserOrder = async (req, res) => {
    try {
        const { token, "order id": orderId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const order = await Order.findOneAndUpdate(
            { _id: orderId, customerId: decoded.id },
            { status: 'cancelled' },
            { new: true }
        );
        if (!order) return res.json({ success: false, message: "order not found" });
        res.json({ success: true, message: "successfully cancelled" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const reorderUserOrder = async (req, res) => {
    try {
        const { token, "order id": orderId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        res.json({ success: true, message: "successfully ordered" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

const setOrderDeliveredUser = async (req, res) => {
    try {
        const { token, "order id": orderId, otp } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const order = await Order.findOne({ _id: orderId, customerId: decoded.id });
        if (!order || order.otp !== otp) return res.json({ success: false, message: "otp wrong" });

        order.status = 'delivered';
        await order.save();

        res.json({ success: true, message: "success" });
    } catch (error) {
        res.json({ success: false, message: "server error" });
    }
}

// ─── Address Management ──────────────────────────────────
const Address = require('../models/Address.model');

const getAllAddresses = async (req, res) => {
    try {
        const { token } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const addresses = await Address.find({ userId: decoded.id }).sort({ isDefault: -1, createdAt: -1 });
        const user = await User.findById(decoded.id);
        res.json({ success: true, message: addresses, defaultAddress: user?.defaultAddress });
    } catch (err) {
        console.error('getAllAddresses error:', err.message);
        res.json({ success: false, message: "server error" });
    }
}

const addUserAddress = async (req, res) => {
    try {
        const { token, label, address, city, landmark, phone, pincode, state, isDefault } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const addr = new Address({ userId: decoded.id, label, address, city, landmark, phone, pincode, state, isDefault });
        await addr.save();
        if (isDefault) {
            await Address.updateMany({ userId: decoded.id, _id: { $ne: addr._id } }, { isDefault: false });
            await User.findByIdAndUpdate(decoded.id, { defaultAddress: addr._id });
        }
        res.json({ success: true, message: addr });
    } catch (err) {
        console.error('addUserAddress error:', err.message);
        res.json({ success: false, message: "server error" });
    }
}

const deleteUserAddress = async (req, res) => {
    try {
        const { token, addressId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        await Address.findOneAndDelete({ _id: addressId, userId: decoded.id });
        res.json({ success: true, message: "successfully deleted" });
    } catch (err) {
        res.json({ success: false, message: "server error" });
    }
}

const updateUserAddress = async (req, res) => {
    try {
        const { token, addressId, label, address, city, landmark, phone, pincode, state, isDefault } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const updateData = {};
        if (label !== undefined) updateData.label = label;
        if (address !== undefined) updateData.address = address;
        if (city !== undefined) updateData.city = city;
        if (landmark !== undefined) updateData.landmark = landmark;
        if (phone !== undefined) updateData.phone = phone;
        if (pincode !== undefined) updateData.pincode = pincode;
        if (state !== undefined) updateData.state = state;
        if (isDefault !== undefined) updateData.isDefault = isDefault;

        await Address.findOneAndUpdate({ _id: addressId, userId: decoded.id }, updateData);
        if (isDefault) {
            await Address.updateMany({ userId: decoded.id, _id: { $ne: addressId } }, { isDefault: false });
            await User.findByIdAndUpdate(decoded.id, { defaultAddress: addressId });
        }
        res.json({ success: true, message: "successfully updated" });
    } catch (err) {
        res.json({ success: false, message: "server error" });
    }
}

// ─── Cart Get (with discount calculations) ───────────────
const getCart = async (req, res) => {
    try {
        const { token, page, limit } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const cartItems = await Cart.find({ userId: decoded.id })
            .populate('productId', 'name photos pricePerUnit unit deliveryCategory productCategory brand discount vendorId')
            .limit(parseInt(limit) || 50)
            .skip(((parseInt(page) || 1) - 1) * (parseInt(limit) || 50));

        const formatted = cartItems.map(item => {
            const price = item.productId?.pricePerUnit || 0;
            const discount = item.productId?.discount || 0;
            const effectivePrice = Math.round(Math.max(0, price - (price * discount / 100)));

            return {
                cartId: item._id,
                productId: item.productId?._id,
                name: item.productId?.name,
                image: item.productId?.photos?.[0],
                number: item.number,
                pricePerUnit: effectivePrice,
                originalPrice: price,
                discount: discount,
                unit: item.productId?.unit,
                deliveryCategory: item.productId?.deliveryCategory,
                productCategory: item.productId?.productCategory,
                brandName: item.productId?.brand,
                type: item.type
            };
        });
        res.json({ success: true, message: formatted });
    } catch (err) { res.json({ success: false, message: "server error" }); }
}

// ─── Wishlist ────────────────────────────────────────────
const Wishlist = require('../models/Wishlist.model');

const addToWishlist = async (req, res) => {
    try {
        const { token, productId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const exists = await Wishlist.findOne({ userId: decoded.id, productId });
        if (exists) return res.json({ success: false, message: "already in wishlist" });
        await Wishlist.create({ userId: decoded.id, productId });
        res.json({ success: true, message: "successfully added to cart" });
    } catch (err) { res.json({ success: false, message: "server error" }); }
}

const removeFromWishlist = async (req, res) => {
    try {
        const { token, wishlistId } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        await Wishlist.findOneAndDelete({ _id: wishlistId, userId: decoded.id });
        res.json({ success: true, message: "successfully added to cart" });
    } catch (err) { res.json({ success: false, message: "server error" }); }
}

const getWishlist = async (req, res) => {
    try {
        const { token, page, limit } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const items = await Wishlist.find({ userId: decoded.id })
            .populate('productId', 'name photos pricePerUnit unit deliveryCategory productCategory brand discount')
            .limit(parseInt(limit) || 50)
            .skip(((parseInt(page) || 1) - 1) * (parseInt(limit) || 50));

        const formatted = items.map(item => {
            const price = item.productId?.pricePerUnit || 0;
            const discount = item.productId?.discount || 0;
            const effectivePrice = Math.round(Math.max(0, price - (price * discount / 100)));

            return {
                wishlistId: item._id,
                productId: item.productId?._id,
                name: item.productId?.name,
                image: item.productId?.photos?.[0],
                pricePerUnit: effectivePrice,
                originalPrice: price,
                discount: discount,
                unit: item.productId?.unit,
                deliveryCategory: item.productId?.deliveryCategory,
                productCategory: item.productId?.productCategory,
                brandName: item.productId?.brand
            };
        });
        res.json({ success: true, message: formatted });
    } catch (err) { res.json({ success: false, message: "server error" }); }
}

// ─── Reviews & Ratings & Notifications ───────────────────
const Review = require('../models/Review.model');

const submitReview = async (req, res) => {
    try {
        const { token, comment } = req.body;
        jwt.verify(token, process.env.JWT_SECRET);
        res.json({ success: true, message: "Route reached/Stubbed Review" });
    } catch (err) { res.json({ success: false }); }
}

const rateProduct = async (req, res) => {
    try {
        const { token, "product id": productId, ratting: ratingVal } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        const review = new Review({ reviewerId: decoded.id, entityId: productId, entityModel: 'Product', rating: ratingVal });
        await review.save();
        res.json({ success: true, message: "successfully applied" });
    } catch (err) { res.json({ success: false }); }
}

const rateRider = async (req, res) => {
    try {
        const { token, "rider id": riderId, ratting: ratingVal } = req.body;
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const review = new Review({ reviewerId: decoded.id, entityId: riderId, entityModel: 'Rider', rating: ratingVal });
        await review.save();
        res.json({ success: true, message: "successfully applied" });
    } catch (err) { res.json({ success: false }); }
}

const getUserNotifications = async (req, res) => {
    try {
        const { token } = req.body;
        jwt.verify(token, process.env.JWT_SECRET);
        res.json({ success: true, message: [] });
    } catch (err) { res.json({ success: false }); }
}

const getAllUsers = async (req, res) => {
    try {
        const users = await User.find();
        res.json({ success: true, message: users });
    } catch (err) { res.json({ success: false }); }
}

module.exports = {
    registerUser,
    verifyRegistrationOtp,
    loginUser,
    verifyLoginOtp,
    getUserProfile,
    updateUserProfile,
    deleteUserProfile,
    verifyUserProfileOtp,
    addToCart, removeFromCart, getCart, checkoutCart, getPaymentLink,
    getAllUserOrders, cancelUserOrder, reorderUserOrder, setOrderDeliveredUser,
    getAllAddresses, addUserAddress, deleteUserAddress, updateUserAddress,
    addToWishlist, removeFromWishlist, getWishlist,
    submitReview, rateProduct, rateRider, getUserNotifications, getAllUsers
};
