import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_state.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/product/bloc/product_event.dart';
import 'package:quickmartcustomer/features/product/bloc/product_state.dart';
import 'package:quickmartcustomer/features/product/data/product_list_item_model.dart';
import 'package:quickmartcustomer/features/product/data/product_query.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_event.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_state.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_query_model.dart';
import 'package:quickmartcustomer/drawer.dart';
import 'package:quickmartcustomer/core/constants/api_constants.dart';

String? _absolutePhotoUrl(String path) {
  final t = path.trim();
  if (t.isEmpty) return null;
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  final p = t.startsWith('/') ? t : '/$t';
  return '${ApiEndpoints.baseImageUrl}$p';
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _currentPage = 1;

  final _searchCtrl = TextEditingController();
  final _minPriceCtrl = TextEditingController();
  final _maxPriceCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  String _stockMode = '';
  String _sortBy = 'default';
  String _selectedCategory = '';
  String _selectedDeliveryCategory = '';
  List<Map<String, dynamic>> _categories = const [];

  // Wishlist cache for quick toggle UI.
  final Set<String> _wishlistedProductIds = <String>{};

  @override
  void initState() {
    super.initState();
    _fetchDefault();
    _fetchWishlist();
    _loadCategories();
  }

  void _fetchDefault() {
    context.read<ProductBloc>().add(const ProductFetchAll(page: 1, limit: 20));
  }

  void _fetchWishlist() {
    context.read<WishlistBloc>().add(
      const WishlistFetchRequested(WishlistQueryModel()),
    );
  }

  Future<void> _loadCategories() async {
    try {
      final data = await context
          .read<ProductBloc>()
          .productRemote
          .getCategories();
      if (!mounted) return;
      setState(() => _categories = data);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minPriceCtrl.dispose();
    _maxPriceCtrl.dispose();
    _brandCtrl.dispose();
    super.dispose();
  }

  double? _tryParseDouble(String s) {
    final v = s.trim();
    if (v.isEmpty) return null;
    return double.tryParse(v);
  }

  void _applyFilters() {
    final query = ProductQuery(
      page: _currentPage,
      limit: 20,
      search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      minPrice: _tryParseDouble(_minPriceCtrl.text),
      maxPrice: _tryParseDouble(_maxPriceCtrl.text),
      brand: _brandCtrl.text.trim().isEmpty ? null : _brandCtrl.text.trim(),
      inStock: _stockMode == 'in_stock'
          ? true
          : (_stockMode == 'out_of_stock' ? false : null),
      sort: _sortBy == 'default' ? null : _sortBy,
      category: _selectedCategory.isEmpty ? null : _selectedCategory,
      deliveryCategory: _selectedDeliveryCategory.isEmpty
          ? null
          : _selectedDeliveryCategory,
    );

    context.read<ProductBloc>().add(ProductFetchRequested(query));
  }

  bool _isLoggedIn(BuildContext context) {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated && state.authenticated;
  }

  void _toggleWishlist(ProductListItem p) {
    final productId = p.id;
    final already = _wishlistedProductIds.contains(productId);

    if (!_isLoggedIn(context)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to use wishlist')),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }

    context.read<WishlistBloc>().add(
      already
          ? WishlistRemoveItemRequested(productId)
          : WishlistAddItemRequested(productId),
    );
    // Optimistic UI; if backend rejects, user can refresh.
    setState(() {
      if (already) {
        _wishlistedProductIds.remove(productId);
      } else {
        _wishlistedProductIds.add(productId);
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
          'Products',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        elevation: 1,
      ),
      drawer: buildAppDrawer(context),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sidebar Filter
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sort By',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _sortBy,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items:
                          [
                                'default',
                                'price low to high',
                                'price high to low',
                                'rating',
                                'discount',
                                'newest',
                                'oldest',
                              ]
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                      onChanged: (v) =>
                          setState(() => _sortBy = v ?? 'default'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'search',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(width: 1.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'price range',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _minPriceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Min price',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _maxPriceCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Max price',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'brand',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _brandCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Brand',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'product category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: [
                        const DropdownMenuItem(value: '', child: Text('All')),
                        ..._categories.map((c) {
                          final id = c['_id'];
                          final idStr = id is Map
                              ? (id[r'$oid']?.toString() ?? '')
                              : id?.toString() ?? '';
                          final name = c['name']?.toString() ?? idStr;
                          return DropdownMenuItem(
                            value: idStr,
                            child: Text(name),
                          );
                        }),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedCategory = v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'delivery category',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedDeliveryCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('All')),
                        DropdownMenuItem(value: 'quick', child: Text('Quick')),
                        DropdownMenuItem(
                          value: 'normal',
                          child: Text('Normal'),
                        ),
                      ],
                      onChanged: (v) =>
                          setState(() => _selectedDeliveryCategory = v ?? ''),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'stock',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _stockMode,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: const [
                        DropdownMenuItem(value: '', child: Text('Any')),
                        DropdownMenuItem(
                          value: 'in_stock',
                          child: Text('In stock'),
                        ),
                        DropdownMenuItem(
                          value: 'out_of_stock',
                          child: Text('Out of stock'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _stockMode = v ?? ''),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply Filter'),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        TextButton(
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() => _currentPage--);
                                  _applyFilters();
                                }
                              : null,
                          child: const Text('Prev'),
                        ),
                        Text('Page $_currentPage'),
                        TextButton(
                          onPressed: () {
                            setState(() => _currentPage++);
                            _applyFilters();
                          },
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right Body (Product Grid)
          Expanded(
            flex: 8,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BlocConsumer<WishlistBloc, WishlistState>(
                listener: (context, state) {
                  if (state is WishlistLoaded) {
                    _wishlistedProductIds
                      ..clear()
                      ..addAll(state.items.map((e) => e.productId));
                  }
                },
                builder: (context, wishlistState) {
                  return BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, productState) {
                      if (productState is ProductLoading ||
                          productState is ProductInitial) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (productState is ProductListLoaded) {
                        final products = productState.products;
                        return GridView.builder(
                          padding: const EdgeInsets.all(8),
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
                            final wished = _wishlistedProductIds.contains(p.id);
                            return _buildProductCard(p, wished);
                          },
                        );
                      }
                      if (productState is ProductFailed) {
                        return Center(child: Text(productState.message));
                      }
                      return const Center(
                        child: Text('No products available.'),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductListItem p, bool wished) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/product-detail', arguments: p);
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                p.images.isNotEmpty && _absolutePhotoUrl(p.images.first) != null
                    ? Image.network(
                        _absolutePhotoUrl(p.images.first)!,
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.broken_image, size: 50),
                        ),
                      )
                    : Container(
                        height: 160,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image, size: 50),
                      ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: Icon(
                      wished ? Icons.favorite : Icons.favorite_border,
                      color: wished ? Colors.red : Colors.grey.shade700,
                    ),
                    onPressed: () => _toggleWishlist(p),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white70,
                    ),
                  ),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.brandName,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${p.pricePerUnit}',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const Text('4.5', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_isLoggedIn(context)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please login to add to cart'),
                            ),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
