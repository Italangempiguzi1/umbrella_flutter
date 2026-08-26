import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/poster_image.dart';
import '../../core/widgets/section_header.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import 'content_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = ref.watch(contentItemsProvider);
    final subscription = ref.watch(currentSubscriptionProvider);
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(contentItemsProvider);
        ref.invalidate(currentSubscriptionProvider);
      },
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            title: const BrandLogo(compact: true),
            actions: [
              IconButton(onPressed: () => context.push('/notifications'), icon: const Icon(Icons.notifications_rounded)),
              IconButton(onPressed: () => context.go('/discover'), icon: const Icon(Icons.search_rounded)),
            ],
          ),
          SliverToBoxAdapter(
            child: subscription.when(
              data: (sub) => sub.active ? _ActivePlanBanner(subscription: sub) : const _SubscribeBanner(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const _SubscribeBanner(),
            ),
          ),
          SliverToBoxAdapter(
            child: AsyncValueWidget<List<ContentItem>>(
              value: content,
              data: (items) {
                if (items.isEmpty) return const _EmptyHome();
                final hero = items.first;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _HeroContent(item: hero),
                    _Section(title: 'Trending now', items: items.take(10).toList(), large: true),
                    _Section(title: 'Movies', items: items.where((e) => e.contentType == 'movie').toList()),
                    _Section(title: 'Series', items: items.where((e) => e.contentType == 'series').toList()),
                    _Section(title: 'Documentaries', items: items.where((e) => e.contentType == 'documentary').toList()),
                    _Section(title: 'Education', items: items.where((e) => e.contentType == 'educational').toList()),
                    _Section(title: 'Premium creators', items: items.where((e) => e.contentType == 'premium_creator').toList()),
                    const SizedBox(height: 100),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SubscribeBanner extends StatelessWidget {
  const _SubscribeBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(gradient: AppTheme.heroGradient, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock full streaming', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  SizedBox(height: 4),
                  Text('Subscribe to watch content, reels and support creators.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            FilledButton.tonal(onPressed: () => context.push('/subscribe'), child: const Text('Plans')),
          ],
        ),
      ),
    );
  }
}

class _ActivePlanBanner extends StatelessWidget {
  const _ActivePlanBanner({required this.subscription});

  final CurrentSubscription subscription;

  @override
  Widget build(BuildContext context) {
    final plan = subscription.subscription?.plan;
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
      child: Card(
        child: ListTile(
          leading: const Icon(Icons.workspace_premium_rounded, color: AppTheme.gold),
          title: Text(plan?.name ?? 'Active subscription', style: const TextStyle(fontWeight: FontWeight.w900)),
          subtitle: Text('${plan?.maxQuality ?? 'HD'} • ${plan?.maxDevices ?? 1} device(s) • ${plan?.monthlyAwardPoints ?? 0} award points'),
          trailing: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
        ),
      ),
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({required this.item});

  final ContentItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
      child: GestureDetector(
        onTap: () => context.push('/content/${item.id}'),
        child: SizedBox(
          height: 360,
          child: Stack(
            children: [
              Positioned.fill(child: PosterImage(url: item.thumbnailUrl, borderRadius: 28)),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(.88)]),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(999)),
                      child: Text(item.typeLabel, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(height: 10),
                    Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                    const SizedBox(height: 8),
                    Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.4)),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        FilledButton.icon(onPressed: () => context.push('/player/content/${item.id}?title=${Uri.encodeComponent(item.title)}'), icon: const Icon(Icons.play_arrow_rounded), label: const Text('Watch')),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(onPressed: () => context.push('/content/${item.id}'), icon: const Icon(Icons.info_rounded), label: const Text('Details')),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.items, this.large = false});

  final String title;
  final List<ContentItem> items;
  final bool large;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, actionLabel: 'See all', onAction: () => context.go('/discover')),
        SizedBox(
          height: large ? 230 : 255,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => ContentCard(item: items[index], large: large),
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(Icons.movie_filter_rounded, size: 64, color: AppTheme.muted),
              const SizedBox(height: 12),
              const Text('No approved content yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text('Create a creator profile and upload the first movie, series, documentary or education video.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)),
              const SizedBox(height: 14),
              FilledButton(onPressed: () => context.go('/creator'), child: const Text('Open Creator Studio')),
            ],
          ),
        ),
      ),
    );
  }
}
