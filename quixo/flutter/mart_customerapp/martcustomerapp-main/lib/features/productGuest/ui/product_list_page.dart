import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../data/product_list_item_model.dart';
import '../data/product_query_model.dart';
import 'product_detail_page.dart';
import 'product_filers.dart';

class ProductGuestListPage extends StatefulWidget {
  const ProductGuestListPage({super.key});

  @override
  State<ProductGuestListPage> createState() => _ProductGuestListPageState();
}

class _ProductGuestListPageState extends State<ProductGuestListPage> {
  final TextEditingController _searchCtrl = TextEditingController();
  bool showFilters = true;
  int currentPage = 1;
  var query = ProductQuery();

  @override
  void initState() {
    super.initState();
    context.read<ProductGuestBloc>().add(ProductFetchAll(page: currentPage));
  }

  void _applyFilters(Map<String, dynamic> newFilters) {
  // Update the query object with new filter values
    query = query.copyWith(
      minPrice: newFilters['minPrice'] as double?,
      maxPrice: newFilters['maxPrice'] as double?,
      inStock: newFilters['inStock'] as bool?,
      sort: newFilters['sort'] as String?,
      // you can add other filters here, e.g., category, brand
      category: newFilters['category'] as String?,
      brand: newFilters['brand'] as String?,
    );

    // Trigger the Bloc to fetch products with the updated query
    context.read<ProductGuestBloc>().add(ProductFetchRequested(query));
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
              // ================= SEARCH BAR =================
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onSubmitted: (value) {
                        _applyFilters(query.toMap());
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    onPressed: () {
                      setState(() => showFilters = !showFilters);
                    },
                  ),
                ],
              ),

              // ================= FILTERS =================
              if (showFilters)
                ProductFilters(
                  query: const {},
                  onApply: (q) {
                    _applyFilters(query.toMap());
                  },
                ),

              const SizedBox(height: 12),

              // ================= PRODUCT GRID =================
              Expanded(
                child: BlocBuilder<ProductGuestBloc, ProductGuestState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is ProductFailed) {
                      return Center(child: Text(state.message));
                    }

                    if (state is ProductListLoaded) {
                      final products = state.products;

                      if (products.isEmpty) {
                        return const Center(child: Text('No products found'));
                      }

                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          return _buildProductCard(context, product);
                        },
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
        onTap: null,
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
              child: Text(product.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(product.brandName),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text("Rs. ${product.pricePerUnit}"),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: product.stock > 0 ? () {} : null,
                child: const Text("Add"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}