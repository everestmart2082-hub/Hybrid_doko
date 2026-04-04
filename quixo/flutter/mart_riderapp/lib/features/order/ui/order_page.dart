import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/features/order/bloc/order_bloc.dart';
import 'package:quickmartrider/features/order/bloc/order_event.dart';
import 'package:quickmartrider/features/order/bloc/order_state.dart';
import 'package:quickmartrider/features/order/data/order_model.dart';
import 'package:quickmartrider/features/order/data/otp_model.dart';
import 'package:quickmartrider/ui/web_shell.dart';

class RiderOrdersTabsPage extends StatefulWidget {
  const RiderOrdersTabsPage({super.key});

  @override
  State<RiderOrdersTabsPage> createState() => _RiderOrdersTabsPageState();
}

class _RiderOrdersTabsPageState extends State<RiderOrdersTabsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  int _page = 1;
  final int _limit = 20;

  String? _deliverOrderId;

  static const _tabs = <_OrderTab>[
    _OrderTab(label: 'Preparing', status: 'prepared'),
    _OrderTab(label: 'Pending', status: 'accepted'),
    _OrderTab(label: 'Delivered', status: 'delivered'),
    _OrderTab(label: 'CancelledByUser', status: 'cancelled'),
    _OrderTab(label: 'CancelledByVender', status: 'cancelled'),
    _OrderTab(label: 'Returned', status: 'rejected'),
  ];

  _OrderTab get _activeTab => _tabs[_tabController.index];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);

    _fetchForActiveTab();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    setState(() => _page = 1);
    _fetchForActiveTab();
  }

  void _fetchForActiveTab() {
    context.read<RiderOrderBloc>().add(
          RiderOrderFetchRequested(
            page: _page,
            limit: _limit,
            searchText: null,
            status: _activeTab.status,
            deliveryCategory: null,
          ),
        );
  }

  Future<String?> _showDeliverOtpDialog() async {
    final otpCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: otpCtrl,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final otp = otpCtrl.text.trim();
                if (otp.length != 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP must be 6 digits')),
                  );
                  return;
                }
                Navigator.pop(context, otp);
              },
              child: const Text('Okay'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showRejectReasonDialog() async {
    final reasonCtrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Order'),
          content: TextField(
            controller: reasonCtrl,
            minLines: 1,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final reason = reasonCtrl.text.trim();
                if (reason.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reason is required')),
                  );
                  return;
                }
                Navigator.pop(context, reason);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  void _onAccept(String orderId) {
    context.read<RiderOrderBloc>().add(
          RiderOrderAcceptRequested(
            AcceptOrderModel(orderId: orderId),
          ),
        );
  }

  void _onGenerateOtpForDeliver(String orderId) {
    _deliverOrderId = orderId;
    context.read<RiderOrderBloc>().add(
          RiderOrderGenerateOtp(
            GenerateOtpModel(orderId: orderId),
          ),
        );
  }

  void _onDeliver(String orderId, String otp) {
    context.read<RiderOrderBloc>().add(
          RiderOrderDelivered(
            DeliverOrderOtpModel(orderId: orderId, otp: otp),
          ),
        );
  }

  void _onReject(String orderId) {
    context.read<RiderOrderBloc>().add(
          RiderOrderRejectRequested(
            RejectOrderModel(orderId: orderId),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Orders',
      bottom: TabBar(
        indicatorColor: Theme.of(context).primaryColor,
        controller: _tabController,
        isScrollable: true,
        tabs: _tabs.map((t) => Tab(child: Text(t.label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight),),)).toList(),
      ),
      child: BlocListener<RiderOrderBloc, RiderOrderState>(
        listener: (context, state) async {
          if (state is RiderOrderActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is RiderOrderDeliveredSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is RiderOrderActionFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          } else if (state is RiderOrderFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }

          if (state is RiderOrderOtpGenerated) {
            final orderId = _deliverOrderId;
            if (orderId == null) return;
            final otp = await _showDeliverOtpDialog();
            if (!mounted) return;
            if (otp != null) {
              _onDeliver(orderId, otp);
            }
            _deliverOrderId = null;
          }
        },
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<RiderOrderBloc, RiderOrderState>(
                builder: (context, state) {
                  if (state is RiderOrderLoading || state is RiderOrderInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RiderOrderLoaded) {
                    final orders = state.orders;
                    if (orders.isEmpty) {
                      return Center(child: Text('No orders found.', style: Theme.of(context).textTheme.bodyMedium));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final group = orders[index];
                        final canAccept = _activeTab.status == 'prepared';
                        final canDeliver = _activeTab.status == 'accepted';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Orders id: ${group.orderId}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 10),
                                ...group.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: _OrderItemRow(item: item),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (canAccept)
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _onAccept(group.orderId),
                                      icon: const Icon(Icons.check_circle_outline),
                                      label: const Text('Accept Order'),
                                    ),
                                  ),
                                if (canDeliver) ...[
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () => _onGenerateOtpForDeliver(group.orderId),
                                      icon: const Icon(Icons.delivery_dining_outlined),
                                      label: const Text('Deliver'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: () async {
                                        await _showRejectReasonDialog();
                                        _onReject(group.orderId);
                                      },
                                      icon: const Icon(Icons.cancel_outlined),
                                      label: const Text('Reject Order'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  if (state is RiderOrderFailure) {
                    return Center(
                      child: Text(
                        state.message,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
            _buildPagination(),
          ],
        ),
      ),
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          TextButton(onPressed: _page <= 1 ? null : () { setState(() => _page -= 1); _fetchForActiveTab(); }, child: Text('Prev', style: Theme.of(context).textTheme.bodyMedium,)),
          const SizedBox(width: 10),
          Text('$_page', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          TextButton(onPressed: () { setState(() => _page += 1); _fetchForActiveTab(); }, child: Text('Next', style: Theme.of(context).textTheme.bodyMedium,)),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final RiderOrderItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product: ${item.productCategory}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          'Order time: ${item.orderTime}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 4),
        Text(
          'Qty: ${item.productNumber}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        if (item.deliveryCategory.isNotEmpty)
          Text(
            'Delivery: ${item.deliveryCategory}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
      ],
    );
  }
}

class _OrderTab {
  final String label;
  final String status;

  const _OrderTab({
    required this.label,
    required this.status,
  });
}
