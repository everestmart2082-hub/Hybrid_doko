import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/Product/bloc/product_bloc.dart';
import 'package:quickmartvender/features/Product/bloc/product_event.dart';
import 'package:quickmartvender/features/Product/bloc/product_state.dart';
import 'package:quickmartvender/features/Product/data/product_model.dart';
import '../web_shell.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  final _search = TextEditingController();
  String _sortBy = 'default';
  String _selectedCategory = '';
  List<Map<String, dynamic>> _categories = [];
  double? _minPrice, _maxPrice;
  int _page = 1;
  static const int _limit = 12;
  bool _filtersVisible = true;

  final _sortOptions = [
    'default', 'price low to high', 'price high to low',
    'rating', 'discount', 'newest', 'oldest',
  ];

  @override
  void initState() {
    super.initState();
    _load();
    context.read<ProductBloc>().add(GetProductFilters());
  }

  void _load() {
    context.read<ProductBloc>().add(GetProducts(
      page: _page,
      limit: _limit,
      searchText: _search.text.trim(),
      sortBy: _sortBy,
      productCategory: _selectedCategory,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
    ));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Products',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/product/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Product'),
          ),
        ),
      ],
      child: BlocListener<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductFiltersLoaded) {
            setState(() => _categories = state.categories);
          }
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Filter Sidebar ──────────────────────
            if (_filtersVisible)
              SizedBox(
                width: 220,
                child: _FilterPanel(
                  sortOptions: _sortOptions,
                  sortBy: _sortBy,
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onSortChanged: (v) { setState(() => _sortBy = v ?? 'default'); _load(); },
                  onCategoryChanged: (v) { setState(() => _selectedCategory = v ?? ''); _load(); },
                  onPriceChanged: (min, max) { setState(() { _minPrice = min; _maxPrice = max; }); _load(); },
                ),
              ),
            // ── Main Content ────────────────────────
            Expanded(
              child: Column(
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(_filtersVisible ? Icons.filter_list_off : Icons.filter_list),
                          onPressed: () => setState(() => _filtersVisible = !_filtersVisible),
                          tooltip: 'Toggle filters',
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _search,
                            decoration: InputDecoration(
                              hintText: 'Search products...',
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.search),
                                onPressed: () { setState(() => _page = 1); _load(); },
                              ),
                            ),
                            onSubmitted: (_) { setState(() => _page = 1); _load(); },
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Grid
                  Expanded(
                    child: BlocBuilder<ProductBloc, ProductState>(
                      builder: (context, state) {
                        if (state is ProductLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is ProductError) {
                          return Center(child: Text(state.error));
                        }
                        if (state is ProductListLoaded) {
                          return _buildGrid(state.products);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  // Pagination
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: _page > 1
                              ? () { setState(() => _page--); _load(); }
                              : null,
                        ),
                        Text('Page $_page'),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: () { setState(() => _page++); _load(); },
                        ),
                      ],
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

  Widget _buildGrid(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No products found.'));
    }
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => _ProductCard(
        product: products[i],
        onTap: () => Navigator.pushNamed(context, '/product/detail',
            arguments: products[i].id),
      ),
    );
  }
}

// ── Filter panel widget ─────────────────────────────────────────────────────

class _FilterPanel extends StatefulWidget {
  final List<String> sortOptions;
  final String sortBy;
  final List<Map<String, dynamic>> categories;
  final String selectedCategory;
  final void Function(String?) onSortChanged;
  final void Function(String?) onCategoryChanged;
  final void Function(double?, double?) onPriceChanged;

  const _FilterPanel({
    required this.sortOptions,
    required this.sortBy,
    required this.categories,
    required this.selectedCategory,
    required this.onSortChanged,
    required this.onCategoryChanged,
    required this.onPriceChanged,
  });

  @override
  State<_FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<_FilterPanel> {
  final _minCtrl = TextEditingController();
  final _maxCtrl = TextEditingController();

  @override
  void dispose() {
    _minCtrl.dispose();
    _maxCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 16, left: 16, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            const Divider(),
            const Text('Sort By', style: TextStyle(fontWeight: FontWeight.w600)),
            DropdownButton<String>(
              isExpanded: true,
              value: widget.sortBy,
              items: widget.sortOptions
                  .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12))))
                  .toList(),
              onChanged: widget.onSortChanged,
            ),
            const SizedBox(height: 12),
            const Text('Category', style: TextStyle(fontWeight: FontWeight.w600)),
            DropdownButton<String>(
              isExpanded: true,
              value: widget.selectedCategory.isEmpty ? null : widget.selectedCategory,
              hint: const Text('All'),
              items: [
                const DropdownMenuItem(value: '', child: Text('All')),
                ...widget.categories.map((c) {
                  final name = c['name']?.toString() ?? '';
                  return DropdownMenuItem(value: name, child: Text(name, style: const TextStyle(fontSize: 12)));
                }),
              ],
              onChanged: widget.onCategoryChanged,
            ),
            const SizedBox(height: 12),
            const Text('Price Range', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: _minCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Min Price', border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _maxCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Max Price', border: OutlineInputBorder(), isDense: true),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  widget.onPriceChanged(
                    double.tryParse(_minCtrl.text),
                    double.tryParse(_maxCtrl.text),
                  );
                },
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product card widget ─────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 130,
                color: theme.primaryColorLight,
                child: Center(child: Icon(Icons.image, size: 48, color: theme.primaryColor)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('Rs ${product.pricePerUnit}',
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
                  Text(product.brandName,
                      style: theme.textTheme.bodySmall, maxLines: 1),
                  Text(product.shortDescription,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 12, color: Colors.amber.shade700),
                      const SizedBox(width: 2),
                      Text(product.productCategory,
                          style: theme.textTheme.labelSmall),
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
