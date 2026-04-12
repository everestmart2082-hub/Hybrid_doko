import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/notifications/bloc/admin_notifications_bloc.dart';
import 'package:mart_adminapp/features/notifications/bloc/admin_notifications_event.dart';
import 'package:mart_adminapp/features/notifications/bloc/admin_notifications_state.dart';
import 'package:mart_adminapp/features/notifications/data/admin_notification_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

enum _AdminNotificationTab { contact, order, product, miscellaneous }

extension on _AdminNotificationTab {
  String get label {
    switch (this) {
      case _AdminNotificationTab.contact:
        return 'Contact';
      case _AdminNotificationTab.order:
        return 'Order';
      case _AdminNotificationTab.product:
        return 'Product';
      case _AdminNotificationTab.miscellaneous:
        return 'Miscellaneous';
    }
  }

  bool matches(AdminNotificationItem n) {
    switch (this) {
      case _AdminNotificationTab.contact:
        return n.isContact;
      case _AdminNotificationTab.order:
        return n.isOrder;
      case _AdminNotificationTab.product:
        return n.isProduct;
      case _AdminNotificationTab.miscellaneous:
        return n.isMiscellaneous;
    }
  }
}

class AdminNotificationsPage extends StatefulWidget {
  const AdminNotificationsPage({super.key});

  @override
  State<AdminNotificationsPage> createState() => _AdminNotificationsPageState();
}

class _AdminNotificationsPageState extends State<AdminNotificationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<AdminNotificationsBloc>().add(const AdminNotificationsLoad());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Notifications',
      child: BlocBuilder<AdminNotificationsBloc, AdminNotificationsState>(
        builder: (context, state) {
          if (state is AdminNotificationsLoading ||
              state is AdminNotificationsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminNotificationsFailed) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context
                          .read<AdminNotificationsBloc>()
                          .add(const AdminNotificationsLoad()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is AdminNotificationsLoaded) {
            final items = state.items;
            return Column(
              children: [
                Material(
                  color: Theme.of(context).primaryColorLight,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: _AdminNotificationTab.values
                        .map((e) => Tab(text: e.label))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _AdminNotificationTab.values
                        .map((tab) => _NotificationList(
                              items: items
                                  .where((n) => tab.matches(n))
                                  .toList(),
                            ))
                        .toList(),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<AdminNotificationItem> items;

  const _NotificationList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No notifications',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    final sorted = List<AdminNotificationItem>.from(items)
      ..sort((a, b) => b.date.compareTo(a.date));
    return RefreshIndicator(
      onRefresh: () async {
        context.read<AdminNotificationsBloc>().add(const AdminNotificationsLoad());
        await context.read<AdminNotificationsBloc>().stream.firstWhere(
              (s) =>
                  s is AdminNotificationsLoaded ||
                  s is AdminNotificationsFailed,
            );
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: sorted.length,
        itemBuilder: (context, i) {
          final n = sorted[i];
          final typeLabel =
              n.type.isEmpty ? 'notification' : n.type;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      typeLabel,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (n.received)
                    const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(Icons.done_all, size: 18),
                    ),
                ],
              ),
              subtitle: Text(
                '${n.date}\n'
                '${n.message.isEmpty ? '(no message)' : n.message}\n'
                'target: ${n.targetId}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }
}
