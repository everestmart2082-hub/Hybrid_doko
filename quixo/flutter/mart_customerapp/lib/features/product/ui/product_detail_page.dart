import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/constants/api_constants.dart';

import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/product/bloc/product_event.dart';
import 'package:quickmartcustomer/features/product/bloc/product_state.dart';
import 'package:quickmartcustomer/features/product/data/product_model.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_query_model.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_event.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_state.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

String? _absolutePhotoUrl(String path) {
  final t = path.trim();
  if (t.isEmpty) return null;
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  final p = t.startsWith('/') ? t : '/$t';
  return '${ApiEndpoints.baseImageUrl}$p';
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _quantity = 1;
  int _ratingStars = 5;
  int _selectedPhotoIndex = 0;
  final _reviewCtrl = TextEditingController();

  final Set<String> _wishlisted = <String>{};
  ProductModel? _lastGoodProduct;
  bool _awaitingReviewThankYou = false;

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
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Product Details',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).primaryColorLight),
        ),
        actions: [
          CustomerHubBarIcons(
            leading: [
              BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  final ProductModel? p = state is ProductLoaded
                      ? state.product
                      : _lastGoodProduct;
                  if (p == null) return const SizedBox.shrink();
                  final wished = _wishlisted.contains(p.id);
                  return IconButton(
                    tooltip:
                        wished ? 'Remove from wishlist' : 'Add to wishlist',
                    onPressed: () => _toggleWishlist(p),
                    icon: Icon(
                      wished ? Icons.favorite : Icons.favorite_border,
                      color: Theme.of(context).primaryColorLight,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      // drawer: buildAppDrawer(context),
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
            if (state is ProductLoaded) {
              if (_awaitingReviewThankYou) {
                _awaitingReviewThankYou = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Review submitted')),
                );
              }
            } else if (state is ProductFailed) {
              if (_lastGoodProduct != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
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
                  _lastGoodProduct = state.product;
                  return _buildLoaded(state.product);
                }
                if (state is ProductFailed) {
                  final fallback = _lastGoodProduct;
                  if (fallback != null) {
                    return _buildLoaded(fallback);
                  }
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
    if (photos.isNotEmpty && _selectedPhotoIndex >= photos.length) {
      _selectedPhotoIndex = 0;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Container(
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: photos.isNotEmpty
                          ? Image.network(
                              _absolutePhotoUrl(photos[_selectedPhotoIndex]) ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const Center(child: Icon(Icons.broken_image)),
                            )
                          : const Center(child: Icon(Icons.image, size: 80)),
                    ),
                    if (photos.length > 1) ...[
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: photos.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final thumbUrl = _absolutePhotoUrl(photos[index]) ?? '';
                            final selected = index == _selectedPhotoIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedPhotoIndex = index),
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: selected
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade300,
                                    width: selected ? 2 : 1,
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Image.network(
                                  thumbUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      p.brand,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (p.discount > 0) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹${(p.pricePerUnit * (1 - p.discount / 100)).toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '₹${p.pricePerUnit.toStringAsFixed(2)}',
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Chip(
                            label: Text('${p.discount.toStringAsFixed(0)}% OFF'),
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      Text(
                        'per ${p.unit}',
                        style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      ),
                    ] else
                      Text(
                        '₹${p.pricePerUnit} / ${p.unit}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.shortDescription.isNotEmpty
                          ? p.shortDescription
                          : '—',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Description',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      p.description.isNotEmpty ? p.description : '—',
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          'Quantity: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _quantity = (_quantity - 1).clamp(1, 999999);
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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

          const Text(
            'Reviews',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (p.reviews.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'No reviews yet. Be the first to leave one.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            )
          else
            ...p.reviews.map(
              (r) => Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    r.userName.isNotEmpty ? r.userName : 'Customer',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (r.dateStr.isNotEmpty)
                        Text(
                          r.dateStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 6),
                      Text(r.message),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Share your rating and a short comment.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add Review',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _reviewCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Rating',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      ...List.generate(5, (i) {
                        final n = i + 1;
                        final filled = n <= _ratingStars;
                        return IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          icon: Icon(
                            filled ? Icons.star : Icons.star_border,
                            color: Colors.amber.shade700,
                            size: 32,
                          ),
                          onPressed: () => setState(() => _ratingStars = n),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final msg = _reviewCtrl.text.trim();
                        if (msg.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please enter review message'),
                            ),
                          );
                          return;
                        }

                        setState(() => _awaitingReviewThankYou = true);
                        context.read<ProductBloc>().add(
                          ProductSubmitReviewRequested(
                            productId: p.id,
                            message: msg,
                            ratingStars: _ratingStars,
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
