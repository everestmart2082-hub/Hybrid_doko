const Cart = require('./cart.model');
const Product = require('../product/product.model');

/**
 * Get the user's cart, auto-create if doesn't exist.
 */
exports.getByUser = async (userId) => {
    let cart = await Cart.findOne({ userId }).populate('items.productId', 'name price images stock deliveryType');
    if (!cart) cart = await Cart.create({ userId, items: [] });
    return cart;
};

/**
 * Add a product to cart (or increment qty if already exists).
 */
exports.addItem = async (userId, productId, quantity = 1) => {
    const product = await Product.findById(productId);
    if (!product) throw Object.assign(new Error('Product not found'), { statusCode: 404 });
    if (product.stock < quantity) throw Object.assign(new Error('Insufficient stock'), { statusCode: 400 });

    let cart = await Cart.findOne({ userId });
    if (!cart) cart = await Cart.create({ userId, items: [] });

    const existingIdx = cart.items.findIndex(i => i.productId.toString() === productId);

    if (existingIdx > -1) {
        cart.items[existingIdx].qty += quantity;
    } else {
        cart.items.push({
            productId,
            name: product.name,
            image: product.images?.[0] || '',
            price: product.price - (product.price * product.discount / 100),
            qty: quantity,
            type: product.deliveryType
        });
    }

    return cart.save();
};

/**
 * Update quantity of a specific cart item.
 */
exports.updateItem = async (userId, itemId, qty) => {
    const cart = await Cart.findOne({ userId });
    if (!cart) throw Object.assign(new Error('Cart not found'), { statusCode: 404 });
    const item = cart.items.id(itemId);
    if (!item) throw Object.assign(new Error('Item not found in cart'), { statusCode: 404 });
    item.qty = Math.max(1, qty);
    return cart.save();
};

/**
 * Remove a specific item from the cart.
 */
exports.removeItem = async (userId, itemId) => {
    const cart = await Cart.findOne({ userId });
    if (!cart) throw Object.assign(new Error('Cart not found'), { statusCode: 404 });
    cart.items = cart.items.filter(i => i._id.toString() !== itemId);
    return cart.save();
};

/**
 * Clear the entire cart.
 */
exports.clear = async (userId) => {
    const cart = await Cart.findOne({ userId });
    if (!cart) return;
    cart.items = [];
    return cart.save();
};
