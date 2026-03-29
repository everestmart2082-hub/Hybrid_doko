import 'package:flutter/material.dart';
import 'package:mart_adminapp/drawer.dart';


/// Wraps every web page with a consistent Scaffold (AppBar + Drawer).
/// The [child] is the page body, constrained and centered for web.
class WebShell extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const WebShell({
    super.key,
    required this.title,
    required this.child,
    this.actions,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        elevation: 1,
        actions: actions,
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
