
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartrider/core/constants/api_constants.dart';
import 'package:quickmartrider/core/constants/app_constants.dart';
import 'package:quickmartrider/core/network/shared_pref.dart';
import 'package:quickmartrider/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartrider/features/auth/repository/auth_remote.dart';
import 'package:quickmartrider/features/auth/ui/login_page.dart';
import 'package:quickmartrider/features/auth/ui/register_page.dart';
import 'package:quickmartrider/features/dashboard/bloc/dashboard_bloc.dart';
import 'package:quickmartrider/features/dashboard/repository/dashboard_remote.dart';
import 'package:quickmartrider/features/notification/bloc/notification_bloc.dart';
import 'package:quickmartrider/features/notification/repository/notification_remote.dart';
import 'package:quickmartrider/features/notification/ui/notification_page.dart';
import 'package:quickmartrider/features/order/bloc/order_bloc.dart';
import 'package:quickmartrider/features/order/repository/order_remote.dart';
import 'package:quickmartrider/features/order/ui/order_page.dart';
import 'package:quickmartrider/features/contacts/bloc/contact_bloc.dart';
import 'package:quickmartrider/features/contacts/repository/contacts_remote.dart';
import 'package:quickmartrider/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartrider/features/profile/repository/rider_profile_remote.dart';
import 'package:quickmartrider/features/profile/ui/profile_page.dart';
import 'package:quickmartrider/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartrider/features/settings/bloc/settings_state.dart';
import 'package:quickmartrider/features/settings/ui/contacts.dart';
import 'package:quickmartrider/features/settings/ui/settings_ui.dart';
import 'package:workmanager/workmanager.dart';
import 'core/network/dio_client.dart';

import 'mainapp.dart';
import 'theme.dart';

void callbackDispatcher() {
  if (kIsWeb) return;
  Workmanager().executeTask((task, inputData) async {
    // Call your notification API here
    // Example: fetch new notifications
    // If new notification exists, call showNotification()
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  WidgetsFlutterBinding.ensureInitialized();
  // Workmanager is not supported on web. Guard to prevent runtime crash.
  if (!kIsWeb) {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true,
    );
    await Workmanager().registerPeriodicTask(
      "notificationChecker",
      "fetchNotifications",
      frequency: const Duration(minutes: 15), // Check every 15 min
    );
  }


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

    return 
    MultiRepositoryProvider(
      providers: [
        /// AUTH
        RepositoryProvider(create: (context)=>RiderAuthRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>RiderContactsRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>RiderNotificationRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>RiderDashboardRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>RiderOrderRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>RiderProfileRemote(dio: dioClient)),
        
      ],
      child: 
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context)=> SettingsBloc()),
          BlocProvider(create: (context)=> RiderAuthBloc(context.read<RiderAuthRemote>())),
          BlocProvider(create: (context)=> RiderContactsBloc(context.read<RiderContactsRemote>())),
          BlocProvider(create: (context)=> RiderNotificationBloc(context.read<RiderNotificationRemote>())),
          BlocProvider(create: (context)=> RiderDashboardBloc(context.read<RiderDashboardRemote>())),
          BlocProvider(create: (context)=> RiderOrderBloc(context.read<RiderOrderRemote>())),
          BlocProvider(create: (context)=> RiderProfileBloc(context.read<RiderProfileRemote>())),
        ],
        child: BlocBuilder<SettingsBloc,SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _themeFor(state.theme),
              home: MainApp(),
              routes: {
                '/mainapp': (context) => const MainApp(),
                '/settings': (context) => const SettingsPage(),
                '/contact': (context) => const ContactUsPage(),
                '/login': (context) => const RiderLoginPage(),
                '/register': (context) => const RiderRegisterPage(),
                '/profile': (context) => const RiderProfilePage(),
                '/order': (context) => const RiderOrdersTabsPage(),
                '/notification': (context) => const RiderNotificationPage(),
              },
            );
          }
        ),
      )
    );
  }
}
