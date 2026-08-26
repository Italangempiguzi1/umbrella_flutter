import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/poster_image.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../engagement/award_dialog.dart';
import '../engagement/vote_dialog.dart';

class ContentDetailScreen extends ConsumerWidget {
  const ContentDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _like(BuildContext context, WidgetRef ref) async {
    try {
      final liked = await ref.read(engagementRepositoryProvider).toggleLike(targetType: 'content', targetId: id);
      showSnack(context, liked ? 'Added to likes' : 'Removed from likes');
    } catch (error) {
      showSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(contentDetailProvider(id));
    return Scaffold(
      body: AsyncValueWidget<ContentItem>(
        value: detail,
        data: (item) => CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 420,
              actions: [
                IconButton(onPressed: () => Share.share('Watch ${item.title} on Umbrella'), icon: const Icon(Icons.share_rounded)),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  children: [
                    Positioned.fill(child: PosterImage(url: item.thumbnailUrl, borderRadius: 0)),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black.withOpacity(.94)]),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 22,
                      right: 22,
                      bottom: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _Chip(label: item.typeLabel, color: AppTheme.primary),
                              _Chip(label: item.language),
                              _Chip(label: item.ageRating),
                              if (item.isPremium) const _Chip(label: 'Premium', color: AppTheme.gold, darkText: true),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -1)),
                          const SizedBox(height: 8),
                          Text('By ${item.creatorName} • ${compactNumber(item.totalViews)} views • ${formatDuration(item.durationSeconds)}', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PrimaryButton(label: 'Watch now', icon: Icons.play_arrow_rounded, onPressed: () => context.push('/player/content/${item.id}?title=${Uri.encodeComponent(item.title)}')),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton.icon(onPressed: () => _like(context, ref), icon: const Icon(Icons.favorite_border_rounded), label: const Text('Like'))),
                        const SizedBox(width: 10),
                        Expanded(child: OutlinedButton.icon(onPressed: () => showVoteDialog(context, ref, targetType: 'content', targetId: item.id), icon: const Icon(Icons.star_border_rounded), label: const Text('Vote'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: OutlinedButton.icon(onPressed: () => showAwardDialog(context, ref, creatorId: item.creator, targetType: 'content', targetId: item.id), icon: const Icon(Icons.card_giftcard_rounded), label: const Text('Award'))),
                        const SizedBox(width: 10),
                        Expanded(child: OutlinedButton.icon(onPressed: () => context.push('/comments/content/${item.id}'), icon: const Icon(Icons.comment_rounded), label: const Text('Comments'))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Text(item.description.isEmpty ? 'No description provided.' : item.description, style: const TextStyle(height: 1.55, color: Colors.white70)),
                    const SizedBox(height: 22),
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(backgroundColor: AppTheme.surfaceAlt, child: Icon(Icons.person_rounded)),
                        title: Text(item.creatorName, style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: const Text('Creator channel'),
                        onTap: () => context.push('/creator/public/${item.creator}'),
                        trailing: FilledButton.tonal(
                          onPressed: () async {
                            try {
                              final result = await ref.read(engagementRepositoryProvider).toggleFollow(item.creator);
                              showSnack(context, result['following'] == true ? 'Following creator' : 'Unfollowed creator');
                            } catch (error) {
                              showSnack(context, error.toString());
                            }
                          },
                          child: const Text('Follow'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/report/content/${item.id}'),
                      icon: const Icon(Icons.flag_rounded),
                      label: const Text('Report this content'),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.color, this.darkText = false});

  final String label;
  final Color? color;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color ?? Colors.black.withOpacity(.58), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: TextStyle(color: darkText ? Colors.black : Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
    );
  }
}
