const PDFDocument = require('pdfkit');

exports.generateInvoice = (order) => new Promise((resolve, reject) => {
  const doc    = new PDFDocument();
  const chunks = [];
  doc.on('data',  (c) => chunks.push(c));
  doc.on('end',   ()  => resolve(Buffer.concat(chunks)));
  doc.on('error', reject);
  doc.fontSize(20).text('Quixo Invoice', { align: 'center' });
  doc.moveDown();
  doc.fontSize(12).text(`Order ID: ${order._id}`);
  doc.text(`Customer: ${order.customerId}`);
  doc.text(`Subtotal: NPR ${order.subTotal}`);
  doc.text(`VAT (13%): NPR ${order.vat}`);
  doc.text(`Delivery: NPR ${order.deliveryCharge}`);
  doc.text(`Total: NPR ${order.total}`);
  doc.end();
});