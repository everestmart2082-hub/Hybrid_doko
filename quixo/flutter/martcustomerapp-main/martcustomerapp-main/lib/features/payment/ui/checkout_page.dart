import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_bloc.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_event.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_state.dart';
import 'package:quickmartcustomer/features/addresss/data/address_model.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_state.dart';
import 'package:quickmartcustomer/features/cart/data/cart_item_model.dart';
import 'package:quickmartcustomer/features/cart/data/cart_query_model.dart';
import 'payment_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  AddressModel? selectedAddress;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartFetchRequested(CartQueryModel(page: 1)));
    context.read<AddressBloc>().add(const AddressFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<CartBloc, CartState>(
              builder: (context, cartState) {
                if (cartState is CartLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (cartState is CartLoaded) {
                  final items = cartState.items;
                  if (items.isEmpty) return const Center(child: Text("Cart is empty"));

                  double total = items.fold(
                      0, (sum, item) => sum + (item.pricePerUnit * item.number));

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              _buildCartItem(items[index]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          "Total: Rs. $total",
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  );
                }

                return const SizedBox();
              },
            ),
          ),

          // ================= SELECT ADDRESS =================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: BlocBuilder<AddressBloc, AddressState>(
              builder: (context, state) {
                if (state is AddressLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is AddressLoaded) {
                  final addresses = state.addresses;
                  if (addresses.isEmpty) return const Text("No address found");

                  return DropdownButtonFormField<AddressModel>(
                    value: selectedAddress ?? addresses.first,
                    decoration: const InputDecoration(labelText: "Select Address"),
                    items: addresses
                        .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text("${a.label} - ${a.city}"),
                            ))
                        .toList(),
                    onChanged: (a) => setState(() => selectedAddress = a),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedAddress == null
                    ? null
                    : () {
                        // Navigate to payment page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                PaymentPage(selectedAddress: selectedAddress!),
                          ),
                        );
                      },
                child: const Text("Proceed to Payment"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text("${item.number} x Rs. ${item.pricePerUnit}"),
      trailing: Text("Rs. ${item.pricePerUnit * item.number}"),
    );
  }
}