import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/addresss/data/address_model.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_state.dart';
import '../bloc/payment_bloc.dart';
import '../bloc/payment_event.dart';
import '../bloc/payment_state.dart';
import '../data/checkout_request_model.dart';

class PaymentPage extends StatefulWidget {
  final AddressModel selectedAddress;

  const PaymentPage({super.key, required this.selectedAddress});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String selectedPaymentMethod = "cash";

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Payment")),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is PaymentFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final loading = state is PaymentLoading;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // ================= PAYMENT METHOD =================
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  decoration: const InputDecoration(labelText: "Payment Method"),
                  items: const [
                    DropdownMenuItem(value: "cash", child: Text("Cash on Delivery")),
                    DropdownMenuItem(value: "card", child: Text("Credit/Debit Card")),
                    DropdownMenuItem(value: "upi", child: Text("UPI")),
                  ],
                  onChanged: (v) => setState(() => selectedPaymentMethod = v!),
                ),
                const SizedBox(height: 16),

                // ================= PLACE ORDER BUTTON =================
                BlocBuilder<CartBloc, CartState>(
                  builder: (context, cartState) {
                    if (cartState is CartLoaded && cartState.items.isNotEmpty) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: loading
                              ? null
                              : () {
                                  final request = CheckoutRequestModel(
                                    addressId: widget.selectedAddress.id,
                                    cartIds: cartState.items
                                        .map((e) => e.productId)
                                        .toList(),
                                    paymentMethod: selectedPaymentMethod,
                                  );

                                  context
                                      .read<PaymentBloc>()
                                      .add(CheckoutRequested(request));
                                },
                          child: loading
                              ? const CircularProgressIndicator()
                              : const Text("Pay Now"),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),

                const SizedBox(height: 16),

                // ================= GO TO HOME AFTER PAYMENT =================
                if (state is PaymentSuccess)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: const Text("Go to Homepage"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}