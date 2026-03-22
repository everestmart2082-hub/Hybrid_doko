import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductDetailPage extends StatefulWidget {

  final String productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {

  int selectedImage = 0;

  @override
  void initState() {
    super.initState();

    context.read<ProductBloc>().add(
          GetProductDetail(widget.productId),
        );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),

      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {

          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductDetailLoaded) {

            final p = state.product;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  /// IMAGE
                  Image.network(p.photos[selectedImage]),

                  const SizedBox(height: 12),

                  /// IMAGE SELECTOR
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: p.photos.length,
                      itemBuilder: (_, i) {

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedImage = i;
                            });
                          },
                          child: Image.network(p.photos[i]),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(p.name,
                      style: Theme.of(context).textTheme.titleLarge),

                  Text("Brand: ${p.brand}"),

                  const SizedBox(height: 8),

                  Text("⭐ ${p.rating} rating"),

                  const SizedBox(height: 12),

                  Text(
                    "Rs ${p.price}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("Discount: ${p.discount}%"),

                  const SizedBox(height: 16),

                  Text("Description"),
                  Text(p.description),

                  const SizedBox(height: 20),

                  Text("About this item"),
                  Text(p.shortDescription),

                ],
              ),
            );
          }

          if (state is ProductError) {
            return Center(child: Text(state.error));
          }

          return const SizedBox();
        },
      ),
    );
  }
}