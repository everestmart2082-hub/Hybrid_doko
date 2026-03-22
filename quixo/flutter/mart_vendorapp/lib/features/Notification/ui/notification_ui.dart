import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/notifications/notifications.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../data/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {

  final int pageSize = 20;
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    context.read<NotificationBloc>().add(
      LoadNotifications(page: currentPage, limit: pageSize)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications")),

      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) => {
          if (state is NotificationLoaded) {
            for (var n in state.notifications) {
              showNotification("New Notification", n.message)
            }
          }
        },
        builder: (context, state) {

          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationLoaded) {

            if(state.notifications.isEmpty) {
              return const Center(child: Text("No notifications"));
            }

            return ListView.builder(
              itemCount: state.notifications.length,
              itemBuilder: (context, i) {
                final NotificationModel n = state.notifications[i];

                return ListTile(
                  leading: const Icon(Icons.notifications),
                  title: Text(n.message),
                  subtitle: Text(n.date),
                );
              },
            );
          }

          if (state is NotificationFailed) {
            return Center(child: Text(state.message));
          }

          return const SizedBox();
        },
      ),
    );
  }
}