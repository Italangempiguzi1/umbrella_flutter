import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/poster_image.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import '../engagement/award_dialog.dart';
import '../engagement/vote_dialog.dart';

class ReelsFeedScreen extends ConsumerWidget {
  const ReelsFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reels = ref.watch(reelsFeedProvider);
    return AsyncValueWidget<List<ReelItem>>(
      value: reels,
      data: (items) {
        if (items.isEmpty) return const EmptyState(title: 'No reels yet', message: 'Creators can upload short reels from Creator Studio.', icon: Icons.video_collection_outlined);
        return PageView.builder(
          scrollDirection: Axis.vertical,
          itemCount: items.length,
          itemBuilder: (context, index) => _ReelPage(reel: items[index]),
        );
      },
    );
  }
}

class _ReelPage extends ConsumerWidget {
  const _ReelPage({required this.reel});

  final ReelItem reel;

  Future<void> _like(BuildContext context, WidgetRef ref) async {
    try {
      final liked = await ref.read(engagementRepositoryProvider).toggleLike(targetType: 'reel', targetId: reel.id);
      showSnack(context, liked ? 'Liked reel' : 'Like removed');
    } catch (error) {
      showSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Positioned.fill(child: PosterImage(url: reel.thumbnailUrl, borderRadius: 0, icon: Icons.video_collection_rounded)),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black.withOpacity(.15), Colors.black.withOpacity(.88)]),
            ),
          ),
        ),
        Center(
          child: GestureDetector(
            onTap: () => context.push('/player/reel/${reel.id}?title=${Uri.encodeComponent(reel.title)}'),
            child: Container(
              height: 82,
              width: 82,
              decoration: BoxDecoration(color: Colors.black.withOpacity(.45), shape: BoxShape.circle, border: Border.all(color: Colors.white30)),
              child: const Icon(Icons.play_arrow_rounded, size: 54),
            ),
          ),
        ),
        Positioned(
          left: 18,
          right: 92,
          bottom: 38,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('@${reel.creatorName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(reel.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -.4)),
              const SizedBox(height: 8),
              Text(reel.caption, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, height: 1.45)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _Pill(icon: Icons.visibility_rounded, label: compactNumber(reel.totalViews)),
                  if (reel.categoryName.isNotEmpty) _Pill(icon: Icons.category_rounded, label: reel.categoryName),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 16,
          bottom: 42,
          child: Column(
            children: [
              _ActionButton(icon: Icons.favorite_rounded, label: 'Like', onTap: () => _like(context, ref)),
              _ActionButton(icon: Icons.comment_rounded, label: 'Chat', onTap: () => context.push('/comments/reel/${reel.id}')),
              _ActionButton(icon: Icons.star_rounded, label: 'Vote', onTap: () => showVoteDialog(context, ref, targetType: 'reel', targetId: reel.id)),
              _ActionButton(icon: Icons.card_giftcard_rounded, label: 'Award', onTap: () => showAwardDialog(context, ref, creatorId: reel.creator, targetType: 'reel', targetId: reel.id)),
              _ActionButton(icon: Icons.share_rounded, label: 'Share', onTap: () => Share.share('Watch ${reel.title} on Umbrella')),
              _ActionButton(icon: Icons.flag_rounded, label: 'Report', onTap: () => context.push('/report/reel/${reel.id}')),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(color: Colors.black.withOpacity(.45), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800)),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withOpacity(.45), borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 14, color: AppTheme.muted), const SizedBox(width: 5), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))]),
    );
  }
}
