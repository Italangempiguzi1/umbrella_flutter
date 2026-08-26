import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

Future<void> showVoteDialog(BuildContext context, WidgetRef ref, {required String targetType, required String targetId}) async {
  int score = 5;
  await showDialog<void>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: const Text('Rate content quality'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            final value = index + 1;
            return IconButton(
              onPressed: () => setState(() => score = value),
              icon: Icon(value <= score ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber, size: 34),
            );
          }),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              try {
                await ref.read(engagementRepositoryProvider).vote(targetType: targetType, targetId: targetId, score: score);
                if (context.mounted) {
                  Navigator.pop(context);
                  showSnack(context, 'Thank you for voting');
                }
              } catch (error) {
                if (context.mounted) showSnack(context, error.toString());
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    ),
  );
}
