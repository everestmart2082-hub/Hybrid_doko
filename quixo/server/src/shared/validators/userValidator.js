const { body } = require('express-validator');
exports.registerValidator = [
  body('name').notEmpty().withMessage('Name required'),
  body('email').isEmail().withMessage('Valid email required'),
  body('phone').isMobilePhone().withMessage('Valid phone required'),
  body('password').isLength({ min: 6 }).withMessage('Min 6 chars'),
];