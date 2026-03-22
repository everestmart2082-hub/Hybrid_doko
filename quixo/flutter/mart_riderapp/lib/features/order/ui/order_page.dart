import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../data/order_model.dart';
import '../data/otp_model.dart';

class RiderOrdersTabsPage extends StatefulWidget {
  const RiderOrdersTabsPage({super.key});

  @override
  State<RiderOrdersTabsPage> createState() => _RiderOrdersTabsPageState();
}

class _RiderOrdersTabsPageState extends State<RiderOrdersTabsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<int, String> _tabStatusMap = {
    0: "pending", // Preparing / Pending
    1: "ongoing", // Ongoing / In Progress
    2: "delivered", // Delivered
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _fetchOrdersForTab(_tabController.index);
      }
    });

    // Load initial tab
    _fetchOrdersForTab(0);
  }

  void _fetchOrdersForTab(int index) {
    final status = _tabStatusMap[index];
    context.read<RiderOrderBloc>().add(
          RiderOrderFetchRequested(
            status: status,
            page: 1,
            limit: 20,
          ),
        );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: "Preparing"),
            Tab(text: "Ongoing"),
            Tab(text: "Delivered"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _OrdersTabContent(status: "pending"),
              _OrdersTabContent(status: "ongoing"),
              _OrdersTabContent(status: "delivered"),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrdersTabContent extends StatelessWidget {
  final String status;
  const _OrdersTabContent({required this.status});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderOrderBloc, RiderOrderState>(
      builder: (context, state) {
        if (state is RiderOrderLoading || state is RiderOrderInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RiderOrderLoaded) {
          final filteredOrders = state.orders
              .where((group) => group.items.any((i) => i.orderStatus == status))
              .toList();

          if (filteredOrders.isEmpty) {
            return const Center(child: Text("No orders in this category."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildOrderCard(context, filteredOrders[index], status);
            },
          );
        } else if (state is RiderOrderFailure) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, RiderOrderGroup group, String tabStatus) {
    final relevantItems = group.items.where((i) => i.orderStatus == tabStatus).toList();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order ID: ${group.orderId}",
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Column(
              children: relevantItems.map((item) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(item.productCategory),
                  subtitle: Text(
                      "Qty: ${item.productNumber} | Delivery: ${item.deliveryCategory}\nTime: ${item.orderTime}"),
                  trailing: tabStatus == "pending"
                      ? ElevatedButton(
                          onPressed: () {
                            context.read<RiderOrderBloc>().add(
                                  RiderOrderGenerateOtp(
                                    GenerateOtpModel(orderId: item.orderId),
                                  ),
                                );
                          },
                          child: const Text("Generate OTP"),
                        )
                      : tabStatus == "ongoing"
                          ? SizedBox(
                              width: 120,
                              child: TextField(
                                decoration: const InputDecoration(
                                  hintText: "Enter OTP",
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onSubmitted: (value) {
                                  context.read<RiderOrderBloc>().add(
                                        RiderOrderDelivered(
                                          DeliverOrderOtpModel(
                                              orderId: item.orderId, otp: value),
                                        ),
                                      );
                                },
                              ),
                            )
                          : Text(item.orderStatus),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}