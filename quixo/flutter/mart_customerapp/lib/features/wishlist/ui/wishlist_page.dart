import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/drawer.dart';

import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_event.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_state.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_query_model.dart';
import 'package:quickmartcustomer/features/wishlist/data/wishlist_model.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

String? _absolutePhotoUrl(String path) {
  final t = path.trim();
  if (t.isEmpty) return null;
  if (t.startsWith('http://') || t.startsWith('https://')) return t;
  final p = t.startsWith('/') ? t : '/$t';
  return '${ApiEndpoints.baseImageUrl}$p';
}

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  @override
  void initState() {
    super.initState();
    context.read<WishlistBloc>().add(
      const WishlistFetchRequested(WishlistQueryModel()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Wishlist',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).primaryColorLight),
        ),
        actions: const [CustomerHubBarIcons()],
      ),
      drawer: buildAppDrawer(context),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocConsumer<WishlistBloc, WishlistState>(
          listener: (context, state) {
            if (state is WishlistActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            } else if (state is WishlistFailed) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is WishlistLoading || state is WishlistInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WishlistLoaded) {
              final items = state.items;
              if (items.isEmpty) {
                return const Center(child: Text('Wishlist is empty'));
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _WishlistCard(item: item);
                },
              );
            }
            if (state is WishlistFailed) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _WishlistCard extends StatelessWidget {
  final WishlistItemModel item;

  const _WishlistCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final discountedPrice = item.pricePerUnit * (1 - (item.discount / 100));
    return InkWell(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/product-detail',
          arguments: item.productId,
        );
      },
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120,
                height: 100,
                child:
                    item.image.isNotEmpty &&
                        _absolutePhotoUrl(item.image) != null
                    ? Image.network(
                        _absolutePhotoUrl(item.image)!,
                        fit: BoxFit.cover,
                      )
                    : const Placeholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(item.brandName),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '₹${discountedPrice.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (item.discount > 0)
                          Text(
                            '₹${item.pricePerUnit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                        if (item.discount > 0)
                          Text(
                            '${item.discount.toStringAsFixed(0)}% OFF',
                            style: TextStyle(
                              color: Theme.of(context).primaryColorDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(
                              context,
                              '/product-detail',
                              arguments: item.productId,
                            );
                          },
                          child: const Text('View'),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            context.read<WishlistBloc>().add(
                              WishlistRemoveItemRequested(
                                item.wishlistId.isNotEmpty
                                    ? item.wishlistId
                                    : item.productId,
                              ),
                            );
                          },
                          child: const Text('Remove From Wishlist'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
