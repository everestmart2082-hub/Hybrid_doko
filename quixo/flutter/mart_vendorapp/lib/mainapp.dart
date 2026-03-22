import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/constants/app_constants.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_bloc.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_event.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_state.dart';
import 'package:quickmartvender/features/Dashboard/data/dashboard_model.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/bloc/auth_event.dart';

import 'drawer.dart';
// import 'package:http/http.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int selectedChart = 0;

  @override
  void initState() {
    super.initState();
    context.read<VenderAuthBloc>().add(VenderAuthCheck());
    context.read<DashboardBloc>().add(
          const LoadVendorChart(page: 1, limit: 10),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppConstants.appName), elevation: 0),
      drawer: buildAppDrawer(context),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white ,
              Theme.of(context).primaryColorLight,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: BlocBuilder<DashboardBloc, DashboardState>(
          builder: (context, state) {

            if (state is DashboardLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is DashboardError) {
              return Center(child: Text(state.message));
            }

            if (state is DashboardLoaded) {
              return _buildDashboard(context, state.chartData);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildDashboard(
    BuildContext context,
    List<VendorChartData> chartData,
  ) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white,
            theme.primaryColorLight,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text("Run Chart", style: theme.textTheme.titleLarge),

            const SizedBox(height: 16),

            _chartSelector(),

            const SizedBox(height: 16),

            /// Chart placeholder (using data)
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: theme.primaryColorLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: chartData.length,
                itemBuilder: (context, index) {

                  final item = chartData[index];

                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(item.value.toString()),
                        Container(
                          width: 20,
                          height: item.value * 5,
                          color: theme.primaryColor,
                        ),
                        Text(item.label),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            Text("Overview", style: theme.textTheme.titleLarge),

            const SizedBox(height: 16),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
              ),
              children: const [

                DashboardCard(
                  title: "Products",
                  value: "0",
                  icon: Icons.inventory,
                ),

                DashboardCard(
                  title: "Orders",
                  value: "0",
                  icon: Icons.shopping_bag,
                ),

                DashboardCard(
                  title: "Pending Orders",
                  value: "0",
                  icon: Icons.pending_actions,
                ),

                DashboardCard(
                  title: "Revenue",
                  value: "Rs 0",
                  icon: Icons.attach_money,
                ),

                DashboardCard(
                  title: "Complaints",
                  value: "0",
                  icon: Icons.report_problem,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }


  /// Chart toggle
  Widget _chartSelector() {

    final theme = Theme.of(context);

    return Row(
      children: [

        _chartButton("Daily", 0),
        const SizedBox(width: 8),

        _chartButton("Weekly", 1),
        const SizedBox(width: 8),

        _chartButton("Monthly", 2),

      ],
    );
  }

  Widget _chartButton(String label, int index) {

    final theme = Theme.of(context);
    final selected = selectedChart == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedChart = index;
        });
      },

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),

        decoration: BoxDecoration(
          color: selected
              ? theme.primaryColor
              : theme.primaryColorLight,

          borderRadius: BorderRadius.circular(8),
        ),

        child: Text(
          label,
          style: theme.textTheme.labelLarge,
        ),
      ),
    );
  }

  /// Chart placeholder (later replace with chart widget)
  Widget _chartPlaceholder() {

    final theme = Theme.of(context);

    return Container(
      height: 200,

      decoration: BoxDecoration(
        color: theme.primaryColorLight,
        borderRadius: BorderRadius.circular(12),
      ),

      child: const Center(
        child: Text("Chart will appear here"),
      ),
    );
  }
}


class DashboardCard extends StatelessWidget {

  final String title;
  final String value;
  final IconData icon;

  const DashboardCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: theme.primaryColorLight,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Icon(icon),

          const Spacer(),

          Text(
            value,
            style: theme.textTheme.headlineSmall,
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}