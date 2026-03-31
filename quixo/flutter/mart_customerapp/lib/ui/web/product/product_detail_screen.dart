import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/drawer.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/data/product_list_item_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final ProductListItem productItem;
  
  const ProductDetailScreen({super.key, required this.productItem});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;

  void _increment() => setState(() => _quantity++);
  void _decrement() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.productItem;

    return Scaffold(
      appBar: AppBar(title: Text(p.name)),
      drawer: buildAppDrawer(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left side (Images)
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Container(
                          height: 400,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: p.images.isNotEmpty
                              ? Image.network(p.images[_selectedImageIndex], fit: BoxFit.contain)
                              : const Center(child: Icon(Icons.image, size: 100, color: Colors.grey)),
                        ),
                        const SizedBox(height: 16),
                        if (p.images.isNotEmpty)
                          SizedBox(
                            height: 80,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: p.images.length,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedImageIndex = index),
                                  child: Container(
                                    width: 80,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: _selectedImageIndex == index ? Theme.of(context).primaryColor : Colors.grey.shade300,
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(p.images[index], fit: BoxFit.cover),
                                  ),
                                );
                              },
                            ),
                          )
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right side (Details)
                  Expanded(
                    flex: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(p.name, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                            Text(p.brandName, style: TextStyle(color: Colors.grey.shade600, fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '₹${p.pricePerUnit} / unit',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                        ),
                        const SizedBox(height: 8),
                        const Text('Vendor: QuickMart', style: TextStyle(fontWeight: FontWeight.w500)),
                        const SizedBox(height: 16),
                        Text(p.shortDescription, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Text('Quantity: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(onPressed: _decrement, icon: const Icon(Icons.remove_circle_outline)),
                            Text('$_quantity', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(onPressed: _increment, icon: const Icon(Icons.add_circle_outline)),
                            const SizedBox(width: 24),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                onPressed: () {
                                  context.read<CartBloc>().add(CartAddRequested(CartAddRequestModel(
                                    productId: p.id,
                                    number: _quantity,
                                  )));
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Added $_quantity ${p.name}(s) to cart')));
                                },
                                icon: const Icon(Icons.shopping_cart),
                                label: const Text("Add To Cart"),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const Divider(),
            // Reviews Section
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Reviews', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 16),
                      const Text('(4.5)', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, color: Colors.orange),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Add Review'),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Sample User 123 - Great Product! (5/5)', style: TextStyle(fontStyle: FontStyle.italic)),
                  const SizedBox(height: 8),
                  const Text('Sample User 456 - Decent quality. (4/5)', style: TextStyle(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
