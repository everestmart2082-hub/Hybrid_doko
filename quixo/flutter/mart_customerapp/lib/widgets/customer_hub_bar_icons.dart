import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_state.dart';
import 'package:quickmartcustomer/features/hub/repository/hub_counts_remote.dart';

/// Top app bar shortcuts: profile, wishlist, cart, orders (with optional badges).
/// Optional [leading] widgets render to the left (e.g. product-detail wishlist toggle).
class CustomerHubBarIcons extends StatefulWidget {
  final List<Widget>? leading;

  const CustomerHubBarIcons({super.key, this.leading});

  @override
  State<CustomerHubBarIcons> createState() => _CustomerHubBarIconsState();
}

class _CustomerHubBarIconsState extends State<CustomerHubBarIcons> {
  CustomerHubCounts? _counts;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncWithAuth());
  }

  void _syncWithAuth() {
    if (!mounted) return;
    final auth = context.read<AuthBloc>().state;
    final ok = auth is AuthAuthenticated && auth.authenticated;
    if (!ok) {
      setState(() => _counts = null);
      return;
    }
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final c = await context.read<HubCountsRemote>().getCounts();
      if (!mounted) return;
      setState(() => _counts = c);
    } catch (_) {
      if (!mounted) return;
      setState(() => _counts = null);
    }
  }

  void _go(BuildContext context, bool authed, String route) {
    if (!authed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to continue')),
      );
      Navigator.pushNamed(context, '/login');
      return;
    }
    Navigator.pushNamed(context, route);
  }

  Widget _icon({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required String route,
    required bool authed,
    int? count,
  }) {
    final color = Theme.of(context).primaryColorLight;
    return IconButton(
      tooltip: tooltip,
      onPressed: () => _go(context, authed, route),
      icon: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Icon(icon, color: color),
          if (authed && count != null && count > 0)
            Positioned(
              left: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(8),
                ),
                constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) => _syncWithAuth(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...?widget.leading,
          Builder(
            builder: (context) {
              final auth = context.watch<AuthBloc>().state;
              final authed = auth is AuthAuthenticated && auth.authenticated;
              final c = _counts;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _icon(
                    context: context,
                    icon: Icons.receipt_long_outlined,
                    tooltip: 'My orders',
                    route: '/orders',
                    authed: authed,
                    count: c?.openOrders,
                  ),
                  _icon(
                    context: context,
                    icon: Icons.shopping_cart_outlined,
                    tooltip: 'Cart',
                    route: '/cart',
                    authed: authed,
                    count: c?.cartItems,
                  ),
                  _icon(
                    context: context,
                    icon: Icons.favorite_border,
                    tooltip: 'Wishlist',
                    route: '/wishlist',
                    authed: authed,
                    count: c?.wishlist,
                  ),
                  _icon(
                    context: context,
                    icon: Icons.person_outline,
                    tooltip: 'Profile',
                    route: '/profile',
                    authed: authed,
                    count: null,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
