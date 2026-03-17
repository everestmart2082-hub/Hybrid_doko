import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/auth/ui/login_page.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import 'quantity_selector.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int quantity = 1;
  int selectedColorIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductGuestBloc>().add(ProductFetchById(widget.productId));
  }

  void _redirectToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: BlocBuilder<ProductGuestBloc, ProductGuestState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailed) {
            return Center(child: Text(state.message));
          }

          if (state is ProductLoaded) {
            final p = state.product;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 250,
                    child: PageView(
                      children: p.photos.map((photo) {
                        return Image.network(photo, fit: BoxFit.cover);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(
                      p.photos.length,
                      (index) => GestureDetector(
                        onTap: () => setState(() => selectedColorIndex = index),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            border: selectedColorIndex == index
                                ? Border.all(color: theme.primaryColor, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(p.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(p.brand, style: theme.textTheme.bodyMedium),
                  Text("Rs. ${p.pricePerUnit}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // QUANTITY + REDIRECT TO LOGIN ON ADD
                  Row(
                    children: [
                      QuantitySelector(
                        value: quantity,
                        onChanged: (v) => setState(() => quantity = v),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _redirectToLogin,
                          child: const Text("Add to Cart"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _redirectToLogin,
                          child: const Text("Add to Wishlist"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // SUMMARY
                  Text("Summary",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "• 100+ bought in past\n"
                    "• Price / Discount: Rs. ${p.pricePerUnit}\n"
                    "• 10 days service replacement\n"
                    "• Free delivery\n"
                    "• Pay on delivery\n"
                    "• Top brand: ${p.brand}\n"
                    "• Secure transaction\n",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // SPECS
                  Text("Specifications",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    "• Brand: ${p.brand}\n"
                    "• RAM Installed: 8GB\n"
                    "• Memory Storage: 256GB\n"
                    "• OS: Android / iOS\n",
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  const Divider(),

                  // ABOUT
                  Text("About this item",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(p.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}