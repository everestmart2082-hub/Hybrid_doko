import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/cart/data/cart_query_model.dart';
import 'package:quickmartcustomer/features/product/ui/product_detail_page.dart';
import '../bloc/cart_bloc.dart';
import '../bloc/cart_event.dart';
import '../bloc/cart_state.dart';
import '../data/cart_item_model.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(CartFetchRequested(CartQueryModel(page: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: BlocConsumer<CartBloc, CartState>(
        listener: (context, state) {
          if (state is CartActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh cart
            context.read<CartBloc>().add(CartFetchRequested(CartQueryModel(page: currentPage)));
          }

          if (state is CartFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CartFailed) {
            return Center(child: Text(state.message));
          }

          if (state is CartLoaded) {
            final cartItems = state.items;
            if (cartItems.isEmpty) {
              return const Center(child: Text("Your cart is empty"));
            }

            double total = cartItems.fold(
                0, (sum, item) => sum + (item.pricePerUnit * item.number));

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(context, item);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  color: theme.cardColor,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Total: Rs. $total",
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          // Add to order event
                          Navigator.pushNamed(context, "/payment");
                        },
                        child: const Text("Add to Order"),
                      )
                    ],
                  ),
                )
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ================= IMAGE =================
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(productId: item.productId),
                  ),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(item.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ================= INFO + QUANTITY =================
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailPage(productId: item.productId),
                        ),
                      );
                    },
                    child: Text(item.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                  ),
                  Text("Brand: ${item.brandName}", style: theme.textTheme.bodyMedium),
                  Text("Price: Rs. ${item.pricePerUnit}"),
                  Text("Unit: ${item.unit}"),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: item.number > 1
                            ? () {
                                context.read<CartBloc>().add(
                                CartRemoveRequested(item.id));
                              }
                            : null,
                      ),
                      Text(item.number.toString(),
                          style: theme.textTheme.titleMedium),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          context.read<CartBloc>().add(
                              CartAddRequested(CartAddRequestModel(productId: item.productId, number: item.number+1)));
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent),
                        onPressed: () {
                          context
                              .read<CartBloc>()
                              .add(CartRemoveRequested(item.productId));
                        },
                        child: const Text("Remove"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}