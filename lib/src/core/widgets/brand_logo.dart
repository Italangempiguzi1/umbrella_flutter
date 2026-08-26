import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../theme/app_theme.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: compact ? 36 : 48,
          width: compact ? 36 : 48,
          decoration: BoxDecoration(
            gradient: AppTheme.heroGradient,
            borderRadius: BorderRadius.circular(compact ? 12 : 16),
            boxShadow: [
              BoxShadow(color: AppTheme.primary.withOpacity(.28), blurRadius: 24, offset: const Offset(0, 10)),
            ],
          ),
          child: const Icon(Icons.umbrella_rounded, color: Colors.white),
        ),
        const SizedBox(width: 12),
        if (!compact)
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppConfig.appName, style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -.5)),
              SizedBox(height: 2),
              Text(AppConfig.appTagline, style: TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600)),
            ],
          ),
      ],
    );
  }
}
