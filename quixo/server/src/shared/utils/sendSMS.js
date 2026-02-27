const axios = require('axios');

exports.sendSMS = async (phone, message) => {
  try {
    await axios.post('https://apisms.sparrowsms.com/v2/sms/', {
      token:  process.env.SPARROW_SMS_TOKEN,
      from:   'Quixo',
      to:     phone,
      text:   message,
    });
  } catch (err) {
    console.error('SMS error:', err.message);
  }
};