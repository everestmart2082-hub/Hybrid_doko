import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_bloc.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_event.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_state.dart';
import 'package:mart_adminapp/features/profile/data/admin_profile_model.dart';
import 'package:mart_adminapp/ui/web/web_shell.dart';

enum _AdminInboxTab { contact, order, product, register, others }

extension on _AdminInboxTab {
  String get label {
    switch (this) {
      case _AdminInboxTab.contact:
        return 'Contact';
      case _AdminInboxTab.order:
        return 'Order';
      case _AdminInboxTab.product:
        return 'Product';
      case _AdminInboxTab.register:
        return 'Register';
      case _AdminInboxTab.others:
        return 'Others';
    }
  }

  bool matches(AdminInboxMessage m) {
    final t = m.type.toLowerCase().trim();
    switch (this) {
      case _AdminInboxTab.contact:
        return t == 'contact';
      case _AdminInboxTab.order:
        return t == 'order';
      case _AdminInboxTab.product:
        return t == 'product';
      case _AdminInboxTab.register:
        return t == 'register';
      case _AdminInboxTab.others:
        return t != 'contact' &&
            t != 'order' &&
            t != 'product' &&
            t != 'register';
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
    _tabController = TabController(length: 5, vsync: this);
    context.read<AdminProfileBloc>().add(AdminProfileLoad());
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
      child: BlocBuilder<AdminProfileBloc, AdminProfileState>(
        builder: (context, state) {
          if (state is AdminProfileLoading || state is AdminProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AdminProfileFailed) {
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
                          .read<AdminProfileBloc>()
                          .add(AdminProfileLoad()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is AdminProfileLoaded) {
            final msgs = state.profile.messages;
            return Column(
              children: [
                Material(
                  color: Theme.of(context).primaryColorLight,
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabs: _AdminInboxTab.values
                        .map((e) => Tab(text: e.label))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _AdminInboxTab.values
                        .map((tab) => _MessageList(
                              messages: msgs
                                  .where((m) => tab.matches(m))
                                  .toList()
                                  .reversed
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

class _MessageList extends StatelessWidget {
  final List<AdminInboxMessage> messages;

  const _MessageList({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, i) {
        final m = messages[i];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              m.type.isEmpty ? 'message' : m.type,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${m.date}\n${m.message}'),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
