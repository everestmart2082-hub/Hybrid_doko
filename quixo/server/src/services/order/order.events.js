const { publish }          = require('../../events/publisher');
const { pushOrderUpdate }  = require('../../realtime/orderSocket');
const { pushNewOrder }     = require('../../realtime/riderSocket');
const { pushOTPEvent }     = require('../../realtime/otpSocket');
const EVENTS               = require('../../events/eventTypes');

exports.onOrderPlaced = async (order) => {
  await publish(EVENTS.ORDER_PLACED, order);
  pushOrderUpdate(order._id, { status: 'pending' });
};

exports.onRiderAssigned = async (order, riderId) => {
  await publish(EVENTS.RIDER_ASSIGNED, { orderId: order._id, riderId });
  pushNewOrder(riderId, order);
};

exports.onOrderDelivered = async (order) => {
  await publish(EVENTS.ORDER_DELIVERED, order);
  pushOTPEvent(order.customerId, order.deliveryOTP);
};