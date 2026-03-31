

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/core/constants/app_constants.dart';
import 'package:quickmartrider/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartrider/features/auth/bloc/auth_event.dart';
import 'package:quickmartrider/features/auth/bloc/auth_state.dart';


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
        selectedTileColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
      child: 
      BlocBuilder<RiderAuthBloc, RiderAuthState>(
        builder: (context, state) {
          final isLoggedIn = state is RiderAuthSuccess && (state.token?.isNotEmpty ?? false);

          return Column(
            children: [
              // ================= HEADER =================
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

              // ================= COMMON =================
              tile(
                title: 'Home',
                icon: Icons.home,
                route: '/mainapp',
              ),
              

              // ================= LOGGED IN =================
              if (isLoggedIn) ...[
                tile(
                  title: 'Notifications',
                  icon: Icons.shopping_cart,
                  route: '/notification',
                ),
                tile(
                  title: 'Orders',
                  icon: Icons.receipt_long,
                  route: '/order',
                ),
              ],

              
              tile(
                title: 'Settings',
                icon: Icons.settings,
                route: '/settings',
              ),
              tile(
                title: 'Contact Us',
                icon: Icons.support_agent,
                route: '/contact',
              ),

              const Spacer(),
              const Divider(),

              // ================= AUTH SECTION =================
              if (!isLoggedIn) ...[
                tile(
                  title: 'Login',
                  icon: Icons.login,
                  route: '/login',
                ),
                tile(
                  title: 'Register',
                  icon: Icons.app_registration,
                  route: '/register',
                ),
              ] else ...[
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: const Text('Profile'),
                  trailing: TextButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                    onPressed: () {
                      context.read<RiderAuthBloc>().add(RiderAuthLogout());
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/profile');
                  },
                ),
              ],

              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }