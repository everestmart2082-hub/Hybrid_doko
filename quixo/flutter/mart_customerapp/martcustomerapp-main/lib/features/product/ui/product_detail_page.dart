import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';
import '../data/rating_request_model.dart';
import '../data/review_model.dart';
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
  final TextEditingController reviewController = TextEditingController();
  double selectedRating = 0;
  List<dynamic> recommendedProducts = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductFetchById(widget.productId));
    context.read<ProductBloc>().add(ProductFetchRecommendedRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );

            // Reload product after review/rating
            context
                .read<ProductBloc>()
                .add(ProductFetchById(widget.productId));
          }
        },
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailed) {
            return Center(child: Text(state.message));
          }

          if (state is ProductRecommendedLoaded) {
            recommendedProducts = state.recommendedProducts;
          }

          if (state is ProductLoaded) {
            final p = state.product;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= IMAGE + COLOR SELECT =================
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
                              onTap: () => setState(() {
                                selectedColorIndex = index;
                              }),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  border: selectedColorIndex == index
                                      ? Border.all(
                                          color: theme.primaryColor, width: 2)
                                      : null,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            )),
                  ),
                  const SizedBox(height: 12),

                  // ================= NAME / BRAND / PRICE =================
                  Text(p.name,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(p.brand, style: theme.textTheme.bodyMedium),
                  Text("Rs. ${p.pricePerUnit}",
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),

                  const SizedBox(height: 12),

                  // ================= RATING =================
                  Text("Rate this product",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),

                  Row(
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            selectedRating = index + 1.0;
                          });

                          context.read<ProductBloc>().add(
                                ProductAddRatingRequested(
                                  RatingRequestModel(
                                    productId: p.id,
                                    rating: index + 1.0,
                                  ),
                                ),
                              );
                        },
                        icon: Icon(
                          Icons.star,
                          color: selectedRating > index
                              ? Colors.amber
                              : Colors.grey.shade400,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),

                  // ================= QUANTITY + ADD TO CART =================
                  Row(
                    children: [
                      QuantitySelector(
                        value: quantity,
                        onChanged: (v) => setState(() => quantity = v),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: p.stock > 0 ? () {} : null,
                          child: const Text("Add to Cart"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  // ================= SUMMARY =================
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

                  // ================= SPECS =================
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

                  // ================= ABOUT =================
                  Text("About this item",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(p.description, style: theme.textTheme.bodyMedium),

                  const SizedBox(height: 20),
                  const Divider(),

                  Text("Recommended Products",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedProducts.length,
                      itemBuilder: (context, index) {
                        final r = recommendedProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailPage(productId: r.id),
                              ),
                            );
                          },
                          child: Container(
                            width: 140,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Image.network(
                                  r.photos.first,
                                  height: 120,
                                  fit: BoxFit.cover,
                                ),
                                Text(r.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                Text("Rs. ${r.pricePerUnit}",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),

                  Text("Add a Review",
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: "Write your review...",
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 8),

                  ElevatedButton(
                    onPressed: () {
                      if (reviewController.text.trim().isEmpty) return;

                      context.read<ProductBloc>().add(
                            ProductAddReviewRequested(
                              ReviewRequestModel(
                                productId: p.id,
                                message: reviewController.text.trim(),
                              ),
                            ),
                          );

                      reviewController.clear();
                    },
                    child: const Text("Submit Review"),
                  ),
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

