import 'package:flutter/material.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

/// Home / Dashboard page — shows summary stats cards.
/// Data is currently placeholder since there is no dedicated dashboard endpoint;
/// real numbers will come once a dashboard API is added.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  Future<Map<String, dynamic>> _loadDashboard() async {
    final dio = DioClient(baseUrl: ApiEndpoints.baseUrl);
    final map = await dio.post(ApiEndpoints.adminDashboard, {});
    if (map is Map<String, dynamic> && map['success'] == true) {
      return (map['message'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{};
    }
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Dashboard',
      child: FutureBuilder<Map<String, dynamic>>(
        future: _loadDashboard(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final d = snapshot.data!;
          final stats = <_Stat>[
            _Stat('Total Revenue', 'Rs. ${d['total_revenue'] ?? 0}', Icons.monetization_on),
            _Stat('Orders — Preparing', '${d['orders_preparing'] ?? 0}', Icons.hourglass_top),
            _Stat('Orders — Pending', '${d['orders_pending'] ?? 0}', Icons.pending_actions),
            _Stat('Orders — Delivered', '${d['orders_delivered'] ?? 0}', Icons.check_circle),
            _Stat('Orders — Cancelled', '${d['orders_cancelled'] ?? 0}', Icons.cancel),
            _Stat('Riders — Verified', '${d['riders_verified'] ?? 0}', Icons.two_wheeler),
            _Stat('Riders — Suspended', '${d['riders_suspended'] ?? 0}', Icons.block),
            _Stat('Vendors — Verified', '${d['vendors_verified'] ?? 0}', Icons.store),
            _Stat('Vendors — Suspended', '${d['vendors_suspended'] ?? 0}', Icons.store_mall_directory),
            _Stat('Products — Approved', '${d['products_approved'] ?? 0}', Icons.inventory),
            _Stat('Products — Hidden', '${d['products_hidden'] ?? 0}', Icons.visibility_off),
            _Stat('Total Customers', '${d['customers_total'] ?? 0}', Icons.people),
          ];
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Overview',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _StatsGrid(stats: stats),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Stat {
  final String label;
  final String value;
  final IconData icon;
  const _Stat(this.label, this.value, this.icon);
}

class _StatsGrid extends StatelessWidget {
  final List<_Stat> stats;
  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth > 900
          ? 4
          : constraints.maxWidth > 600
              ? 3
              : 2;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: 1.6,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
        ),
        itemCount: stats.length,
        itemBuilder: (_, i) {
          final s = stats[i];
          return Card(
            elevation: 3,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(s.icon,
                      color: Theme.of(context).primaryColor, size: 28),
                  const SizedBox(height: 8),
                  Text(s.value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                  const SizedBox(height: 4),
                  Text(s.label,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
