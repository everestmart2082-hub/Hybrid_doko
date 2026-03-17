import 'package:flutter/material.dart';

class ProductFilters extends StatefulWidget {
  final Map<String, dynamic> query; // simplified
  final ValueChanged<Map<String, dynamic>> onApply;

  const ProductFilters({
    super.key,
    required this.query,
    required this.onApply,
  });

  @override
  State<ProductFilters> createState() => _ProductFiltersState();
}

class _ProductFiltersState extends State<ProductFilters> {
  double minPrice = 0;
  double maxPrice = 10000;
  bool inStock = false;
  String selectedSort = "createdAt-desc";

  @override
  void initState() {
    super.initState();
    minPrice = widget.query['minPrice'] ?? 0;
    maxPrice = widget.query['maxPrice'] ?? 10000;
    inStock = widget.query['inStock'] ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: minPrice.toString(),
                    decoration: const InputDecoration(labelText: 'Min price'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        minPrice = double.tryParse(v) ?? 0,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: maxPrice.toString(),
                    decoration: const InputDecoration(labelText: 'Max price'),
                    keyboardType: TextInputType.number,
                    onChanged: (v) =>
                        maxPrice = double.tryParse(v) ?? 10000,
                  ),
                ),
              ],
            ),
            CheckboxListTile(
              title: const Text('Show in stock only'),
              value: inStock,
              onChanged: (v) => setState(() => inStock = v!),
            ),
            DropdownButtonFormField<String>(
              value: selectedSort,
              decoration: const InputDecoration(labelText: "Sort By"),
              items: const [
                DropdownMenuItem(
                  value: "createdAt-desc",
                  child: Text("Newest First"),
                ),
                DropdownMenuItem(
                  value: "createdAt-asc",
                  child: Text("Oldest First"),
                ),
                DropdownMenuItem(
                  value: "price-asc",
                  child: Text("Price: Low-High"),
                ),
                DropdownMenuItem(
                  value: "price-desc",
                  child: Text("Price: High-Low"),
                ),
              ],
              onChanged: (v) => setState(() => selectedSort = v!),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply({
                    'minPrice': minPrice,
                    'maxPrice': maxPrice,
                    'inStock': inStock,
                    'sort': selectedSort,
                  });
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