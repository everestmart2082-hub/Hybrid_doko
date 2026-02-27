const { body } = require('express-validator');
exports.orderValidator = [
  body('items').isArray({ min: 1 }).withMessage('At least one item is required'),
  body('items.*.productId').notEmpty().withMessage('Product ID is required'),
  body('items.*.qty').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('address').notEmpty().withMessage('Delivery address is required'),
  body('address.address').notEmpty().withMessage('Street address is required'),
  body('paymentMethod').isIn(['khalti', 'esewa', 'fonepay', 'cashOnDelivery']).withMessage('Invalid payment method'),
  body('deliveryType').isIn(['quick', 'ecommerce']).withMessage('Delivery type must be quick or ecommerce'),
];