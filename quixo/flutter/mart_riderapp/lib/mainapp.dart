import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/core/constants/app_constants.dart';
import 'package:quickmartrider/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartrider/features/auth/bloc/auth_event.dart';
import 'package:quickmartrider/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:quickmartrider/features/dashboard/bloc/dashboard_event.dart';
import 'package:quickmartrider/features/dashboard/bloc/dashboard_state.dart';
import 'package:quickmartrider/features/dashboard/data/dashboard_model.dart';
import 'package:quickmartrider/ui/web_shell.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    context.read<RiderAuthBloc>().add(AuthCheck());
    context.read<RiderDashboardBloc>().add(RiderDashboardFetchRequested());
  }

  @override
  Widget build(BuildContext context) {
    return WebShell(
      title: AppConstants.appName,
      child: BlocBuilder<RiderDashboardBloc, RiderDashboardState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dashboard",
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 20),
                _buildDashboardContent(state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDashboardContent(RiderDashboardState state) {
    if (state is RiderDashboardLoading || state is RiderDashboardInitial) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is RiderDashboardLoaded) {
      final RiderDashboardModel data = state.dashboard;
      return Column(
        children: [
          _buildStatCard(
            title: "Earnings",
            value: "Rs ${data.earning.toStringAsFixed(2)}",
            icon: Icons.account_balance_wallet,
            color: Colors.green.shade400,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: "Delivered Orders",
            value: "${data.deliveredOrders}",
            icon: Icons.check_circle_outline,
            color: Colors.blue.shade400,
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: "Ongoing Orders",
            value: "${data.ongoingOrders}",
            icon: Icons.local_shipping,
            color: Colors.orange.shade400,
          ),
        ],
      );
    } else if (state is RiderDashboardFailure) {
      return Center(
        child: Text(
          state.message,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}