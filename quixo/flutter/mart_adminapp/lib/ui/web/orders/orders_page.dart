import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/orders/bloc/admin_order_bloc.dart';
import 'package:mart_adminapp/features/orders/bloc/admin_order_event.dart';
import 'package:mart_adminapp/features/orders/bloc/admin_order_state.dart';
import 'package:mart_adminapp/features/orders/data/admin_order_model.dart';
import 'package:mart_adminapp/features/orders/repository/admin_orders_remote.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

class AdminOrdersPage extends StatefulWidget {
  const AdminOrdersPage({super.key});

  @override
  State<AdminOrdersPage> createState() => _AdminOrdersPageState();
}

class _AdminOrdersPageState extends State<AdminOrdersPage>
    with SingleTickerProviderStateMixin {
  static const int _perPage = 10;
  late final TabController _tabController;

  final _searchCtrl = TextEditingController();
  String _deliveryCategory = 'all';
  int _page = 0;

  List<AdminOrderItem> _all = const [];

  static const _tabs = <_OrderTab>[
    _OrderTab(label: 'Preparing', status: 'preparing'),
    _OrderTab(label: 'Pending', status: 'pending'),
    _OrderTab(label: 'Delivered', status: 'delivered'),
    _OrderTab(label: 'CancelledByUser', status: 'cancelledByUser'),
    _OrderTab(label: 'CancelledByVender', status: 'cancelledByVender'),
    _OrderTab(label: 'Returned', status: 'returned'),
  ];

  _OrderTab get _activeTab => _tabs[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) return;
      setState(() => _page = 0);
    });

    context.read<AdminOrderBloc>().add(AdminOrderLoad());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<AdminOrderItem> _filtered() {
    final s = _searchCtrl.text.trim().toLowerCase();
    return _all.where((o) {
      final matchesTab = o.orderStatus == _activeTab.status;
      final matchesDelivery = _deliveryCategory == 'all'
          ? true
          : o.deliveryCategory.toLowerCase() == _deliveryCategory;
      final matchesSearch = s.isEmpty
          ? true
          : (o.orderId.toLowerCase().contains(s) ||
              o.productCategory.toLowerCase().contains(s) ||
              o.productId.toLowerCase().contains(s) ||
              o.venderId.toLowerCase().contains(s));
      return matchesTab && matchesDelivery && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Orders',
      child: BlocConsumer<AdminOrderBloc, AdminOrderState>(
        listener: (context, state) {
          if (state is AdminOrderLoaded) {
            setState(() => _all = state.orders);
          }
        },
        builder: (context, state) {
          if (state is AdminOrderLoading || (_all.isEmpty && state is! AdminOrderLoaded)) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = _filtered();
          final totalPages =
              (filtered.length / _perPage).ceil().clamp(1, 999999);
          final page = _page.clamp(0, totalPages - 1);
          final start = page * _perPage;
          final end = (start + _perPage).clamp(0, filtered.length);
          final items = filtered.sublist(start, end);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 360,
                      child: TextField(
                        style: Theme.of(context).textTheme.bodyLarge,
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          labelText: 'Search',
                          border: OutlineInputBorder(borderSide: BorderSide(color: Theme.of(context).primaryColorLight)),
                          labelStyle: Theme.of(context).textTheme.bodyMedium
                          
                        ),
                        onChanged: (_) => setState(() => _page = 0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    DropdownButton<String>(
                      dropdownColor: Theme.of(context).primaryColorLight,
                      iconEnabledColor: Theme.of(context).primaryColorDark,
                      value: _deliveryCategory,
                      onChanged: (v) {
                        setState(() {
                          _deliveryCategory = v ?? 'all';
                          _page = 0;
                        });
                      },
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All delivery categories')),
                        DropdownMenuItem(value: 'normal', child: Text('Normal')),
                        DropdownMenuItem(value: 'quick', child: Text('Quick')),
                      ],
                    ),
                  ],
                ),
              ),
              TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                controller: _tabController,
                isScrollable: true,
                tabs: _tabs.map((t) => Tab(child: Text(t.label,style: Theme.of(context).textTheme.bodyLarge,),)).toList(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final o = items[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'orders id: ${o.orderId}',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 10),
                            _InfoRow(label: 'product category', value: o.productCategory),
                            _InfoRow(label: 'product id', value: o.productId),
                            _InfoRow(label: 'quantity', value: o.productNumber.toString()),
                            _InfoRow(label: 'vender id', value: o.venderId),
                            _InfoRow(label: 'vendor name', value: o.vendorName),
                            _InfoRow(label: 'user', value: '${o.userName} (${o.userNumber})'),
                            _InfoRow(label: 'rider', value: o.riderName.isEmpty ? 'Not assigned' : '${o.riderName} (${o.riderNumber})'),
                            _InfoRow(label: 'order date', value: o.orderTime),
                            _InfoRow(label: 'delivary category', value: o.deliveryCategory),
                            _InfoRow(label: 'order status', value: o.orderStatus),
                            const SizedBox(height: 8),
                            if(_tabController.index == 0 || _tabController.index == 1)
                            OutlinedButton(
                              onPressed: () async {
                                final ctrl = TextEditingController(text: o.riderId);
                                final riderId = await showDialog<String>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Assign Rider'),
                                    content: TextField(
                                      controller: ctrl,
                                      decoration: const InputDecoration(
                                        labelText: 'Rider ID',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.pop(context, ctrl.text.trim()), child: const Text('Assign')),
                                    ],
                                  ),
                                );
                                if (riderId == null || riderId.isEmpty) return;
                                try {
                                  await context.read<AdminOrdersRemote>().assignRider(
                                        ordersId: o.ordersId.isEmpty ? o.orderId : o.ordersId,
                                        riderId: riderId,
                                      );
                                  if (!context.mounted) return;
                                  context.read<AdminOrderBloc>().add(AdminOrderLoad());
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                                  );
                                }
                              },
                              child: Text(o.riderId.isEmpty ? 'Assign Rider' : 'Change Rider'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              _Pagination(
                page: page,
                totalPages: totalPages,
                onPrev: page > 0 ? () => setState(() => _page = page - 1) : null,
                onNext: page < totalPages - 1 ? () => setState(() => _page = page + 1) : null,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$label: ', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          Flexible(child: Text(value, style: Theme.of(context).textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int page;
  final int totalPages;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;

  const _Pagination({
    required this.page,
    required this.totalPages,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          TextButton(onPressed: onPrev, child: Text('Prev', style: Theme.of(context).textTheme.bodyMedium,)),
          const SizedBox(width: 10),
          Text('${page + 1} / $totalPages', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          TextButton(onPressed: onNext, child: Text('Next', style: Theme.of(context).textTheme.bodyMedium,)),
        ],
      ),
    );
  }
}

class _OrderTab {
  final String label;
  final String status;
  const _OrderTab({required this.label, required this.status});
}

