import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/poster_image.dart';
import '../../data/models/app_models.dart';

class ContentCard extends StatelessWidget {
  const ContentCard({super.key, required this.item, this.large = false});

  final ContentItem item;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final width = large ? 220.0 : 150.0;
    return GestureDetector(
      onTap: () => context.push('/content/${item.id}'),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: large ? 16 / 10 : 3 / 4,
              child: Stack(
                children: [
                  Positioned.fill(child: PosterImage(url: item.thumbnailUrl, borderRadius: 22)),
                  if (item.earlyAccess)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                        decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(999)),
                        child: const Text('Early', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 11)),
                      ),
                    ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(color: Colors.black.withOpacity(.65), borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility_rounded, size: 14),
                          const SizedBox(width: 4),
                          Text(compactNumber(item.totalViews), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w900, height: 1.15)),
            const SizedBox(height: 4),
            Text('${item.typeLabel} • ${item.language}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
