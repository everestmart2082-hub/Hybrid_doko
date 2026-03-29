import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/drawer.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/product/bloc/product_event.dart';
import 'package:quickmartcustomer/features/product/bloc/product_state.dart';
import 'package:quickmartcustomer/features/product/data/product_list_item_model.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  int _currentPage = 1;
  String? _selectedCategory;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    // Assuming backend endpoint /api/category/all and vendor/all should be fetched here,
    // but we can mock or keep it static based on requirements for Web UI demo
  }

  void _fetchProducts() {
    // Basic fetch assuming typical structure
    context.read<ProductBloc>().add(
      ProductFetchAll(
        page: _currentPage,
        limit: 20,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
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
                    const TextField(
                      decoration: InputDecoration(
                        labelText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),

                    const Text('Sort By', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildSortOptions(),
                    const Divider(),

                    const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                    _buildCategoryOptions(),
                    const Divider(),

                    const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _minPriceController,
                      decoration: const InputDecoration(labelText: 'Min Price', isDense: true),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _maxPriceController,
                      decoration: const InputDecoration(labelText: 'Max Price', isDense: true),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchProducts,
                      child: const Text("Apply Filter"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right Body (Product Grid)
          Expanded(
            flex: 8,
            child: Container(
              color: Colors.grey[100],
              padding: const EdgeInsets.all(16),
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                   if (state is ProductLoading) {
                     return const Center(child: CircularProgressIndicator());
                   } else if (state is ProductListLoaded) {
                     return _buildProductGrid(state.products);
                   } else if (state is ProductFailed) {
                     return Center(child: Text(state.message));
                   }
                   return const Center(child: Text('No products available.'));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions() {
    final opts = ['default', 'price low to high', 'price high to low', 'rating', 'discount', 'newest', 'oldest'];
    return Column(
      children: opts.map((o) => RadioListTile(
        title: Text(o),
        value: o,
        groupValue: 'default',
        onChanged: (val) {},
        dense: true,
      )).toList(),
    );
  }

  Widget _buildCategoryOptions() {
    final opts = ['all', 'electronics', 'groceries', 'clothing'];
    return Column(
      children: opts.map((o) => RadioListTile(
        title: Text(o),
        value: o,
        groupValue: _selectedCategory ?? 'all',
        onChanged: (val) {
          setState(() => _selectedCategory = val as String?);
        },
        dense: true,
      )).toList(),
    );
  }

  Widget _buildProductGrid(List<ProductListItem> products) {
    return Column(
      children: [
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 250,
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
        // Pagination
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: _currentPage > 1 ? () {
                  setState(() => _currentPage--);
                  _fetchProducts();
                } : null,
                child: const Text('Prev'),
              ),
              Text('  Page $_currentPage  '),
              TextButton(
                onPressed: () {
                  setState(() => _currentPage++);
                  _fetchProducts();
                },
                child: const Text('Next'),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildProductCard(ProductListItem p) {
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
                p.images.isNotEmpty
                    ? Image.network(p.images.first, height: 160, width: double.infinity, fit: BoxFit.cover)
                    : Container(height: 160, color: Colors.grey, child: const Icon(Icons.image, size: 50)),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {
                      // Wishlist logic
                    },
                    style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(p.brandName, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${p.pricePerUnit}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const Text('4.5', style: TextStyle(fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<CartBloc>().add(
                          CartAddRequested(CartAddRequestModel(productId: p.id, number: 1))
                        );
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart!')));
                      },
                      child: const Text('Add To Cart'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
