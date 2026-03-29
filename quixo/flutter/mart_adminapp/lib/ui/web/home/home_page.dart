import 'package:flutter/material.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

/// Home / Dashboard page — shows summary stats cards.
/// Data is currently placeholder since there is no dedicated dashboard endpoint;
/// real numbers will come once a dashboard API is added.
class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Dashboard',
      child: SingleChildScrollView(
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
            _StatsGrid(stats: const [
              _Stat('Total Revenue', 'Rs. —', Icons.monetization_on),
              _Stat('Orders — Preparing', '—', Icons.hourglass_top),
              _Stat('Orders — Delivered', '—', Icons.check_circle),
              _Stat('Orders — Cancelled', '—', Icons.cancel),
              _Stat('Riders — Verified', '—', Icons.two_wheeler),
              _Stat('Riders — Suspended', '—', Icons.block),
              _Stat('Vendors — Verified', '—', Icons.store),
              _Stat('Vendors — Suspended', '—', Icons.store_mall_directory),
              _Stat('Employees — Active', '—', Icons.badge),
              _Stat('Products — Approved', '—', Icons.inventory),
              _Stat('Products — Hidden', '—', Icons.visibility_off),
              _Stat('Total Categories', '—', Icons.category),
            ]),
          ],
        ),
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
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(s.label,
                      style: Theme.of(context).textTheme.bodySmall,
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
