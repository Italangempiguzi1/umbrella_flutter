import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PosterImage extends StatelessWidget {
  const PosterImage({super.key, required this.url, this.borderRadius = 20, this.icon = Icons.movie_creation_rounded});

  final String? url;
  final double borderRadius;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final imageUrl = url ?? '';
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: imageUrl.isEmpty
          ? Container(
              color: AppTheme.surfaceAlt,
              child: Icon(icon, color: AppTheme.muted, size: 42),
            )
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(color: AppTheme.surfaceAlt),
              errorWidget: (context, url, error) => Container(
                color: AppTheme.surfaceAlt,
                child: Icon(icon, color: AppTheme.muted, size: 42),
              ),
            ),
    );
  }
}
