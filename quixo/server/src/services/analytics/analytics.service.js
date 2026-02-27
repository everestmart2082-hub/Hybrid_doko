const Order = require('../order/order.model');
const Product = require('../product/product.model');
const User = require('../auth/auth.model');
const Vendor = require('../vendor/vendor.model');
const Payment = require('../payment/payment.model');

/**
 * Admin dashboard overview
 */
exports.getDashboard = async () => {
  const [totalUsers, totalVendors, totalProducts, totalOrders, revenue] = await Promise.all([
    User.countDocuments({ role: 'customer' }),
    Vendor.countDocuments(),
    Product.countDocuments({ isApproved: true, isHidden: false }),
    Order.countDocuments(),
    Order.aggregate([
      { $match: { status: 'delivered' } },
      { $group: { _id: null, total: { $sum: '$total' } } }
    ])
  ]);

  return {
    totalUsers,
    totalVendors,
    totalProducts,
    totalOrders,
    totalRevenue: revenue[0]?.total || 0,
  };
};

/**
 * Sales over time — daily aggregation for a given date range.
 * Defaults to last 30 days.
 */
exports.getSalesOverTime = async (query = {}) => {
  const days = parseInt(query.days) || 30;
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - days);

  const sales = await Order.aggregate([
    { $match: { createdAt: { $gte: startDate }, status: { $ne: 'cancelled' } } },
    {
      $group: {
        _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
        orders: { $sum: 1 },
        revenue: { $sum: '$total' },
      }
    },
    { $sort: { _id: 1 } }
  ]);

  return sales;
};

/**
 * Top selling products
 */
exports.getTopProducts = async (query = {}) => {
  const limit = parseInt(query.limit) || 10;

  const products = await Order.aggregate([
    { $match: { status: 'delivered' } },
    { $unwind: '$items' },
    {
      $group: {
        _id: '$items.productId',
        name: { $first: '$items.name' },
        totalSold: { $sum: '$items.qty' },
        totalRevenue: { $sum: { $multiply: ['$items.price', '$items.qty'] } },
      }
    },
    { $sort: { totalSold: -1 } },
    { $limit: limit }
  ]);

  return products;
};

/**
 * Order status distribution
 */
exports.getOrderStats = async () => {
  const stats = await Order.aggregate([
    { $group: { _id: '$status', count: { $sum: 1 } } },
    { $sort: { count: -1 } }
  ]);

  return stats.reduce((acc, s) => { acc[s._id] = s.count; return acc; }, {});
};

/**
 * Revenue by vendor (top vendors)
 */
exports.getRevenueByVendor = async (query = {}) => {
  const limit = parseInt(query.limit) || 10;

  const vendors = await Order.aggregate([
    { $match: { status: 'delivered' } },
    {
      $group: {
        _id: '$vendorId',
        totalOrders: { $sum: 1 },
        totalRevenue: { $sum: '$total' },
      }
    },
    { $sort: { totalRevenue: -1 } },
    { $limit: limit },
    {
      $lookup: {
        from: 'vendors',
        localField: '_id',
        foreignField: '_id',
        as: 'vendor'
      }
    },
    { $unwind: { path: '$vendor', preserveNullAndEmptyArrays: true } },
    {
      $project: {
        vendorId: '$_id',
        storeName: '$vendor.storeName',
        totalOrders: 1,
        totalRevenue: 1,
      }
    }
  ]);

  return vendors;
};

/**
 * Payment method distribution
 */
exports.getPaymentStats = async () => {
  const stats = await Order.aggregate([
    { $group: { _id: '$paymentMethod', count: { $sum: 1 }, total: { $sum: '$total' } } },
    { $sort: { count: -1 } }
  ]);

  return stats;
};
