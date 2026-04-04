
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quickmartcustomer/core/constants/api_constants.dart';
import 'package:quickmartcustomer/core/constants/app_constants.dart';
import 'package:quickmartcustomer/core/network/shared_pref.dart';
import 'package:quickmartcustomer/core/notifications/notifications.dart';
import 'package:quickmartcustomer/features/addresss/bloc/addresses_bloc.dart';
import 'package:quickmartcustomer/features/addresss/repository/address_remote.dart';
import 'package:quickmartcustomer/features/addresss/ui/addressListMainpage.dart';
import 'package:quickmartcustomer/features/auth/bloc/auth_bloc.dart';
import 'package:quickmartcustomer/features/auth/repository/auth_remote.dart';
import 'package:quickmartcustomer/ui/web/auth/login_screen.dart';
import 'package:quickmartcustomer/ui/web/auth/register_screen.dart';
import 'package:quickmartcustomer/features/cart/bloc/cart_bloc.dart';
import 'package:quickmartcustomer/features/cart/repository/cart_remote.dart';
import 'package:quickmartcustomer/features/contacts/bloc/contact_bloc.dart';
import 'package:quickmartcustomer/features/contacts/repository/contact_remote.dart';
import 'package:quickmartcustomer/features/cart/ui/cart_page.dart';
import 'package:quickmartcustomer/features/notification/bloc/notification_bloc.dart';
import 'package:quickmartcustomer/features/notification/data/notification_query_model.dart';
import 'package:quickmartcustomer/features/notification/repository/notification_remote.dart';
import 'package:quickmartcustomer/features/notification/ui/notification_page.dart';
import 'package:quickmartcustomer/features/order/bloc/order_bloc.dart';
import 'package:quickmartcustomer/features/order/repository/order_remote.dart';
import 'package:quickmartcustomer/features/order/ui/order_page.dart';
import 'package:quickmartcustomer/features/payment/bloc/payment_bloc.dart';
import 'package:quickmartcustomer/features/payment/repository/payment_remote.dart';
import 'package:quickmartcustomer/features/payment/ui/checkout_page.dart';
import 'package:quickmartcustomer/features/product/ui/product_list_page.dart';
import 'package:quickmartcustomer/features/product/ui/product_detail_page.dart';
import 'package:quickmartcustomer/features/wishlist/ui/wishlist_page.dart';
import 'package:quickmartcustomer/features/product/data/product_list_item_model.dart';
import 'package:quickmartcustomer/features/productGuest/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/productGuest/repository/product_remote.dart';
import 'package:quickmartcustomer/features/productGuest/ui/product_list_page.dart';
import 'package:quickmartcustomer/features/profile/bloc/profile_bloc.dart';
import 'package:quickmartcustomer/features/profile/repository/profile_remote.dart';
import 'package:quickmartcustomer/features/profile/ui/profile_page.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_bloc.dart';
import 'package:quickmartcustomer/features/settings/bloc/settings_state.dart';
import 'package:quickmartcustomer/features/settings/ui/contact_us_page.dart';
import 'package:quickmartcustomer/features/settings/ui/settings_page.dart';
import 'package:quickmartcustomer/features/wishlist/bloc/wishlist_bloc.dart';
import 'package:quickmartcustomer/features/wishlist/repository/wishlist_remote.dart';
import 'package:quickmartcustomer/features/settings/repository/settings_remote.dart';
import 'package:workmanager/workmanager.dart';

import 'core/network/dio_client.dart';

import 'mainapp.dart';
import 'theme.dart';

import 'package:quickmartcustomer/features/product/bloc/product_bloc.dart';
import 'package:quickmartcustomer/features/product/repository/product_remote.dart';

const String checkNotificationsTask = "checkNotifications";

void callbackDispatcher() {
  if (kIsWeb) return;
  Workmanager().executeTask((task, inputData) async {
    if (task == checkNotificationsTask) {
      final remote = NotificationRemote(dio: DioClient(baseUrl: ApiEndpoints.baseUrl)); // your repo to fetch notifications
      final newNotifications = await remote.getNotifications(NotificationQueryModel());

      for (var n in newNotifications) {
        await showNotification("New Notification", n.message);
      }

      return Future.value(true);
    }
    return Future.value(false);
  });
}

// Initialize Workmanager in main()
void initBackgroundTasks() {
  if (kIsWeb) return;
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  Workmanager().registerPeriodicTask(
    "1",
    checkNotificationsTask,
    frequency: const Duration(minutes: 15),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Background tasks + local notifications are Android/iOS only.
  if (!kIsWeb) {
    initBackgroundTasks();
    await initNotifications();
  }

  runApp(MyApp());
}

// ignore: must_be_immutable
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
        RepositoryProvider(create: (context)=>AuthRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>ProfileRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>AddressRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>OrderRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>CartRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>ContactRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>ProductRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>PaymentRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>ProductGuestRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>WishlistRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>NotificationRemote(dio: dioClient)),
        RepositoryProvider(create: (context)=>SettingsRemote(dio: dioClient)),
      ],
      child: 
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (context)=> SettingsBloc(context.read<SettingsRemote>())),
          BlocProvider(create: (context)=>AuthBloc(context.read<AuthRemote>())),
          BlocProvider(create: (context)=>AddressBloc(context.read<AddressRemote>())),
          BlocProvider(create: (context)=>OrderBloc(context.read<OrderRemote>())),
          BlocProvider(create: (context)=>CartBloc(context.read<CartRemote>())),
          BlocProvider(create: (context)=>ProductBloc(context.read<ProductRemote>())),
          BlocProvider(create: (context)=>ContactBloc(context.read<ContactRemote>())),
          BlocProvider(create: (context)=>PaymentBloc(context.read<PaymentRemote>())),
          BlocProvider(create: (context)=>ProductGuestBloc(context.read<ProductGuestRemote>())),
          BlocProvider(create: (context)=>WishlistBloc(context.read<WishlistRemote>())),
          BlocProvider(create: (context)=>NotificationBloc(context.read<NotificationRemote>())),
          BlocProvider(create: (context)=>ProfileBloc(context.read<ProfileRemote>())),
        ],
        child: BlocBuilder<SettingsBloc,SettingsState>(
          builder: (context, state) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _themeFor(state.theme),
              initialRoute: '/mainapp',
              routes: {
                '/mainapp': (context) => const MainApp(),
                '/settings': (context) => const SettingsPage(),
                '/contact': (context) => const ContactUsPage(),
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/profile': (context) => const ProfilePage(),
                '/productsGuest': (context) => const ProductGuestListPage(),
                '/products': (context) => const ProductListPage(),
                '/cart': (context) => const CartPage(),
                '/orders': (context) => const OrderPage(),
                '/payment': (context) => const CheckoutPage(),
                '/addresses': (context) => const AddressPage(),
                '/notifications': (context) => const NotificationPage()
                ,
                '/wishlist': (context) => const WishlistPage(),
                '/product-detail': (context) {
                  final args = ModalRoute.of(context)?.settings.arguments;
                  if (args is String) {
                    return ProductDetailPage(productId: args);
                  }
                  // Support navigation from ProductListPage/MainApp which passes a ProductListItem.
                  if (args is ProductListItem) {
                    return ProductDetailPage(productId: args.id);
                  }
                  return const ProductDetailPage(productId: '');
                },
              },
            );
          }
        ),
      )
    );
  }
}
