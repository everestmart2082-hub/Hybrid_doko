import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_bloc.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_event.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_state.dart';
import 'package:mart_adminapp/features/products/data/admin_product_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminProductDetailsPage extends StatefulWidget {
  const AdminProductDetailsPage({super.key});

  @override
  State<AdminProductDetailsPage> createState() =>
      _AdminProductDetailsPageState();
}

class _AdminProductDetailsPageState extends State<AdminProductDetailsPage> {
  String? _productId;
  bool _hidden = false;
  bool _approved = false;
  bool _toUpdate = false;

  AdminProductDetail? _detail;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      _productId = args['productId']?.toString();
      _hidden = (args['hidden'] as bool?) ?? false;
      _approved = (args['approved'] as bool?) ?? false;
      _toUpdate = (args['toUpdate'] as bool?) ?? false;
    }

    if (_productId != null) {
      context.read<AdminProductBloc>().add(AdminProductLoadById(_productId!));
    }
  }

  String _imageUrl(String photo) {
    if (photo.startsWith('http://') || photo.startsWith('https://')) {
      return photo;
    }
    return '${ApiEndpoints.baseImageUrl}${photo.startsWith('/') ? '' : '/'}$photo';
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Product Details',
      child: BlocConsumer<AdminProductBloc, AdminProductState>(
        listener: (context, state) {
          if (state is AdminProductDetailLoaded) {
            _detail = state.detail;
          } else if (state is AdminProductActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            if (_productId != null) {
              context
                  .read<AdminProductBloc>()
                  .add(AdminProductLoadById(_productId!));
            }
          } else if (state is AdminProductFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final d = _detail;
          if (_productId == null) {
            return const Center(child: Text('Missing productId argument.'));
          }
          if (d == null || state is AdminProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        Chip(label: Text('hidden: $_hidden')),
                        Chip(label: Text('approved: $_approved')),
                        if (_toUpdate) const Chip(label: Text('toupdate: true')),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: d.photos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final photo = d.photos[i];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl(photo),
                          width: 160,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 160,
                            height: 180,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('brand: ${d.brand}', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 6),
                        Text('delivery category: ${d.deliveryCategory}'),
                        const SizedBox(height: 6),
                        Text('product category: ${d.productCategory}'),
                        const SizedBox(height: 6),
                        Text('stock: ${d.stock}'),
                        const SizedBox(height: 6),
                        Text('rating: ${d.rating}'),
                        const SizedBox(height: 6),
                        Text('unit: ${d.unit}'),
                        const SizedBox(height: 6),
                        Text('price per unit: ${d.pricePerUnit}'),
                        const SizedBox(height: 6),
                        Text('discount: ${d.discount}'),
                        const SizedBox(height: 12),
                        Text('short description:', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 6),
                        Text(d.shortDescriptions),
                        const SizedBox(height: 12),
                        Text('Long description:', style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 6),
                        Text(d.description),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AdminProductBloc>().add(
                                AdminProductHide(
                                  productId: _productId!,
                                  hide: !_hidden,
                                ),
                              );
                          setState(() => _hidden = !_hidden);
                        },
                        child: Text(_hidden ? 'Unhide Product' : 'Hide Product'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AdminProductBloc>().add(
                                AdminProductApprove(
                                  productId: _productId!,
                                  approved: !_approved,
                                ),
                              );
                          setState(() => _approved = !_approved);
                        },
                        child:
                            Text(_approved ? 'Unapprove Product' : 'Approve Product'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

