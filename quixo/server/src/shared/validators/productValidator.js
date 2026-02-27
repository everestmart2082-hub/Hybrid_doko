const { body } = require('express-validator');
exports.productValidator = [
  body('name').notEmpty().withMessage('Product name is required'),
  body('price').isNumeric().withMessage('Price must be a number'),
  body('category').notEmpty().withMessage('Category is required'),
  body('deliveryType').isIn(['quick', 'ecommerce']).withMessage('Delivery type must be quick or ecommerce'),
  body('stock').isInt({ min: 0 }).withMessage('Stock must be a non-negative integer'),
  body('description').optional().isString(),
  body('discount').optional().isFloat({ min: 0, max: 100 }).withMessage('Discount must be 0-100'),
];