import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/features/Product/bloc/product_bloc.dart';
import 'package:quickmartvender/features/Product/bloc/product_event.dart';
import 'package:quickmartvender/features/Product/bloc/product_state.dart';
import 'package:quickmartvender/features/Product/data/product_detail_model.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/bloc/auth_state.dart';
import '../web_shell.dart';
import 'product_form_page.dart';

class ProductDetailPage extends StatefulWidget {
  final String id;
  final List<Map<String, dynamic>> categories;
  const ProductDetailPage({required this.id, required this.categories, super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _imgIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = widget.id;
    context.read<ProductBloc>().add(GetProductDetail(id));
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

  String? _absolutePhotoUrl(String path) {
    final t = path.trim();
    if (t.isEmpty) return null;
    if (t.startsWith('http://') || t.startsWith('https://')) return t;
    final p = t.startsWith('/') ? t : '/$t';
    return '${ApiEndpoints.baseUrl}$p';
  }

  String _categoryIdHex(Map<String, dynamic> c) {
    final v = c['_id'];
    if (v is String) return v;
    if (v is Map && v[r'$oid'] is String) return v[r'$oid'] as String;
    return '';
  }

  String _resolveCategoryName(String catIdOrName) {
    if (catIdOrName.isEmpty) return '';
    for (final c in widget.categories) {
      if (_categoryIdHex(c) == catIdOrName) {
        return c['name']?.toString() ?? catIdOrName;
      }
    }
    return catIdOrName;
  }

  Widget _buildDetail(ProductDetail p) {
    final theme = Theme.of(context);
    final hasDiscount = p.discount > 0;
    final discountedPrice = hasDiscount
        ? (p.price * (1 - (p.discount / 100))).clamp(0, double.infinity)
        : p.price;

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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Container(
                    height: 260,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.primaryColorLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: p.photos.isNotEmpty
                        ? Image.network(
                            _absolutePhotoUrl(p.photos[_imgIndex]) ?? "",
                            fit: BoxFit.cover,
                          )
                        : Center(
                            child: Icon(
                              Icons.image,
                              size: 60,
                              color: theme.primaryColor,
                            ),
                          ),
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
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () => setState(() => _imgIndex = i),
                        child: Container(
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: i == _imgIndex
                                  ? theme.primaryColor
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            color: theme.primaryColorLight,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.network(
                              _absolutePhotoUrl(p.photos[i]) ?? "",
                              fit: BoxFit.cover,
                            ),
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
                      child: Text(
                        p.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                Text(
                  p.brand,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      'Rs ${discountedPrice.toStringAsFixed(2)}/${p.unit}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.primaryColor,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 10),
                      Text(
                        'Rs ${p.price.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          decoration: TextDecoration.lineThrough,
                          color: theme.hintColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${p.discount.toStringAsFixed(0)}% off',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Vendor: ${p.vendorName}',
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(p.shortDescription, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  children: [
                    _Chip(p.deliveryCategory, Icons.local_shipping),
                    _Chip(
                      _resolveCategoryName(p.productCategory),
                      Icons.category,
                    ),
                    _Chip('Stock: ${p.stock}', Icons.inventory_2),
                    _Chip('★ ${p.rating.toStringAsFixed(1)}', Icons.star_rate),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Description',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(p.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 24),
                Text(
                  'Customer reviews',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (p.reviews.isEmpty)
                  Text(
                    'No reviews yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  )
                else
                  ...p.reviews.map(
                    (r) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          r.userName.isNotEmpty ? r.userName : 'Customer',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          r.message,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
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
