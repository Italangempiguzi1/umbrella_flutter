import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/providers/app_providers.dart';

class UmbrellaApp extends ConsumerStatefulWidget {
  const UmbrellaApp({super.key});

  @override
  ConsumerState<UmbrellaApp> createState() => _UmbrellaAppState();
}

class _UmbrellaAppState extends ConsumerState<UmbrellaApp> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(authControllerProvider.notifier).bootstrap());
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Umbrella',
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
