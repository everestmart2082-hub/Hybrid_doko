import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/order/bloc/order_bloc.dart';
import 'package:quickmartcustomer/features/order/bloc/order_event.dart';
import 'package:quickmartcustomer/features/order/bloc/order_state.dart';
import 'package:quickmartcustomer/features/order/data/order_query_model.dart';
import 'package:quickmartcustomer/features/order/data/order_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String _status = 'preparing';
  String _deliveryCategory = 'quick'; // UI-only toggle

  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const OrderFetchRequested(OrderQueryModel()));
  }

  void _applyFilters() {
    context.read<OrderBloc>().add(
      OrderFetchRequested(
        OrderQueryModel(status: _status, deliveryCategory: _deliveryCategory),
      ),
    );
  }

  void _cancelAll(List<OrderModel> orders) {
    final ids = orders.map((o) => o.orderId).toList();
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
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(
          'Orders',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColorLight,
          ),
        ),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilters(),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: OutlinedButton.icon(
                            onPressed: orders.isEmpty
                                ? null
                                : () => _cancelAll(orders),
                            icon: const Icon(Icons.cancel),
                            label: const Text('cancel All'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.separated(
                            itemCount: orders.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 20),
                            itemBuilder: (context, index) {
                              final order = orders[index];
                              final showCancel = _canCancel(order);
                              return ListTile(
                                onTap: () {
                                  if (order.productId.isNotEmpty) {
                                    Navigator.pushNamed(
                                      context,
                                      '/product-detail',
                                      arguments: order.productId,
                                    );
                                  }
                                },
                                title: Text(
                                  'Order ${order.orderId} • ${order.productName}',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  'Status: ${order.status}\nDelivery: ${order.deliveryCategory}',
                                ),
                                trailing: showCancel
                                    ? TextButton(
                                        onPressed: () {
                                          context.read<OrderBloc>().add(
                                            OrderCancelRequested(order.orderId),
                                          );
                                        },
                                        child: const Text('cancel this order'),
                                      )
                                    : const Text('-'),
                              );
                            },
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

  Widget _buildFilters() {
    const statuses = <String>[
      'preparing',
      'pending',
      'delivered',
      'cancelledByUser',
      'cancelledByVender',
      'returned',
    ];
    const deliveryCats = <String>['quick', 'normal'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(
                      labelText: 'Order Status',
                      border: OutlineInputBorder(),
                    ),
                    items: statuses
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _status = v);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _deliveryCategory,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Category',
                      border: OutlineInputBorder(),
                    ),
                    items: deliveryCats
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _deliveryCategory = v);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: _applyFilters,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
