const mongoose = require('mongoose');

const adminSchema = new mongoose.Schema({
    name: { type: String, required: true },
    phone: { type: String, required: true, unique: true },
    email: { type: String },
    companyRegistrationCertificateOcr: { type: String },
    panVatCertificate: { type: String },
    businessRegistrationLicense: { type: String },
    ecommerceListing: { type: String },
    moaAoaPromotersCitizenship: { type: String },
    employeeRegistrationPan: { type: String },
    vendorRegistrationPan: { type: String },
    sharePaper: { type: String },
    aomMom: { type: String },
    certificates: [{ type: String }],
    otp: { type: String },
}, { timestamps: true });

module.exports = mongoose.model('Admin', adminSchema);
