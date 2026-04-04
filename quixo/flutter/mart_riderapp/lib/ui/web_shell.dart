import 'package:flutter/material.dart';
import 'package:quickmartrider/drawer.dart';

/// Wraps every page with a consistent Scaffold (AppBar + Drawer).
/// On wide screens the body is constrained to 1100px; on mobile it fills width.
class WebShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  const WebShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorDark,
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColorLight)),
        elevation: 1,
        actions: actions,
        bottom: bottom,
      ),
      drawer: buildAppDrawer(context),
      floatingActionButton: floatingActionButton,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final double maxWidth =
              constraints.maxWidth > 1200 ? 1100 : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: maxWidth,
              child: child,
            ),
          );
        },
      ),
    );
  }
}
