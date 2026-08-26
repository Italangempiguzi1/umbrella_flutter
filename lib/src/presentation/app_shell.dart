import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/gradient_scaffold.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  static const _routes = ['/home', '/discover', '/reels', '/creator', '/profile'];

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final index = _routes.indexWhere((route) => location.startsWith(route));

    return GradientScaffold(
      bottomNavigationBar: SafeArea(
        child: NavigationBar(
          selectedIndex: index < 0 ? 0 : index,
          onDestinationSelected: (value) => context.go(_routes[value]),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.search_rounded), label: 'Discover'),
            NavigationDestination(icon: Icon(Icons.video_collection_rounded), label: 'Reels'),
            NavigationDestination(icon: Icon(Icons.dashboard_customize_rounded), label: 'Creator'),
            NavigationDestination(icon: Icon(Icons.person_rounded), label: 'Profile'),
          ],
        ),
      ),
      child: child,
    );
  }
}
