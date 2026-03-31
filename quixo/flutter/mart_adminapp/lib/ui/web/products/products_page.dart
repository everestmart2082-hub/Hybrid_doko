import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_bloc.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_event.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_state.dart';
import 'package:mart_adminapp/features/products/data/admin_category_model.dart';
import 'package:mart_adminapp/features/products/data/admin_product_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  static const int _perPage = 10;
  int _page = 0;

  final _search = TextEditingController();
  String _sort = 'default';

  bool _filterHidden = false;
  bool _filterApproved = false;
  bool _filterToUpdate = false;

  String _category = 'all';

  List<AdminProductListItem> _products = const [];
  List<CategoryListItem> _categories = const [];

  @override
  void initState() {
    super.initState();
    context.read<AdminProductBloc>().add(AdminProductLoad());
    context.read<AdminProductBloc>().add(AdminCategoryLoad());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<AdminProductListItem> _applyFilters(List<AdminProductListItem> input) {
    final s = _search.text.trim().toLowerCase();
    final out = input.where((p) {
      final matchesSearch = s.isEmpty
          ? true
          : (p.name.toLowerCase().contains(s) ||
              p.shortDescription.toLowerCase().contains(s) ||
              p.brandName.toLowerCase().contains(s));

      final matchesCategory = _category == 'all'
          ? true
          : p.productCategory == _category;

      final matchesHidden = !_filterHidden ? true : p.hidden == true;
      final matchesApproved = !_filterApproved ? true : p.approved == true;
      final matchesToUpdate = !_filterToUpdate ? true : p.toUpdate == true;

      return matchesSearch &&
          matchesCategory &&
          matchesHidden &&
          matchesApproved &&
          matchesToUpdate;
    }).toList();

    switch (_sort) {
      case 'priceLow':
        out.sort((a, b) => a.pricePerUnit.toDouble().compareTo(b.pricePerUnit.toDouble()));
        break;
      case 'priceHigh':
        out.sort((a, b) => b.pricePerUnit.toDouble().compareTo(a.pricePerUnit.toDouble()));
        break;
      default:
        break;
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Products',
      child: BlocConsumer<AdminProductBloc, AdminProductState>(
        listener: (context, state) {
          if (state is AdminProductListLoaded) {
            setState(() => _products = state.products);
          } else if (state is AdminCategoryLoaded) {
            setState(() => _categories = state.categories);
          } else if (state is AdminProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AdminProductFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (_products.isEmpty && state is AdminProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _applyFilters(_products);
          final totalPages =
              (filtered.length / _perPage).ceil().clamp(1, 999999);
          final page = _page.clamp(0, totalPages - 1);
          final start = page * _perPage;
          final end = (start + _perPage).clamp(0, filtered.length);
          final items = filtered.sublist(start, end);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 320,
                      child: TextField(
                        controller: _search,
                        decoration: const InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (_) => setState(() => _page = 0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _category,
                      onChanged: (v) {
                        setState(() {
                          _category = v ?? 'all';
                          _page = 0;
                        });
                      },
                      items: [
                        const DropdownMenuItem(value: 'all', child: Text('All categories')),
                        ..._categories.map((c) => DropdownMenuItem(
                              value: c.name,
                              child: Text(c.name),
                            )),
                      ],
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      value: _sort,
                      onChanged: (v) => setState(() => _sort = v ?? 'default'),
                      items: const [
                        DropdownMenuItem(value: 'default', child: Text('default')),
                        DropdownMenuItem(value: 'priceLow', child: Text('price low to high')),
                        DropdownMenuItem(value: 'priceHigh', child: Text('price high to low')),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('hidden'),
                      selected: _filterHidden,
                      onSelected: (v) => setState(() => _filterHidden = v),
                    ),
                    FilterChip(
                      label: const Text('approved'),
                      selected: _filterApproved,
                      onSelected: (v) => setState(() => _filterApproved = v),
                    ),
                    FilterChip(
                      label: const Text('toupdate'),
                      selected: _filterToUpdate,
                      onSelected: (v) => setState(() => _filterToUpdate = v),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.12,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) {
                    final p = items[index];
                    return _ProductCard(
                      product: p,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/product_details',
                          arguments: {
                            'productId': p.productId,
                            'hidden': p.hidden,
                            'approved': p.approved,
                            'toUpdate': p.toUpdate,
                          },
                        );
                      },
                    );
                  },
                ),
              ),
              _Pagination(
                page: page,
                totalPages: totalPages,
                onPrev: page > 0 ? () => setState(() => _page = page - 1) : null,
                onNext: page < totalPages - 1 ? () => setState(() => _page = page + 1) : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final AdminProductListItem product;
  final VoidCallback onTap;
  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.image, size: 44),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.favorite_border),
                    onPressed: () {},
                    tooltip: 'wishlist',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text('${product.pricePerUnit} ${product.deliveryCategory.isEmpty ? '' : ''} per unit'),
              const SizedBox(height: 4),
              Text('brand: ${product.brandName}'),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  Chip(label: Text('hidden: ${product.hidden}')),
                  Chip(label: Text('approved: ${product.approved}')),
                  if (product.toUpdate) const Chip(label: Text('toupdate: true')),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AdminProductBloc>().add(
                              AdminProductHide(
                                productId: product.productId,
                                hide: !product.hidden,
                              ),
                            );
                      },
                      child: Text(product.hidden ? 'Unhide Product' : 'Hide Product'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AdminProductBloc>().add(
                              AdminProductApprove(
                                productId: product.productId,
                                approved: !product.approved,
                              ),
                            );
                      },
                      child: Text(product.approved ? 'Unapprove Product' : 'Approve Product'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (product.toUpdate)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/product_details',
                        arguments: {
                          'productId': product.productId,
                          'hidden': product.hidden,
                          'approved': product.approved,
                          'toUpdate': product.toUpdate,
                        },
                      );
                    },
                    child: const Text('check update proposal'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          TextButton(onPressed: onPrev, child: const Text('Prev')),
          const SizedBox(width: 10),
          Text('${page + 1} / $totalPages'),
          const Spacer(),
          TextButton(onPressed: onNext, child: const Text('Next')),
        ],
      ),
    );
  }
}

