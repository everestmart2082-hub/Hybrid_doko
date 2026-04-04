import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/Order/bloc/order_bloc.dart';
import 'package:quickmartvender/features/Order/bloc/order_event.dart';
import 'package:quickmartvender/features/Order/bloc/order_state.dart';
import 'package:quickmartvender/features/Order/data/order_model.dart';
import '../web_shell.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  static const _statuses = [
    'Preparing', 'Prepared', 'Delivered',
    'CancelledByUser', 'CancelledByVender', 'Returned',
  ];

  int _page = 1;
  String _search = '';
  String _deliveryCategory = '';

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: _statuses.length, vsync: this)
      ..addListener(() {
        if (!_tabs.indexIsChanging) _load();
      });
    _load();
  }

  void _load() {
    context.read<OrderBloc>().add(LoadOrders(
      page: _page,
      limit: 15,
      searchText: _search,
      status: _statuses[_tabs.index],
      deliveryCategory: _deliveryCategory,
    ));
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Orders',
      child: Column(
        children: [
          // ── Tab bar ──────────────────────────────────────
          TabBar(
            controller: _tabs,
            isScrollable: true,
            indicatorColor: Theme.of(context).primaryColor,
            labelStyle: Theme.of(context).textTheme.bodyLarge,
            tabs: _statuses.map((s) => Tab(text: s)).toList(),
          ),
          // ── Filter row ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (v) {
                      _search = v;
                      setState(() => _page = 1);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: Theme.of(context).primaryColorLight,
                    iconEnabledColor: Theme.of(context).primaryColorDark,
                    decoration: const InputDecoration(
                      labelText: 'Delivery Category',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    value: _deliveryCategory.isEmpty ? null : _deliveryCategory,
                    hint: const Text('All'),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('All')),
                      DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                      DropdownMenuItem(value: 'Quick', child: Text('Quick')),
                    ],
                    onChanged: (v) {
                      setState(() { _deliveryCategory = v ?? ''; _page = 1; });
                      _load();
                    },
                  ),
                ),
              ],
            ),
          ),
          // ── Tab views ────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: _statuses.map((status) {
                // Only the "Preparing" tab (index 0) shows the Prepared button
                final showAction = status == 'Preparing';
                return BlocBuilder<OrderBloc, OrderState>(
                  builder: (context, state) {
                    if (state is OrderLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is OrderError) {
                      return Center(child: Text(state.message));
                    }
                    if (state is OrderLoaded) {
                      return _buildList(state.orders, showAction);
                    }
                    return const SizedBox();
                  },
                );
              }).toList(),
            ),
          ),
          // ── Pagination ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _page > 1
                      ? () { setState(() => _page--); _load(); }
                      : null,
                ),
                Text('Page $_page'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () { setState(() => _page++); _load(); },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<VendorOrder> orders, bool showPreparedButton) {
    if (orders.isEmpty) {
      return const Center(child: Text('No orders found.'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _OrderCard(
        order: orders[i],
        showPreparedButton: showPreparedButton,
        onPrepared: () {
          context.read<OrderBloc>().add(PrepareOrder(orders[i].orderId));
          // Reload after a short delay
          Future.delayed(const Duration(milliseconds: 400), _load);
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final VendorOrder order;
  final bool showPreparedButton;
  final VoidCallback onPrepared;
  const _OrderCard({
    required this.order,
    required this.showPreparedButton,
    required this.onPrepared,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      color: theme.primaryColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.primaryColorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.image, color: theme.primaryColor, size: 36),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order.orderId}',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.primaryColorLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(order.orderStatus,
                            style: TextStyle(fontSize: 11, color: theme.primaryColorDark)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Category: ${order.productCategory}',
                      style: theme.textTheme.bodySmall),
                  Text('Delivery: ${order.deliveryCategory}',
                      style: theme.textTheme.bodySmall),
                  Text('Date: ${order.orderTime}',
                      style: theme.textTheme.bodySmall),
                  Text('Qty: ${order.productNumber}',
                      style: theme.textTheme.bodySmall),
                  if (order.riderName.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('Rider: ${order.riderName} | ${order.riderNumber}',
                        style: theme.textTheme.bodySmall),
                  ],
                  if (showPreparedButton) ...[
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: onPrepared,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                      child: const Text('Mark as Prepared'),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
