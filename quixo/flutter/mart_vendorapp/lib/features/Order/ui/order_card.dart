import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../data/order_model.dart';

class OrderCard extends StatelessWidget {

  final VendorOrder order;

  const OrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),

      child: Padding(
        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Order #${order.orderId}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text("Status: ${order.orderStatus}"),

            Text("Product Category: ${order.productCategory}"),

            Text("Delivery: ${order.deliveryCategory}"),

            Text("Order Time: ${order.orderTime}"),

            const Divider(),

            Text("Product Quantity: ${order.productNumber}"),

            Text("Rider: ${order.riderName}"),

            Text("Rider Phone: ${order.riderNumber}"),

            const SizedBox(height: 10),

            if (order.orderStatus == "pending")

              Align(
                alignment: Alignment.centerRight,

                child: ElevatedButton(

                  onPressed: () {

                    context.read<OrderBloc>().add(
                      PrepareOrder(order.orderId),
                    );

                  },

                  child: const Text("Mark Prepared"),
                ),
              )
          ],
        ),
      ),
    );
  }
}