import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/features/notification/bloc/notification_bloc.dart';
import 'package:quickmartrider/features/notification/bloc/notification_event.dart';
import 'package:quickmartrider/features/notification/bloc/notification_state.dart';
import 'package:quickmartrider/features/notification/data/notification_model.dart';
import 'package:quickmartrider/ui/web_shell.dart';

class RiderNotificationPage extends StatefulWidget {
  const RiderNotificationPage({super.key});

  @override
  State<RiderNotificationPage> createState() => _RiderNotificationPageState();
}

class _RiderNotificationPageState extends State<RiderNotificationPage> {
  int _page = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    context
        .read<RiderNotificationBloc>()
        .add(RiderNotificationFetchRequested(page: _page, limit: _limit));
  }

  void _fetch() {
    context
        .read<RiderNotificationBloc>()
        .add(RiderNotificationFetchRequested(page: _page, limit: _limit));
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: 'Notifications',
      child: Column(
        children: [
          Expanded(
            child: BlocBuilder<RiderNotificationBloc, RiderNotificationState>(
              builder: (context, state) {
                if (state is RiderNotificationInitial ||
                    state is RiderNotificationLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is RiderNotificationLoaded) {
                  final notifications = state.notifications;
                  if (notifications.isEmpty) {
                    return Center(child: Text('No notifications.', style: Theme.of(context).textTheme.bodyMedium));
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _NotificationCard(notification: n);
                    },
                  );
                }

                if (state is RiderNotificationFailure) {
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
    );
  }

  Widget _buildPagination() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          TextButton(
            onPressed: _page <= 1
                ? null
                : () {
                    setState(() => _page -= 1);
                    _fetch();
                  },
            child: Text('Prev', style: Theme.of(context).textTheme.bodyMedium),
          ),
          const SizedBox(width: 8),
          Text('$_page', style: Theme.of(context).textTheme.bodyMedium),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() => _page += 1);
              _fetch();
            },
            child: Text('Next', style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final RiderNotificationModel notification;

  const _NotificationCard({
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).primaryColorLight,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'date: ${notification.date}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
