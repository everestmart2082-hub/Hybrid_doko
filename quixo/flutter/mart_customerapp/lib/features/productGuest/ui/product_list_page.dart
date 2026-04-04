import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_state.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/productGuest/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/productGuest/bloc/product_event.dart';
import 'package:quickmartcustomer/features/productGuest/bloc/product_state.dart';
import 'package:quickmartcustomer/features/productGuest/data/product_list_item_model.dart';

class ProductGuestListPage extends StatefulWidget {
  const ProductGuestListPage({super.key});

  @override
  State<ProductGuestListPage> createState() => _ProductGuestListPageState();
}

class _ProductGuestListPageState extends State<ProductGuestListPage> {
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductGuestBloc>().add(ProductFetchAll(page: 1, limit: 20));
  }

  bool _isLoggedIn(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated && state.authenticated;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text('Products', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight)),
        elevation: 1,
      ),
      drawer: null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocBuilder<ProductGuestBloc, ProductGuestState>(
          builder: (context, state) {
            if (state is ProductLoading || state is ProductInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProductListLoaded) {
              final products = state.products;
              return Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 280,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        mainAxisExtent: 360,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final p = products[index];
                        return _buildProductCard(p);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() => _currentPage--);
                                  context.read<ProductGuestBloc>().add(
                                      ProductFetchAll(
                                          page: _currentPage, limit: 20));
                                }
                              : null,
                          child: const Text('Prev'),
                        ),
                        Text('Page $_currentPage'),
                        TextButton(
                          onPressed: () {
                            setState(() => _currentPage++);
                            context.read<ProductGuestBloc>().add(
                                ProductFetchAll(
                                    page: _currentPage, limit: 20));
                          },
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            if (state is ProductFailed) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductListItem p) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              p.images.isNotEmpty
                  ? Image.network(
                      p.images.first,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 160,
                      width: double.infinity,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image, size: 50),
                    ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(p.brandName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 8),
                Text('₹${p.pricePerUnit}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (!_isLoggedIn(context)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please login to add to cart')),
                        );
                        Navigator.pushNamed(context, '/login');
                        return;
                      }
                      context.read<CartBloc>().add(
                            CartAddRequested(
                              CartAddRequestModel(productId: p.id, number: 1),
                            ),
                          );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to Cart!')),
                      );
                    },
                    child: const Text('Add To Cart'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/product-detail',
                      arguments: p.id,
                    ),
                    child: const Text('View details'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

