
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/constants/app_constants.dart';
import 'package:quickmartvender/core/network/shared_pref.dart';
import 'package:quickmartvender/core/notifications/notifications.dart';

// Blocs & repos
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_bloc.dart';
import 'package:quickmartvender/features/Dashboard/repository/dashboard_remote.dart';
import 'package:quickmartvender/features/Notification/bloc/notification_bloc.dart';
import 'package:quickmartvender/features/Notification/repository/notification_remote.dart';
import 'package:quickmartvender/features/Order/bloc/order_bloc.dart';
import 'package:quickmartvender/features/Order/repository/order_remote.dart';
import 'package:quickmartvender/features/Product/bloc/product_bloc.dart';
import 'package:quickmartvender/features/Product/repository/product_remote.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/repository/auth_remote.dart';
import 'package:quickmartvender/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartvender/features/profile/repository/profile_remote.dart';
import 'package:quickmartvender/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartvender/features/settings/bloc/settings_state.dart';
import 'package:quickmartvender/features/contacts/bloc/contact_bloc.dart';
import 'package:quickmartvender/features/contacts/repository/contact_remote.dart';

// Web UI pages
import 'package:quickmartvender/ui/web/auth/login_page.dart';
import 'package:quickmartvender/ui/web/auth/register_page.dart';
import 'package:quickmartvender/ui/web/dashboard/dashboard_page.dart';
import 'package:quickmartvender/ui/web/products/product_list_page.dart';
import 'package:quickmartvender/ui/web/products/product_form_page.dart';
import 'package:quickmartvender/ui/web/orders/orders_page.dart';
import 'package:quickmartvender/ui/web/profile/profile_page.dart';
import 'package:quickmartvender/ui/web/notification/notification_page.dart';
import 'package:quickmartvender/ui/web/settings/settings_page.dart';
import 'package:quickmartvender/ui/web/contacts/contact_page.dart';

import 'core/network/dio_client.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final SharedPreferencesProvider s = SharedPreferencesProvider();

  ThemeData _themeFor(String theme) {
    switch (theme) {
      case 'amberLight':
        return themeDataFromColors(amberRedTheme);
      case 'amberDark':
        return themeDataFromColors(amberRedDarkTheme);
      case 'orangeLight':
        return themeDataFromColors(orangeBlueGrayTheme);
      case 'orangeDark':
        return themeDataFromColors(orangeBlueGrayDarkTheme);
      case 'tealLight':
        return themeDataFromColors(tealBlueTheme);
      case 'tealDark':
        return themeDataFromColors(tealBlueDarkTheme);
      default:
        return themeDataFromColors(amberRedDarkTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dioClient = DioClient(baseUrl: ApiEndpoints.baseUrl);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => VenderAuthRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => ProfileRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => NotificationRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => ProductRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => OrderRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => DashboardRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => ContactRemote(dio: dioClient)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsBloc()),
          BlocProvider(create: (ctx) => VenderAuthBloc(ctx.read<VenderAuthRemote>())),
          BlocProvider(create: (ctx) => NotificationBloc(ctx.read<NotificationRemote>())),
          BlocProvider(create: (ctx) => ProfileBloc(ctx.read<ProfileRemote>())),
          BlocProvider(create: (ctx) => ProductBloc(ctx.read<ProductRemote>())),
          BlocProvider(create: (ctx) => OrderBloc(ctx.read<OrderRemote>())),
          BlocProvider(create: (ctx) => DashboardBloc(ctx.read<DashboardRemote>())),
          BlocProvider(
              create: (ctx) => ContactBloc(ctx.read<ContactRemote>())),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _themeFor(state.theme),
              // Default home = Dashboard (if logged in); Login otherwise.
              // Auth guard is handled per-page by checking VenderAuthBloc.
              initialRoute: '/mainapp',
              routes: {
                '/mainapp':    (_) => const DashboardPage(),
                '/login':      (_) => const VenderLoginPage(),
                '/register':   (_) => const VenderRegisterPage(),
                '/profile':    (_) => const ProfilePage(),
                '/products':   (_) => const ProductListPage(),
                '/product/add': (_) => const ProductFormPage(),
                '/orders':     (_) => const OrdersPage(),
                '/notifications': (_) => const NotificationPage(),
                '/settings':   (_) => const SettingsPage(),
                '/contact':    (_) => const ContactUsPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
