import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/drawer.dart';
import 'package:quickmartcustomer/core/constants/api_constants.dart';

import 'package:quickmartcustomer/features/order/bloc/order_bloc.dart';
import 'package:quickmartcustomer/features/order/bloc/order_event.dart';
import 'package:quickmartcustomer/features/order/bloc/order_state.dart';
import 'package:quickmartcustomer/features/order/data/order_query_model.dart';
import 'package:quickmartcustomer/features/order/data/order_model.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  int _tabIndex = 0;
  final _searchCtrl = TextEditingController();
  static const _tabs = <String>[
    'preparing',
    'pending',
    'delivered',
    'cancelledByUser',
    'cancelledByVender',
    'returned',
  ];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _applyFilters() {
    context.read<OrderBloc>().add(
      OrderFetchRequested(
        OrderQueryModel(status: _tabs[_tabIndex], search: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim()),
      ),
    );
  }

  void _cancelAll(List<OrderModel> orders) {
    final ids = orders.where(_canCancel).map((o) => o.orderId).toList();
    if (ids.isEmpty) return;
    context.read<OrderBloc>().add(OrderCancelAllRequested(ids));
  }

  bool _canCancel(OrderModel order) {
    final s = order.status.toLowerCase();
    return s.contains('preparing') || s.contains('pending');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      drawer: buildAppDrawer(context),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Orders',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        elevation: 1,
        actions: const [CustomerHubBarIcons()],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                labelText: 'Search',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final active = index == _tabIndex;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      selected: active,
                      label: Text(_tabs[index]),
                      onSelected: (_) {
                        setState(() => _tabIndex = index);
                        _applyFilters();
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocConsumer<OrderBloc, OrderState>(
                listener: (context, state) {
                  if (state is OrderActionSuccess) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  } else if (state is OrderFailed) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is OrderLoading || state is OrderInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is OrderLoaded) {
                    final orders = state.orders;
                    final quick = orders.where((o) => o.deliveryCategory.toLowerCase() == 'quick').toList();
                    final normal = orders.where((o) => o.deliveryCategory.toLowerCase() != 'quick').toList();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if(_tabIndex == 0 || _tabIndex == 1)
                        Align(
                          alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: orders.where(_canCancel).isEmpty
                                ? null
                                : () => _cancelAll(orders),
                            icon: const Icon(Icons.cancel),
                              label: Text('cancel All (${orders.where(_canCancel).length})'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView(
                            children: [
                              _buildDeliverySection('Quick', quick),
                              const SizedBox(height: 16),
                              _buildDeliverySection('Normal', normal),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                  if (state is OrderFailed) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySection(String label, List<OrderModel> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$label Delivery', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 10),
            if (items.isEmpty)
              const Text('No orders')
            else
              ...items.map((order) {
                final showCancel = _canCancel(order);
                final imageUrl = order.productImage.isEmpty
                    ? null
                    : (order.productImage.startsWith('http')
                        ? order.productImage
                        : '${ApiEndpoints.baseImageUrl}${order.productImage.startsWith('/') ? '' : '/'}${order.productImage}');
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    onTap: () {
                      if (order.productId.isNotEmpty) {
                        Navigator.pushNamed(context, '/product-detail', arguments: order.productId);
                      }
                    },
                    leading: SizedBox(
                      width: 56,
                      height: 56,
                      child: imageUrl == null
                          ? const Icon(Icons.image)
                          : Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                    ),
                    title: Text('${order.productName} (${order.ordersId})'),
                    subtitle: Text(
                      '${order.brandName}\nQty: ${order.productNumber}\n${order.shortDescription}\nStatus: ${order.status}${order.riderName.isEmpty ? '' : '\nRider: ${order.riderName} (${order.riderNumber})'}',
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: showCancel
                        ? TextButton(
                            onPressed: () => context.read<OrderBloc>().add(OrderCancelRequested(order.orderId)),
                            child: const Text('cancel this order'),
                          )
                        : const Text('-'),
                  ),
                );
              }),
            const SizedBox(height: 8),
            if(_tabIndex == 0 || _tabIndex == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: items.isEmpty ? null : () => _cancelAll(items),
                  icon: const Icon(Icons.cancel),
                  label: const Text('cancel All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
