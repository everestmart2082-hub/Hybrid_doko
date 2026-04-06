import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/constants/app_constants.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_event.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_state.dart';

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
      leading: Icon(icon, color: Theme.of(context).primaryColorDark),
      title: Text(title, style: Theme.of(context).textTheme.bodyMedium),
      selected: selected,
      selectedTileColor: Theme.of(context).colorScheme.primary,
      onTap:
          onTap ??
          () {
            final isDesktop = MediaQuery.of(context).size.width > 800;
            if (!selected) {
              if (!isDesktop) {
                Navigator.pop(context); // Close the modal drawer first
              }
              Navigator.pushReplacementNamed(context, route);
            } else {
              if (!isDesktop) {
                Navigator.pop(context); // Close the modal drawer
              }
            }
          },
    );
  }

  return Drawer(
    child: BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final isLoggedIn = state is AuthAuthenticated
            ? state.authenticated
            : false;

        return Container(
          decoration: BoxDecoration(color: Theme.of(context).primaryColorLight),
          child: Column(
            children: [
              // ═══════════════ HEADER ════════════════
              DrawerHeader(
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // ═══════════════ COMMON ═══════════════
              tile(title: 'Home', icon: Icons.home, route: '/mainapp'),
              if (!isLoggedIn)
                tile(
                  title: 'Products',
                  icon: Icons.storefront,
                  route: '/productsGuest',
                ),

              // ═══════════════ LOGGED IN ═══════════════
              if (isLoggedIn) ...[
                tile(
                  title: 'Products',
                  icon: Icons.storefront,
                  route: '/products',
                ),
                tile(title: 'Cart', icon: Icons.shopping_cart, route: '/cart'),
                tile(
                  title: 'Orders',
                  icon: Icons.receipt_long,
                  route: '/orders',
                ),

                tile(
                  title: 'Wishlist',
                  icon: Icons.bookmark,
                  route: '/wishlist',
                ),
                tile(
                  title: 'Addresses',
                  icon: Icons.location_on,
                  route: '/addresses',
                ),
              ],

              tile(title: 'Settings', icon: Icons.settings, route: '/settings'),
              if (isLoggedIn)
                tile(
                  title: 'Contact Us',
                  icon: Icons.support_agent,
                  route: '/contact',
                ),

              const Spacer(),
              const Divider(),

              // ═══════════════ AUTH SECTION ═══════════════
              if (!isLoggedIn) ...[
                tile(title: 'Login', icon: Icons.login, route: '/login'),
                tile(
                  title: 'Register',
                  icon: Icons.app_registration,
                  route: '/register',
                ),
              ] else ...[
                ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    'Profile',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: TextButton.icon(
                    icon: Icon(
                      Icons.logout,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    label: Text(
                      'Logout',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogout());
                      Navigator.pushReplacementNamed(context, '/mainapp');
                    },
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/profile');
                  },
                ),
              ],

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    ),
  );
}
