import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/primary_button.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class CreatorDashboardScreen extends ConsumerWidget {
  const CreatorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(creatorProfileProvider);
    return SafeArea(
      child: AsyncValueWidget<CreatorProfile?>(
        value: profile,
        data: (creator) {
          if (creator == null) return const _CreatorOnboarding();
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(creatorProfileProvider);
              ref.invalidate(creatorDashboardProvider);
              ref.invalidate(contentItemsProvider);
              ref.invalidate(allReelsProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 110),
              children: [
                _CreatorHeader(profile: creator),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: PrimaryButton(label: 'Upload Video', icon: Icons.upload_rounded, onPressed: () => context.push('/creator/upload'))),
                    const SizedBox(width: 10),
                    Expanded(child: PrimaryButton(label: 'Upload Reel', icon: Icons.video_collection_rounded, onPressed: () => context.push('/creator/upload-reel'))),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(onPressed: () => context.push('/creator/earnings'), icon: const Icon(Icons.account_balance_wallet_rounded), label: const Text('Earnings and Payouts')),
                const SizedBox(height: 16),
                _DashboardMetrics(),
                const SizedBox(height: 16),
                _MyUploads(profile: creator),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CreatorOnboarding extends StatelessWidget {
  const _CreatorOnboarding();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(28)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.workspace_premium_rounded, size: 54),
              SizedBox(height: 18),
              Text('Creator Studio', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -.8)),
              SizedBox(height: 8),
              Text('Upload premium videos and reels, track analytics, build followers and earn from the subscription reward pool.', style: TextStyle(height: 1.5, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const ListTile(leading: Icon(Icons.verified_user_rounded), title: Text('Verification ready'), subtitle: Text('Create your creator profile and submit content for review.')),
                const ListTile(leading: Icon(Icons.analytics_rounded), title: Text('Dashboard analytics'), subtitle: Text('Track views, watch time, followers and estimated earnings.')),
                const ListTile(leading: Icon(Icons.payments_rounded), title: Text('Reward earnings'), subtitle: Text('Earn from watch time, votes, engagement and awards.')),
                const SizedBox(height: 10),
                PrimaryButton(label: 'Create Creator Profile', icon: Icons.add_circle_rounded, onPressed: () => context.push('/creator/setup')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CreatorHeader extends StatelessWidget {
  const _CreatorHeader({required this.profile});

  final CreatorProfile profile;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppTheme.surfaceAlt,
              backgroundImage: profile.profileImageUrl.isNotEmpty ? NetworkImage(profile.profileImageUrl) : null,
              child: profile.profileImageUrl.isEmpty ? Text(profile.displayName.isEmpty ? 'C' : profile.displayName[0].toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)) : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.displayName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text('${profile.totalFollowers} followers • ${profile.verificationStatus}', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
                  if (!profile.canUpload) const Text('Upload disabled', style: TextStyle(color: Colors.redAccent)),
                ],
              ),
            ),
            IconButton(onPressed: () => context.push('/creator/setup'), icon: const Icon(Icons.edit_rounded)),
          ],
        ),
      ),
    );
  }
}

class _DashboardMetrics extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(creatorDashboardProvider);
    return AsyncValueWidget<CreatorDashboard>(
      value: dashboard,
      data: (data) => Column(
        children: [
          Row(
            children: [
              Expanded(child: MetricCard(label: 'Long videos', value: '${data.totalLongFormContent}', icon: Icons.movie_creation_rounded)),
              const SizedBox(width: 10),
              Expanded(child: MetricCard(label: 'Reels', value: '${data.totalReels}', icon: Icons.video_collection_rounded)),
            ],
          ),
          Row(
            children: [
              Expanded(child: MetricCard(label: 'Valid views', value: compactNumber(data.validViews), icon: Icons.visibility_rounded)),
              const SizedBox(width: 10),
              Expanded(child: MetricCard(label: 'Pending', value: moneyTzs(data.estimatedPendingEarnings), icon: Icons.wallet_rounded)),
            ],
          ),
          MetricCard(label: 'Watch time', value: formatDuration(data.totalWatchSeconds), icon: Icons.timer_rounded),
        ],
      ),
    );
  }
}

class _MyUploads extends ConsumerWidget {
  const _MyUploads({required this.profile});

  final CreatorProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentItemsProvider);
    final reels = ref.watch(allReelsProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('My Uploads', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        content.when(
          data: (items) {
            final mine = items.where((item) => item.creator == profile.id).take(5).toList();
            if (mine.isEmpty) return const Text('No long-form uploads yet.', style: TextStyle(color: AppTheme.muted));
            return Column(
              children: mine.map((item) => Card(child: ListTile(leading: const Icon(Icons.movie_rounded), title: Text(item.title), subtitle: Text('${item.typeLabel} • ${item.status}'), trailing: Text(compactNumber(item.totalViews))))).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        reels.when(
          data: (items) {
            final mine = items.where((item) => item.creator == profile.id).take(5).toList();
            if (mine.isEmpty) return const Text('No reel uploads yet.', style: TextStyle(color: AppTheme.muted));
            return Column(
              children: mine.map((item) => Card(child: ListTile(leading: const Icon(Icons.video_collection_rounded), title: Text(item.title), subtitle: Text('Reel • ${item.status}'), trailing: Text(compactNumber(item.totalViews))))).toList(),
            );
          },
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
