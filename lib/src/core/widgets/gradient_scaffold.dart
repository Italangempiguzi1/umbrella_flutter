import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({super.key, required this.child, this.appBar, this.bottomNavigationBar, this.floatingActionButton});

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-.8, -1),
            radius: 1.3,
            colors: [AppTheme.primary.withOpacity(.18), AppTheme.background, AppTheme.background],
          ),
        ),
        child: child,
      ),
    );
  }
}
