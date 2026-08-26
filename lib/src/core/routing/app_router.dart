import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/app_providers.dart';
import '../../features/admin/admin_tools_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/auth/splash_screen.dart';
import '../../features/content/content_detail_screen.dart';
import '../../features/content/player_screen.dart';
import '../../features/creator/creator_dashboard_screen.dart';
import '../../features/creator/creator_profile_setup_screen.dart';
import '../../features/creator/creator_public_screen.dart';
import '../../features/creator/creator_upload_content_screen.dart';
import '../../features/creator/creator_upload_reel_screen.dart';
import '../../features/creator/earnings_screen.dart';
import '../../features/engagement/comments_screen.dart';
import '../../features/home/discover_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/moderation/report_screen.dart';
import '../../features/moderation/reports_list_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/profile/edit_profile_screen.dart';
import '../../features/profile/payment_history_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/reels/reels_feed_screen.dart';
import '../../features/subscriptions/subscription_screen.dart';
import '../../presentation/app_shell.dart';

final routerNotifierProvider = Provider<RouterNotifier>((ref) => RouterNotifier(ref));

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this.ref) {
    ref.listen(authControllerProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;
      final isAuthRoute = location == '/login' || location == '/register';

      if (auth.isBootstrapping) return location == '/splash' ? null : '/splash';
      if (!auth.isAuthenticated) return isAuthRoute ? null : '/login';
      if (location == '/splash' || isAuthRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/discover', builder: (context, state) => const DiscoverScreen()),
          GoRoute(path: '/reels', builder: (context, state) => const ReelsFeedScreen()),
          GoRoute(path: '/creator', builder: (context, state) => const CreatorDashboardScreen()),
          GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
        ],
      ),
      GoRoute(path: '/subscribe', builder: (context, state) => const SubscriptionScreen()),
      GoRoute(path: '/payments', builder: (context, state) => const PaymentHistoryScreen()),
      GoRoute(path: '/profile/edit', builder: (context, state) => const EditProfileScreen()),
      GoRoute(path: '/notifications', builder: (context, state) => const NotificationsScreen()),
      GoRoute(path: '/reports', builder: (context, state) => const ReportsListScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const AdminToolsScreen()),
      GoRoute(path: '/content/:id', builder: (context, state) => ContentDetailScreen(id: state.pathParameters['id']!)),
      GoRoute(
        path: '/player/:targetType/:id',
        builder: (context, state) => PlayerScreen(
          targetType: state.pathParameters['targetType']!,
          id: state.pathParameters['id']!,
          title: state.uri.queryParameters['title'],
        ),
      ),
      GoRoute(path: '/creator/setup', builder: (context, state) => const CreatorProfileSetupScreen()),
      GoRoute(path: '/creator/public/:id', builder: (context, state) => CreatorPublicScreen(id: state.pathParameters['id']!)),
      GoRoute(path: '/creator/upload', builder: (context, state) => const CreatorUploadContentScreen()),
      GoRoute(path: '/creator/upload-reel', builder: (context, state) => const CreatorUploadReelScreen()),
      GoRoute(path: '/creator/earnings', builder: (context, state) => const EarningsScreen()),
      GoRoute(
        path: '/comments/:targetType/:id',
        builder: (context, state) => CommentsScreen(
          targetType: state.pathParameters['targetType']!,
          targetId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/report/:targetType/:id',
        builder: (context, state) => ReportScreen(
          targetType: state.pathParameters['targetType']!,
          targetId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
