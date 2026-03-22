import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import 'order_card.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {

  final searchController = TextEditingController();

  String status = "";
  String deliveryCategory = "";

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {

    context.read<OrderBloc>().add(
      LoadOrders(
        searchText: searchController.text,
        status: status,
        deliveryCategory: deliveryCategory,
      ),
    );
  }

  void _openFilters() {

    showModalBottomSheet(
      context: context,
      builder: (_) {

        return Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [

              const Text(
                "Filters",
                style: TextStyle(fontSize: 18),
              ),

              DropdownButtonFormField(
                decoration: const InputDecoration(labelText: "Order Status"),
                items: const [

                  DropdownMenuItem(
                    value: "",
                    child: Text("All"),
                  ),

                  DropdownMenuItem(
                    value: "pending",
                    child: Text("Pending"),
                  ),

                  DropdownMenuItem(
                    value: "prepared",
                    child: Text("Prepared"),
                  ),

                  DropdownMenuItem(
                    value: "delivered",
                    child: Text("Delivered"),
                  ),

                ],
                onChanged: (v) => status = v ?? "",
              ),

              DropdownButtonFormField(
                decoration:
                    const InputDecoration(labelText: "Delivery Category"),

                items: const [

                  DropdownMenuItem(
                    value: "",
                    child: Text("All"),
                  ),

                  DropdownMenuItem(
                    value: "quick",
                    child: Text("Quick Delivery"),
                  ),

                  DropdownMenuItem(
                    value: "ecommerce",
                    child: Text("E-Commerce"),
                  ),
                ],

                onChanged: (v) => deliveryCategory = v ?? "",
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {

                  Navigator.pop(context);
                  _loadOrders();

                },
                child: const Text("Apply Filters"),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Orders"),

        actions: [

          IconButton(
            icon: const Icon(Icons.filter_alt),
            onPressed: _openFilters,
          )

        ],
      ),

      body: Column(
        children: [

          /// SEARCH
          Padding(
            padding: const EdgeInsets.all(12),

            child: TextField(
              controller: searchController,

              decoration: InputDecoration(
                hintText: "Search orders",

                prefixIcon: const Icon(Icons.search),

                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _loadOrders,
                ),
              ),
            ),
          ),

          Expanded(
            child: BlocConsumer<OrderBloc, OrderState>(
              listener: (context, state) {

                if (state is OrderPrepared) {

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  );

                  _loadOrders();
                }
              },

              builder: (context, state) {

                if (state is OrderLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (state is OrderLoaded) {

                  return ListView.builder(
                    itemCount: state.orders.length,

                    itemBuilder: (context, i) {

                      final order = state.orders[i];

                      return OrderCard(order: order);
                    },
                  );
                }

                if (state is OrderError) {
                  return Center(child: Text(state.message));
                }

                return const SizedBox();
              },
            ),
          )
        ],
      ),
    );
  }
}