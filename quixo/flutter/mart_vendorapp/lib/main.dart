
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartvender/core/constants/api_constants.dart';
import 'package:quickmartvender/core/constants/app_constants.dart';
import 'package:quickmartvender/core/network/shared_pref.dart';
import 'package:quickmartvender/core/notifications/notifications.dart';
import 'package:quickmartvender/features/Dashboard/bloc/dashboard_bloc.dart';
import 'package:quickmartvender/features/Dashboard/repository/dashboard_remote.dart';
import 'package:quickmartvender/features/Notification/bloc/notification_bloc.dart';
import 'package:quickmartvender/features/Notification/repository/notification_remote.dart';
import 'package:quickmartvender/features/Notification/ui/notification_ui.dart';
import 'package:quickmartvender/features/Order/bloc/order_bloc.dart';
import 'package:quickmartvender/features/Order/repository/order_remote.dart';
import 'package:quickmartvender/features/Order/ui/order_page.dart';
import 'package:quickmartvender/features/Product/bloc/product_bloc.dart';
import 'package:quickmartvender/features/Product/repository/product_remote.dart';
import 'package:quickmartvender/features/Product/ui/product_list_page.dart';
import 'package:quickmartvender/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartvender/features/auth/repository/auth_remote.dart';
import 'package:quickmartvender/features/auth/ui/login_page.dart';
import 'package:quickmartvender/features/auth/ui/register_page.dart';
import 'package:quickmartvender/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartvender/features/profile/repository/profile_remote.dart';
import 'package:quickmartvender/features/profile/ui/profile_page.dart';
import 'package:quickmartvender/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartvender/features/settings/bloc/settings_state.dart';
import 'package:quickmartvender/features/settings/ui/contacts_ui.dart';
import 'package:quickmartvender/features/settings/ui/settings_ui.dart';
import 'core/network/dio_client.dart';

import 'mainapp.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final SharedPreferencesProvider s = SharedPreferencesProvider();

  var themeString = "amber-red";      

  ThemeData themeData = themeDataFromColors(orangeBlueGrayTheme);

  ThemeData _getThemeData(String themeString) {
    switch (themeString) {
      case 'orange-bluegray':
        return themeDataFromColors(orangeBlueGrayTheme);
      case 'teal-blue':
        return themeDataFromColors(tealBlueTheme);
      case 'amber-red':
        return themeDataFromColors(amberRedTheme);
      case 'orange-bluegray-dark':
        return themeDataFromColors(orangeBlueGrayDarkTheme);
      case 'teal-blue-dark':
        return themeDataFromColors(tealBlueDarkTheme);
      case 'amber-red-dark':
        return themeDataFromColors(amberRedDarkTheme);
      default:
        return themeDataFromColors(amberRedTheme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dioClient = DioClient(baseUrl: ApiEndpoints.baseUrl);

    return 
    MultiRepositoryProvider(
      providers: [
        /// AUTH
        RepositoryProvider(create: (context)=>VenderAuthRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>ProfileRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>NotificationRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>ProductRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>OrderRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>DashboardRemote(dio: dioClient)),
        
      ],
      child: 
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context)=> SettingsBloc()),
          BlocProvider(create: (context)=> VenderAuthBloc(context.read<VenderAuthRemote>())),
          BlocProvider(create: (context)=> NotificationBloc(context.read<NotificationRemote>())),
          BlocProvider(create: (context)=> ProfileBloc(context.read<ProfileRemote>())),
          BlocProvider(create: (context)=> ProductBloc(context.read<ProductRemote>())),
          BlocProvider(create: (context)=> OrderBloc(context.read<OrderRemote>())),
          BlocProvider(create: (context)=> DashboardBloc(context.read<DashboardRemote>())),
        ],
        child: BlocBuilder<SettingsBloc,SettingsState>(
          builder: (context, state) {
            themeData = _getThemeData(state.theme);
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: themeData,
              home: MainApp(),
              routes: {
                '/mainapp': (context) => const MainApp(),
                '/settings': (context) => const SettingsPage(),
                '/contact': (context) => const ContactUsPage(),
                '/login': (context) => const VenderLoginPage(),
                '/register': (context) => const VenderRegisterPage(),
                '/profile': (context) => const ProfilePage(),
                '/order': (context)=> const OrdersPage(),
                '/product': (context)=> const ProductPage(),
                'notification': (context)=> NotificationPage()
              },
            );
          }
        ),
      )
    );
  }
}
