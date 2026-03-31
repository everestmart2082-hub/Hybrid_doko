import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:quickmartcustomer/features/notification/bloc/notification_bloc.dart';
import 'package:quickmartcustomer/features/notification/bloc/notification_event.dart';
import 'package:quickmartcustomer/features/notification/bloc/notification_state.dart';
import 'package:quickmartcustomer/features/notification/data/notification_query_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<NotificationBloc>()
        .add(const NotificationFetchRequested(NotificationQueryModel()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading || state is NotificationInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NotificationLoaded) {
              final notifications = state.notifications;
              if (notifications.isEmpty) {
                return const Center(child: Text('No notifications'));
              }
              return ListView.separated(
                itemCount: notifications.length,
                separatorBuilder: (_, __) => const Divider(height: 20),
                itemBuilder: (context, index) {
                  final n = notifications[index];
                  return ListTile(
                    title: Text(n.message),
                    subtitle: Text(n.date),
                  );
                },
              );
            }
            if (state is NotificationFailed) {
              return Center(child: Text(state.message));
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

