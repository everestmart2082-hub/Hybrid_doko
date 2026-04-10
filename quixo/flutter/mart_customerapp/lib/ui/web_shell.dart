import 'package:flutter/material.dart';
import '../drawer.dart';
import 'package:quickmartcustomer/widgets/customer_hub_bar_icons.dart';

class WebShell extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const WebShell({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: theme.primaryColorLight,
      appBar:AppBar(
              title: Text(title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.primaryColorLight,
                  )),
              backgroundColor: theme.primaryColorDark,
              iconTheme: IconThemeData(color: theme.primaryColorLight),
              actions: [
                ...?actions,
                const CustomerHubBarIcons(),
              ],
            ),
      drawer:  buildAppDrawer(context),
      body: Row(
        children: [
          if (isDesktop)
            SizedBox(
              width: 250,
              child: buildAppDrawer(context),
            ),
          Expanded(
            child: Scaffold(
            //   backgroundColor: theme.primaryColorLight,
            //   appBar: isDesktop ? AppBar(
            //     title: Text(title,
            //         style: theme.textTheme.bodyLarge?.copyWith(
            //           color: theme.primaryColorLight,
            //         )),
            //     backgroundColor: theme.primaryColorDark,
            //     iconTheme: IconThemeData(color: theme.primaryColorLight),
            //     actions: actions,
            //     automaticallyImplyLeading: false,
            //   ) : null,
              body: child,
            ),
          ),
        ],
      ),
    );
  }
}
