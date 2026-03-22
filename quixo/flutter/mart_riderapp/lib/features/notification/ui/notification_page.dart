import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../data/notification_model.dart';

class RiderNotificationPage extends StatefulWidget {
  const RiderNotificationPage({super.key});

  @override
  State<RiderNotificationPage> createState() => _RiderNotificationPageState();
}

class _RiderNotificationPageState extends State<RiderNotificationPage> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
    _scrollController.addListener(_onScroll);
  }

  void _fetchNotifications() {
    context.read<RiderNotificationBloc>().add(
          RiderNotificationFetchRequested(
            page: _currentPage,
            limit: _limit,
          ),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _currentPage++;
      _fetchNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RiderNotificationBloc, RiderNotificationState>(
      builder: (context, state) {
        if (state is RiderNotificationLoading || state is RiderNotificationInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RiderNotificationLoaded) {
          if (state.notifications.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: state.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = state.notifications[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(item.message),
                  subtitle: Text(item.date.toString()),
                  leading: const Icon(Icons.notifications),
                ),
              );
            },
          );
        } else if (state is RiderNotificationFailure) {
          return Center(
            child: Text(
              state.message,
              style: const TextStyle(color: Colors.red),
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}