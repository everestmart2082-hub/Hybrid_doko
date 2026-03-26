import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_event.dart';
import 'package:quickmartcustomer/features/cart/data/cart_model.dart';
import 'package:quickmartcustomer/features/product/ui/product_detail_page.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../data/order_model.dart';
import '../data/order_query_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String globalFilter = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchOrders();
  }

  void _fetchOrders() {
    context.read<OrderBloc>().add(const OrderFetchRequested(OrderQueryModel()));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Processing"),
            Tab(text: "On Delivery"),
            Tab(text: "Delivered"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: Column(
        children: [
          // ================= Global Search =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search orders',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (v) => setState(() => globalFilter = v.trim()),
            ),
          ),
          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {
                if (state is OrderActionSuccess) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
                if (state is OrderFailed) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is OrderLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is OrderLoaded) {
                  final allOrders = state.orders
                      .where((o) => o.productName
                          .toLowerCase()
                          .contains(globalFilter.toLowerCase()))
                      .toList();

                  final processing = allOrders
                      .where((o) => o.status.toLowerCase() == "processing")
                      .toList();
                  final onDelivery = allOrders
                      .where((o) => o.status.toLowerCase() == "on delivery")
                      .toList();
                  final delivered = allOrders
                      .where((o) => o.status.toLowerCase() == "delivered")
                      .toList();
                  final cancelled = allOrders
                      .where((o) => o.status.toLowerCase() == "cancelled")
                      .toList();

                  final tabsData = [processing, onDelivery, delivered, cancelled];

                  return TabBarView(
                    controller: _tabController,
                    children: List.generate(4, (index) {
                      final orders = tabsData[index];
                      if (orders.isEmpty) {
                        return const Center(child: Text("No orders found"));
                      }
                      return ListView.builder(
                        itemCount: orders.length,
                        itemBuilder: (context, i) => _buildOrderCard(
                            context, orders[i], index == 0, index == 2),
                      );
                    }),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, OrderModel order, bool canCancel, bool canReorder) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(productId: order.productId),
              ),
            );
          },
          child: CircleAvatar(
            child: Text(order.productName.isNotEmpty
                ? order.productName[0].toUpperCase()
                : "?"),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailPage(productId: order.productId),
              ),
            );
          },
          child: Text(order.productName,
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Status: ${order.status}"),
            Text("Delivery: ${order.deliveryCategory}"),
            Text("Rider: ${order.riderName} (${order.riderNumber})"),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (canCancel)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                tooltip: "Cancel Order",
                onPressed: () {
                  context.read<OrderBloc>().add(OrderCancelRequested(order.orderId));
                },
              ),
            if (canReorder)
              IconButton(
                icon: const Icon(Icons.add_shopping_cart, color: Colors.green),
                tooltip: "Reorder",
                onPressed: () {
                  // needs a for loop 
                  ////
                  //////
                  /////
                  ///
                  context.read<CartBloc>().add(CartAddRequested(CartAddRequestModel(productId: order.orderId, number: 1)));
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Added to cart")));
                },
              ),
          ],
        ),
      ),
    );
  }
}