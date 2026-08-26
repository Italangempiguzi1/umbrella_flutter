import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

Future<void> showAwardDialog(
  BuildContext context,
  WidgetRef ref, {
  required String creatorId,
  required String targetType,
  required String targetId,
}) async {
  int points = 5;
  final message = TextEditingController();
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Award creator'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Award points help distribute the creator reward pool.'),
            const SizedBox(height: 14),
            Row(
              children: [
                const Text('Points', style: TextStyle(fontWeight: FontWeight.w800)),
                Expanded(
                  child: Slider(
                    value: points.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '$points',
                    activeColor: AppTheme.gold,
                    onChanged: (value) => setState(() => points = value.round()),
                  ),
                ),
                Text('$points', style: const TextStyle(fontWeight: FontWeight.w900)),
              ],
            ),
            TextField(controller: message, maxLength: 120, decoration: const InputDecoration(hintText: 'Optional message')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(engagementRepositoryProvider).award(
                      creatorId: creatorId,
                      targetType: targetType,
                      targetId: targetId,
                      points: points,
                      message: message.text.trim(),
                    );
                if (context.mounted) {
                  Navigator.pop(context);
                  showSnack(context, 'Creator awarded successfully');
                }
              } catch (error) {
                if (context.mounted) showSnack(context, error.toString());
              }
            },
            child: const Text('Award'),
          ),
        ],
      ),
    ),
  );
  message.dispose();
}
