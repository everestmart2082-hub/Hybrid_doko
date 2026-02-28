const mongoose = require('mongoose');

const categorySchema = new mongoose.Schema({
    name: { type: String, required: true },
    type: { type: String, enum: ['quick', 'normal', '1 dAY'] },
    requiredCriteria: [{
        name: { type: String },
        description: { type: String }
    }],
    others: [{
        name: { type: String },
        description: { type: String }
    }]
}, { timestamps: true });

module.exports = mongoose.model('Category', categorySchema);
