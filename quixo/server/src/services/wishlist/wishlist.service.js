const Wishlist = require('./wishlist.model');

exports.get = async (userId) => {
    let wishlist = await Wishlist.findOne({ userId }).populate('products');
    if (!wishlist) wishlist = await Wishlist.create({ userId, products: [] });
    return wishlist;
};

exports.addProduct = async (userId, productId) => {
    let wishlist = await Wishlist.findOne({ userId });
    if (!wishlist) wishlist = await Wishlist.create({ userId, products: [] });

    if (!wishlist.products.includes(productId)) {
        wishlist.products.push(productId);
        await wishlist.save();
    }
    return wishlist.populate('products');
};

exports.removeProduct = async (userId, productId) => {
    const wishlist = await Wishlist.findOne({ userId });
    if (!wishlist) throw Object.assign(new Error('Wishlist not found'), { statusCode: 404 });

    wishlist.products = wishlist.products.filter(id => id.toString() !== productId);
    await wishlist.save();
    return wishlist.populate('products');
};
