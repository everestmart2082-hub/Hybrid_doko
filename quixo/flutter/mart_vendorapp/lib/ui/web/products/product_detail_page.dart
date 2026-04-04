import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/Product/bloc/product_bloc.dart';
import 'package:quickmartvender/features/Product/bloc/product_event.dart';
import 'package:quickmartvender/features/Product/bloc/product_state.dart';
import 'package:quickmartvender/features/Product/data/product_detail_model.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/bloc/auth_state.dart';
import '../web_shell.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _imgIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = ModalRoute.of(context)!.settings.arguments as String?;
    if (id != null) {
      context.read<ProductBloc>().add(GetProductDetail(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Product Detail',
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProductError) {
            return Center(child: Text(state.error));
          }
          if (state is ProductDetailLoaded) {
            return _buildDetail(state.product);
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildDetail(ProductDetail p) {
    final theme = Theme.of(context);

    // Determine if the current vendor owns this product
    final authState = context.read<VenderAuthBloc>().state;
    // We compare with logged-in vendor. For now show button for authenticated users.
    final isOwner = authState is VenderAuthenticated && authState.authenticated;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─ Left: images ─────────────────────────────
          SizedBox(
            width: 320,
            child: Column(
              children: [
                // Main image
                Card(
                  elevation: 2,
                  color: Theme.of(context).primaryColorLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.primaryColorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: p.photos.isNotEmpty
                        ? Image.network(p.photos[_imgIndex], fit: BoxFit.cover)
                        : Center(child: Icon(Icons.image, size: 60, color: theme.primaryColor)),
                  ),
                ),
                const SizedBox(height: 10),
                // Thumbnail strip
                if (p.photos.length > 1)
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: p.photos.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => setState(() => _imgIndex = i),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: i == _imgIndex ? theme.primaryColor : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: theme.primaryColorLight,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(p.photos[i], fit: BoxFit.cover),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          // ─ Right: details ───────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(p.name,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold)),
                    ),
                    if (isOwner)
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductFormPage(existing: p),
                          ),
                        ),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit Product'),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(p.brand, style: theme.textTheme.titleSmall?.copyWith(color: theme.hintColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('Rs ${p.price}/${p.unit}',
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.bold, color: theme.primaryColor)),
                    if (p.discount > 0) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('${p.discount}% off',
                            style: TextStyle(color: Colors.green.shade800, fontSize: 12)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text('Vendor: ${p.vendorName}', style: theme.textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(p.shortDescription, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  children: [
                    _Chip(p.deliveryCategory, Icons.local_shipping),
                    _Chip(p.productCategory, Icons.category),
                    _Chip('Stock: ${p.stock}', Icons.inventory_2),
                    _Chip('★ ${p.rating.toStringAsFixed(1)}', Icons.star_rate),
                  ],
                ),
                const SizedBox(height: 18),
                Text('Description', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(p.description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _Chip(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 15),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      padding: EdgeInsets.zero,
    );
  }
}
