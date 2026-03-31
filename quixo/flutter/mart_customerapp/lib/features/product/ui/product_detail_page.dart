import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/product/bloc/product_event.dart';
import 'package:quickmartcustomer/features/product/bloc/product_state.dart';
import 'package:quickmartcustomer/features/product/data/product_model.dart';
import 'package:quickmartcustomer/features/product/data/rating_request_model.dart';
import 'package:quickmartcustomer/features/product/data/review_model.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_query_model.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_event.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_state.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  int _ratingStars = 5;
  final _reviewCtrl = TextEditingController();

  final Set<String> _wishlisted = <String>{};

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(
          ProductFetchByIdRequested(widget.productId),
        );
    context.read<WishlistBloc>().add(
          const WishlistFetchRequested(WishlistQueryModel(page: 1, limit: 20)),
        );
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  void _toggleWishlist(ProductModel product) {
    final already = _wishlisted.contains(product.id);
    context.read<WishlistBloc>().add(
          already
              ? WishlistRemoveItemRequested(product.id)
              : WishlistAddItemRequested(product.id),
        );
    setState(() {
      if (already) {
        _wishlisted.remove(product.id);
      } else {
        _wishlisted.add(product.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
      ),
      body: BlocListener<WishlistBloc, WishlistState>(
        listener: (context, state) {
          if (state is WishlistLoaded) {
            _wishlisted
              ..clear()
              ..addAll(state.items.map((e) => e.productId));
          }
        },
        child: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is ProductFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading || state is ProductInitial) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductLoaded) {
                  final p = state.product;
                  return _buildLoaded(p);
                }
                if (state is ProductFailed) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoaded(ProductModel p) {
    final photos = p.photos;
    final wished = _wishlisted.contains(p.id);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  height: 420,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: photos.isNotEmpty
                      ? Image.network(
                          photos.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Center(child: Icon(Icons.broken_image)),
                        )
                      : const Center(child: Icon(Icons.image, size: 80)),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.name,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            )),
                    const SizedBox(height: 8),
                    Text(p.brand,
                        style:
                            TextStyle(color: Colors.grey.shade600, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '₹${p.pricePerUnit} / ${p.unit}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(p.shortDescription),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text('Quantity: ',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _quantity = (_quantity - 1).clamp(1, 999999);
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text('$_quantity',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _quantity = _quantity + 1;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.read<CartBloc>().add(
                                    CartAddRequested(
                                      CartAddRequestModel(
                                        productId: p.id,
                                        number: _quantity,
                                      ),
                                    ),
                                  );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Added to cart')),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart),
                            label: const Text('Add To Cart'),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _toggleWishlist(p),
                          icon: Icon(
                            wished ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),

          // Reviews placeholder + add review form
          const Text('Reviews', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          const Text('No review list is returned by current product API; you can add one below.'),
          const SizedBox(height: 24),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _ratingStars,
                    items: const [1, 2, 3, 4, 5]
                        .map((s) => DropdownMenuItem(value: s, child: Text('$s stars')))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _ratingStars = v);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Rating',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final msg = _reviewCtrl.text.trim();
                        if (msg.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter review message')),
                          );
                          return;
                        }

                        context.read<ProductBloc>().add(
                              ProductAddReviewRequested(
                                ReviewRequestModel(
                                  productId: p.id,
                                  message: msg,
                                ),
                              ),
                            );
                        context.read<ProductBloc>().add(
                              ProductAddRatingRequested(
                                RatingRequestModel(
                                  productId: p.id,
                                  rating: _ratingStars.toDouble(),
                                ),
                              ),
                            );
                        _reviewCtrl.clear();
                      },
                      child: const Text('Add Review'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

