const { validationResult } = require('express-validator');

/**
 * Middleware to check express-validator results.
 * Use AFTER validator arrays in the route chain:
 *   router.post('/', registerValidator, validate, ctrl.register)
 *
 * Or simply add this as a middleware factory that wraps validators.
 */
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            success: false,
            message: 'Validation failed',
            errors: errors.array().map(e => ({ field: e.path, message: e.msg }))
        });
    }
    next();
};

module.exports = { validate };
