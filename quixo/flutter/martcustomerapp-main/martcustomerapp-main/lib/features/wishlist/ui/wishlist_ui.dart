import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/product/ui/product_detail_page.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_model.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_query_model.dart';
import '../bloc/wishlist_bloc.dart';
import '../bloc/wishlist_event.dart';
import '../bloc/wishlist_state.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  void _fetchWishlist() {
    context.read<WishlistBloc>().add(WishlistFetchRequested(WishlistQueryModel(page: currentPage)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Wishlist")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(12),
        child: BlocConsumer<WishlistBloc, WishlistState>(
          listener: (context, state) {
            if (state is WishlistActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              _fetchWishlist();
            }
            if (state is WishlistFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is WishlistLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is WishlistFailed) {
              return Center(
                  child: Text(state.message, style: theme.textTheme.bodyLarge));
            }

            if (state is WishlistLoaded) {
              final items = state.items;
              if (items.isEmpty) {
                return const Center(child: Text("No items in wishlist"));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _buildWishlistCard(context, item);
                },
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildWishlistCard(BuildContext context, WishlistItemModel item) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailPage(productId: item.productId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              Container(
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
              const SizedBox(width: 12),

              // Info + Buttons
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text("Brand: ${item.brandName}",
                        style: theme.textTheme.bodyMedium),
                    Text("Price: Rs. ${item.pricePerUnit}",
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    Text("Unit: ${item.unit}"),
                    Text("Delivery: ${item.deliveryCategory}"),
                    Text("Category: ${item.productCategory}"),
                    const SizedBox(height: 8),

                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<WishlistBloc>().add(
                                  WishlistRemoveItemRequested(item.productId),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          child: const Text("Remove"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            context.read<WishlistBloc>().add(
                                  WishlistAddItemRequested(
                                      item.productId),
                                );
                          },
                          child: const Text("Add to Cart"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}