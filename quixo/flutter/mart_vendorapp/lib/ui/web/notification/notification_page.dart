import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/features/Notification/bloc/notification_bloc.dart';
import 'package:quickmartvender/features/Notification/bloc/notification_event.dart';
import 'package:quickmartvender/features/Notification/bloc/notification_state.dart';
import '../web_shell.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int _page = 1;
  static const int _limit = 15;

  void _load() {
    context.read<NotificationBloc>().add(
          LoadNotifications(page: _page, limit: _limit),
        );
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return WebShell(
      title: 'Notifications',
      child: BlocBuilder<NotificationBloc, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NotificationFailed) {
            return Center(child: Text(state.message));
          }
          if (state is NotificationLoaded) {
            if (state.notifications.isEmpty) {
              return const Center(child: Text('No notifications.'));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: state.notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final n = state.notifications[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.primaryColorLight,
                          child: Text(
                            '${i + 1 + (_page - 1) * _limit}',
                            style: TextStyle(color: theme.primaryColorDark, fontSize: 12),
                          ),
                        ),
                        title: Text(n.message),
                        trailing: Text(
                          n.date.isEmpty ? '—' : n.date,
                          style: theme.textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
                ),
                // Pagination
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _page > 1
                            ? () { setState(() => _page--); _load(); }
                            : null,
                      ),
                      Text('Page $_page'),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: state.notifications.length == _limit
                            ? () { setState(() => _page++); _load(); }
                            : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
