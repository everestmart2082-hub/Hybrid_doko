import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mart_adminapp/core/constants/api_constants.dart';
import 'package:mart_adminapp/core/constants/app_constants.dart';
import 'package:mart_adminapp/core/network/dio_client.dart';
import 'package:mart_adminapp/features/auth/bloc/admin_auth_bloc.dart';
import 'package:mart_adminapp/features/auth/repository/admin_auth_remote.dart';
import 'package:mart_adminapp/features/contacts/bloc/contact_bloc.dart';
import 'package:mart_adminapp/features/customer/bloc/admin_customer_bloc.dart';
import 'package:mart_adminapp/features/customer/repository/admin_customer_remote.dart';
import 'package:mart_adminapp/features/employee/bloc/admin_employee_bloc.dart';
import 'package:mart_adminapp/features/employee/repository/admin_employee_remote.dart';
import 'package:mart_adminapp/features/orders/bloc/admin_order_bloc.dart';
import 'package:mart_adminapp/features/orders/repository/admin_orders_remote.dart';
import 'package:mart_adminapp/features/products/bloc/admin_product_bloc.dart';
import 'package:mart_adminapp/features/products/repository/admin_category_remote.dart';
import 'package:mart_adminapp/features/products/repository/admin_product_remote.dart';
import 'package:mart_adminapp/features/notifications/bloc/admin_notifications_bloc.dart';
import 'package:mart_adminapp/features/notifications/repository/admin_inbox_remote.dart';
import 'package:mart_adminapp/features/profile/bloc/admin_profile_bloc.dart';
import 'package:mart_adminapp/features/profile/repository/admin_profile_remote.dart';
import 'package:mart_adminapp/features/rider/bloc/admin_rider_bloc.dart';
import 'package:mart_adminapp/features/rider/repository/admin_rider_remote.dart';
import 'package:mart_adminapp/features/settings/bloc/settings_bloc.dart';
import 'package:mart_adminapp/features/settings/bloc/settings_state.dart';
import 'package:mart_adminapp/features/settings/repository/admin_settings_remote.dart';
import 'package:mart_adminapp/features/vendor/bloc/admin_vendor_bloc.dart';
import 'package:mart_adminapp/features/vendor/repository/admin_vendor_remote.dart';
import 'package:mart_adminapp/theme.dart';
import 'package:mart_adminapp/ui/web/auth/login_page.dart';
import 'package:mart_adminapp/ui/web/contacts/contact_page.dart';
import 'package:mart_adminapp/ui/web/customers/customers_page.dart';
import 'package:mart_adminapp/ui/web/employees/employees_page.dart';
import 'package:mart_adminapp/ui/web/home/home_page.dart';
import 'package:mart_adminapp/ui/web/orders/orders_page.dart';
import 'package:mart_adminapp/ui/web/products/product_details_page.dart';
import 'package:mart_adminapp/ui/web/products/categories_page.dart';
import 'package:mart_adminapp/ui/web/products/products_page.dart';
import 'package:mart_adminapp/ui/web/profile/profile_page.dart';
import 'package:mart_adminapp/ui/web/notifications/admin_notifications_page.dart';
import 'package:mart_adminapp/ui/web/riders/riders_page.dart';
import 'package:mart_adminapp/ui/web/settings/settings_page.dart';
import 'package:mart_adminapp/ui/web/constants/constants_page.dart';
import 'package:mart_adminapp/ui/web/vendor/vendor_page.dart';

void main() {
  runApp(const AdminRoot());
}

class AdminRoot extends StatelessWidget {
  const AdminRoot({super.key});

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
        RepositoryProvider(create: (_) => AdminAuthRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminVendorRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminOrdersRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminProductRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminCategoryRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminCustomerRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminRiderRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminEmployeeRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminProfileRemote(dio: dioClient)),
        RepositoryProvider(create: (_) => AdminInboxRemote(dio: dioClient)),
        RepositoryProvider(
            create: (_) => AdminSettingsRemote(dio: dioClient)),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => SettingsBloc()),
          BlocProvider(create: (_) => ContactBloc()),
          BlocProvider(
              create: (context) =>
                  AdminAuthBloc(context.read<AdminAuthRemote>())),
          BlocProvider(
              create: (context) =>
                  AdminVendorBloc(context.read<AdminVendorRemote>())),
          BlocProvider(
              create: (context) =>
                  AdminOrderBloc(context.read<AdminOrdersRemote>())),
          BlocProvider(
            create: (context) => AdminProductBloc(
              productRemote: context.read<AdminProductRemote>(),
              categoryRemote: context.read<AdminCategoryRemote>(),
            ),
          ),
          BlocProvider(
              create: (context) =>
                  AdminCustomerBloc(context.read<AdminCustomerRemote>())),
          BlocProvider(
              create: (context) =>
                  AdminRiderBloc(context.read<AdminRiderRemote>())),
          BlocProvider(
              create: (context) =>
                  AdminEmployeeBloc(context.read<AdminEmployeeRemote>())),
          BlocProvider(
              create: (context) =>
                  AdminProfileBloc(context.read<AdminProfileRemote>())),
          BlocProvider(
              create: (context) => AdminNotificationsBloc(
                    context.read<AdminInboxRemote>(),
                  )),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: _themeFor(settingsState.theme),
              home: const AdminHomePage(),
              routes: {
                '/mainapp': (context) => const AdminHomePage(),
                '/login': (context) => const AdminLoginPage(),
                '/profile': (context) => const AdminProfilePage(),
                '/notifications': (context) => const AdminNotificationsPage(),
                '/settings': (context) => const AdminSettingsPage(),
                '/constants': (context) => const AdminConstantsPage(),
                '/contact': (context) => const AdminContactsPage(),
                '/vendors': (context) => const AdminVendorPage(),
                '/orders': (context) => const AdminOrdersPage(),
                '/products': (context) => const AdminProductsPage(),
                '/categories': (context) => const AdminCategoriesPage(),
                '/product_details': (context) => const AdminProductDetailsPage(),
                '/customers': (context) => const AdminCustomersPage(),
                '/riders': (context) => const AdminRidersPage(),
                '/employees': (context) => const AdminEmployeesPage(),
              },
            );
          },
        ),
      ),
    );
  }
}
