import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/product_bloc.dart';
import '../bloc/product_event.dart';
import '../data/product_detail_model.dart';
import '../data/product_input_model.dart';

class ProductEditPage extends StatefulWidget {

  final ProductDetail? product;

  const ProductEditPage({super.key, this.product});

  @override
  State<ProductEditPage> createState() => _ProductEditPageState();
}

class _ProductEditPageState extends State<ProductEditPage> {

  final name = TextEditingController();
  final brand = TextEditingController();
  final description = TextEditingController();
  final shortDescription = TextEditingController();
  final price = TextEditingController();
  final unit = TextEditingController();
  final discount = TextEditingController();
  final category = TextEditingController();
  final deliveryCategory = TextEditingController();
  final stock = TextEditingController();

  List<String> photos = [];

  void save() {

    final input = ProductInput(
      name: name.text,
      brand: brand.text,
      description: description.text,
      shortDescription: shortDescription.text,
      pricePerUnit: double.parse(price.text),
      unit: unit.text,
      discount: double.parse(discount.text),
      productCategory: category.text,
      deliveryCategory: deliveryCategory.text,
      stock: int.parse(stock.text),
      photos: photos,
    );

    if (widget.product == null) {

      context.read<ProductBloc>().add(
            AddProduct(input),
          );

    } else {

      context.read<ProductBloc>().add(
            EditProduct(input),
          );

    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Add Product")),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            field("Name", name),
            field("Brand", brand),
            field("Description", description),
            field("Short Description", shortDescription),

            field("Price", price),
            field("Unit", unit),
            field("Discount", discount),

            field("Product Category", category),

            field("Delivery Category", deliveryCategory),

            field("Stock", stock),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: save,
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  Widget field(String label, TextEditingController c) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}