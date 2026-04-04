import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_bloc.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_event.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_state.dart';
import 'package:quickmartvender/features/Dashboard/data/dashboard_model.dart';
import '../web_shell.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Dashboard',
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(child: Text(state.message));
          }
          if (state is DashboardLoaded) {
            return _buildContent(state.stats);
          }
          return const Center(child: Text('Loading dashboard...'));
        },
      ),
    );
  }

  Widget _buildContent(DashboardStatsModel s) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Orders section ──────────────────────────────────
          _sectionTitle('Orders'),
          const SizedBox(height: 12),
          _statsGrid([
            _StatCard('Total Orders', s.totalOrders, Icons.receipt_long, Colors.blue),
            _StatCard('Preparing', s.preparingOrders, Icons.hourglass_top, Colors.orange),
            _StatCard('Prepared', s.preparedOrders, Icons.check_circle_outline, Colors.teal),
            _StatCard('Delivered', s.deliveredOrders, Icons.local_shipping, Colors.green),
            _StatCard('Cancelled (User)', s.cancelledByUserOrders, Icons.cancel_outlined, Colors.red),
            _StatCard('Cancelled (Vendor)', s.cancelledByVendorOrders, Icons.block, Colors.deepOrange),
            _StatCard('Returned', s.returnedOrders, Icons.keyboard_return, Colors.purple),
          ]),

          const SizedBox(height: 28),

          // ── Revenue & Chart ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Revenue card
              Expanded(
                flex: 1,
                child: Card(
                  elevation: 2,
                  color: Theme.of(context).primaryColorLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Revenue',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(
                          'Rs ${s.totalRevenue.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Chart
              Expanded(
                flex: 2,
                child: Card(
                  elevation: 2,
                  color: Theme.of(context).primaryColorLight,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue Chart',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        _SimpleBarChart(data: s.chart),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ── Products section ──────────────────────────────────
          _sectionTitle('Products'),
          const SizedBox(height: 12),
          _statsGrid([
            _StatCard('Total Products', s.totalProducts, Icons.inventory, Colors.indigo),
            _StatCard('Out of Stock', s.outOfStockProducts, Icons.remove_shopping_cart, Colors.red),
            _StatCard('Low Stock', s.lowStockProducts, Icons.warning_amber, Colors.amber),
            _StatCard('Active', s.activeProducts, Icons.toggle_on, Colors.green),
            _StatCard('Inactive', s.inactiveProducts, Icons.toggle_off, Colors.grey),
          ]),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _statsGrid(List<_StatCard> cards) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: cards
          .map((c) => SizedBox(width: 160, child: _buildStatCard(c)))
          .toList(),
    );
  }

  Widget _buildStatCard(_StatCard c) {
    return Card(
      elevation: 2,
      color: Theme.of(context).primaryColorLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(c.icon, color: c.color, size: 28),
            const SizedBox(height: 10),
            Text(
              c.value.toString(),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: c.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(c.label,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _StatCard {
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  const _StatCard(this.label, this.value, this.icon, this.color);
}

class _SimpleBarChart extends StatelessWidget {
  final List<VendorChartData> data;
  const _SimpleBarChart({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 120,
        child: Center(child: Text('No chart data')),
      );
    }
    final maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final color = Theme.of(context).primaryColor;

    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final frac = maxVal > 0 ? item.value / maxVal : 0.0;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(item.value.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 10)),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    child: Container(
                      height: 80 * frac,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.label,
                      style: const TextStyle(fontSize: 9),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
