import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/core/constants/app_constants.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_bloc.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_event.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_state.dart';

Drawer buildAppDrawer(BuildContext context) {
  final currentRoute = ModalRoute.of(context)?.settings.name;

  Widget tile({
    required String title,
    required IconData icon,
    required String route,
    VoidCallback? onTap,
  }) {
    final selected = currentRoute == route;

    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: selected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withOpacity(0.1),
      onTap: onTap ??
          () {
            if (!selected) {
              Navigator.pushNamed(context, route);
            } else {
              Navigator.pop(context);
            }
          },
    );
  }

  return Drawer(
    child: BlocBuilder<AdminAuthBloc, AdminAuthState>(
      builder: (context, state) {
        final isLoggedIn =
            state is AdminAuthenticated ? state.authenticated : false;

        return Column(
          children: [
            // ═══════════════ HEADER ════════════════
            DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  AppConstants.appName,
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),

            // ═══════════════ ALWAYS VISIBLE ════════════════
            tile(title: 'Home', icon: Icons.home, route: '/mainapp'),

            // ═══════════════ LOGGED IN ONLY ════════════════
            if (isLoggedIn) ...[
              tile(title: 'Orders', icon: Icons.receipt_long, route: '/orders'),
              tile(title: 'Products', icon: Icons.inventory, route: '/products'),
              tile(title: 'Vendors', icon: Icons.store, route: '/vendors'),
              tile(title: 'Customers', icon: Icons.people, route: '/customers'),
              tile(title: 'Riders', icon: Icons.two_wheeler, route: '/riders'),
              tile(title: 'Employees', icon: Icons.badge, route: '/employees'),
            ],

            tile(title: 'Settings', icon: Icons.settings, route: '/settings'),
            tile(
                title: 'Contact Us',
                icon: Icons.support_agent,
                route: '/contact'),

            const Spacer(),
            const Divider(),

            // ═══════════════ AUTH SECTION ════════════════
            if (!isLoggedIn) ...[
              tile(title: 'Login', icon: Icons.login, route: '/login'),
            ] else ...[
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.admin_panel_settings)),
                title: const Text('Profile'),
                trailing: TextButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: () {
                    context.read<AdminAuthBloc>().add(AdminLogout());
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
                onTap: () =>
                    Navigator.pushReplacementNamed(context, '/profile'),
              ),
            ],

            const SizedBox(height: 12),
          ],
        );
      },
    ),
  );
}
