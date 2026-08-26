import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;
    final current = ref.watch(currentSubscriptionProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: AppTheme.surfaceAlt,
                backgroundImage: user?.avatarUrl.isNotEmpty == true ? NetworkImage(user!.avatarUrl) : null,
                child: user?.avatarUrl.isNotEmpty == true ? null : Text(user?.username.substring(0, 1).toUpperCase() ?? 'U', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.username ?? 'User', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                    Text(user?.email ?? '', style: const TextStyle(color: AppTheme.muted)),
                    const SizedBox(height: 4),
                    Text(user?.role ?? 'viewer', style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          current.when(
            data: (sub) => _SubscriptionTile(sub: sub),
            loading: () => const LinearProgressIndicator(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 14),
          _MenuTile(icon: Icons.edit_rounded, title: 'Edit Profile', subtitle: 'Update username, email, phone and avatar', onTap: () => context.push('/profile/edit')),
          _MenuTile(icon: Icons.workspace_premium_rounded, title: 'Subscription Plans', subtitle: 'Manage your monthly plan', onTap: () => context.push('/subscribe')),
          _MenuTile(icon: Icons.receipt_long_rounded, title: 'Payment History', subtitle: 'View subscription payment records', onTap: () => context.push('/payments')),
          _MenuTile(icon: Icons.notifications_rounded, title: 'Notifications', subtitle: 'Updates, moderation and reward messages', onTap: () => context.push('/notifications')),
          _MenuTile(icon: Icons.flag_rounded, title: 'My Reports', subtitle: 'Track reports you submitted', onTap: () => context.push('/reports')),
          _MenuTile(icon: Icons.admin_panel_settings_rounded, title: 'Admin Quick Tools', subtitle: 'Approve content/reels using admin token', onTap: () => context.push('/admin')),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Logout',
            icon: Icons.logout_rounded,
            onPressed: () async {
              try {
                await ref.read(authControllerProvider.notifier).logout();
              } catch (error) {
                showSnack(context, error.toString());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SubscriptionTile extends StatelessWidget {
  const _SubscriptionTile({required this.sub});

  final CurrentSubscription sub;

  @override
  Widget build(BuildContext context) {
    if (!sub.active) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.lock_open_rounded, color: AppTheme.gold),
          title: const Text('No active subscription', style: TextStyle(fontWeight: FontWeight.w900)),
          subtitle: const Text('Subscribe to unlock streaming and reels.'),
          trailing: FilledButton.tonal(onPressed: () => context.push('/subscribe'), child: const Text('Plans')),
        ),
      );
    }
    final plan = sub.subscription?.plan;
    return Card(
      child: ListTile(
        leading: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
        title: Text(plan?.name ?? 'Active plan', style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text('${plan?.maxQuality ?? 'HD'} • ${plan?.monthlyAwardPoints ?? 0} award points'),
        trailing: Text(plan == null ? '' : moneyTzs(plan.priceTzs), style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}
