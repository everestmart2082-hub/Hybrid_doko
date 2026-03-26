import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../data/product_list_item_model.dart';
import '../data/product_query.dart';
import 'product_detail_page.dart';
import 'product_filers.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool showFilters = false;
  int currentPage = 1;
  var query = ProductQuery();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  void _fetchProducts() {
    context.read<ProductBloc>().add(ProductFetchRequested(query.copyWith(page: currentPage)));
  }

  void _applyFilters(Map<String, dynamic> newFilters) {
    query = query.copyWith(
      minPrice: newFilters['minPrice'] as double?,
      maxPrice: newFilters['maxPrice'] as double?,
      inStock: newFilters['inStock'] as bool?,
      sort: newFilters['sort'] as String?,
      category: newFilters['category'] as String?,
      brand: newFilters['brand'] as String?,
    );

    _fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Products")),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, theme.primaryColorLight],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Search bar + filter toggle
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _applyFilters(query.toMap()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () => setState(() => showFilters = !showFilters),
                  ),
                ],
              ),

              // Filters
              if (showFilters)
                ProductFilters(
                  query: query.toMap(),
                  onApply: _applyFilters,
                ),

              const SizedBox(height: 12),

              // Product Grid
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is ProductFailed) {
                      return Center(child: Text(state.message, style: theme.textTheme.bodyLarge));
                    }
                    if (state is ProductListLoaded) {
                      final products = state.products;
                      if (products.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }

                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) => _buildProductCard(context, products[index]),
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, ProductListItem product) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailPage(productId: product.id)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product.images.isNotEmpty ? product.images.first : "",
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(product.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(product.brandName, style: theme.textTheme.bodyMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text("Rs. ${product.pricePerUnit}", style: theme.textTheme.titleSmall),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: product.stock > 0
                    ? () => context.read<CartBloc>().add(CartAddRequested(CartAddRequestModel(productId: product.id, number: 1)))
                    : null,
                child: const Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}