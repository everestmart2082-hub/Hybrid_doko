const axios = require('axios');

exports.initiateEsewa = (order) => {
  const clientUrl = process.env.CLIENT_URL || 'http://localhost:3000';
  const params = new URLSearchParams({
    amt: order.subTotal,
    txAmt: 0,
    psc: 0,
    pdc: order.deliveryCharge,
    tAmt: order.total,
    pid: order._id.toString(),
    scd: process.env.ESEWA_MERCHANT_ID,
    su: `${clientUrl}/payment/success`,
    fu: `${clientUrl}/payment/failed`,
  });
  return `https://uat.esewa.com.np/epay/main?${params.toString()}`;
};

exports.verifyEsewa = async (oid, amt) => {
  const res = await axios.post('https://uat.esewa.com.np/epay/transrec', null, {
    params: { amt, rid: '', pid: oid, scd: process.env.ESEWA_MERCHANT_ID }
  });
  return res.data.includes('Success');
};