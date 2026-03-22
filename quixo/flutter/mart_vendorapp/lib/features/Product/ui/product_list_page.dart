import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../bloc/product_state.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {

  final searchController = TextEditingController();

  double? minPrice;
  double? maxPrice;
  String category = "";
  String delivery = "";
  String brand = "";
  int? rating;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {

    context.read<ProductBloc>().add(
      GetProducts(
        searchText: searchController.text,
        minPrice: minPrice,
        maxPrice: maxPrice,
        productCategory: category,
        deliveryCategory: delivery,
        brand: brand,
        rating: rating,
      ),
    );
  }

  void _openFilters() {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,

      builder: (_) {

        return Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Text("Filters", style: TextStyle(fontSize: 18)),

              TextField(
                decoration: const InputDecoration(labelText: "Min Price"),
                onChanged: (v) => minPrice = double.tryParse(v),
              ),

              TextField(
                decoration: const InputDecoration(labelText: "Max Price"),
                onChanged: (v) => maxPrice = double.tryParse(v),
              ),

              TextField(
                decoration: const InputDecoration(labelText: "Category"),
                onChanged: (v) => category = v,
              ),

              TextField(
                decoration: const InputDecoration(labelText: "Brand"),
                onChanged: (v) => brand = v,
              ),

              TextField(
                decoration: const InputDecoration(labelText: "Rating"),
                onChanged: (v) => rating = int.tryParse(v),
              ),

              DropdownButtonFormField(
                items: const [
                  DropdownMenuItem(
                    value: "quick",
                    child: Text("Quick Delivery"),
                  ),
                  DropdownMenuItem(
                    value: "ecommerce",
                    child: Text("E-Commerce"),
                  ),
                ],
                onChanged: (v) => delivery = v ?? "",
                decoration: const InputDecoration(labelText: "Delivery"),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {

                  Navigator.pop(context);
                  _loadProducts();

                },
                child: const Text("Apply Filters"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Products"),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilters,
          )
        ],
      ),

      body: Column(
        children: [

          /// SEARCH BAR
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText: "Search products",
                prefixIcon: const Icon(Icons.search),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loadProducts,
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocBuilder<ProductBloc, ProductState>(
              builder: (context, state) {

                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ProductListLoaded) {

                  return ListView.builder(
                    itemCount: state.products.length,

                    itemBuilder: (context, i) {

                      final p = state.products[i];

                      return ListTile(
                        title: Text(p.name),
                        subtitle: Text(p.brandName),
                        trailing: Text("Rs ${p.pricePerUnit}"),
                      );
                    },
                  );
                }

                if (state is ProductError) {
                  return Center(child: Text(state.error));
                }

                return const SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}