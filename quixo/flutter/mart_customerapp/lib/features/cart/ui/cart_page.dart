import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_state.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/cart/data/cart_query_model.dart';
import 'package:quickmartcustomer/features/cart/data/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(const CartFetchRequested(CartQueryModel()));
  }

  bool _isQuick(CartItemModel item) {
    final s = item.deliveryCategory.toLowerCase();
    return s.contains('quick');
  }

  void _updateQty(CartItemModel item, int newQty) {
    // We don't have a dedicated update endpoint in the BLoC; we remove and re-add.
    context.read<CartBloc>().add(CartRemoveRequested(item.id));
    if (newQty > 0) {
      context.read<CartBloc>().add(
            CartAddRequested(
              CartAddRequestModel(productId: item.productId, number: newQty),
            ),
          );
    }
    // Refresh after a short delay to allow in-flight events.
    Future.delayed(const Duration(milliseconds: 300), () {
      context.read<CartBloc>().add(const CartFetchRequested(CartQueryModel()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: BlocListener<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartFailed) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is CartActionSuccess) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoading || state is CartInitial) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is CartLoaded) {
                final quick = state.items.where(_isQuick).toList();
                final normal = state.items.where((e) => !_isQuick(e)).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Quick Products', quick),
                    const SizedBox(height: 24),
                    _buildSection('Normal Products', normal),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/payment'),
                            child: const Text('Checkout'),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
              if (state is CartFailed) {
                return Center(child: Text(state.message));
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<CartItemModel> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        if (items.isEmpty)
          const Text('No items')
        else
          Column(
            children: items.map((item) => _buildCartRow(item)).toList(),
          ),
      ],
    );
  }

  Widget _buildCartRow(CartItemModel item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 90,
              child: item.image.isNotEmpty
                  ? Image.network(item.image, fit: BoxFit.cover)
                  : const Placeholder(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 6),
                  Text(item.brandName),
                  const SizedBox(height: 6),
                  Text('Price: ${item.pricePerUnit} / ${item.unit}'),
                  const SizedBox(height: 8),
                  Text('Total: ${(item.pricePerUnit * item.number).toStringAsFixed(2)}'),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      tooltip: 'Decrease',
                      onPressed: () {
                        final newQty = (item.number - 1).clamp(0, 999999);
                        _updateQty(item, newQty);
                      },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${item.number}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      tooltip: 'Increase',
                      onPressed: () {
                        _updateQty(item, item.number + 1);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    _updateQty(item, 0);
                  },
                  child: const Text('Remove From Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

