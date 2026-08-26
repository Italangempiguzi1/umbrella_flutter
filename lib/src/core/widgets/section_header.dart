import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.actionLabel, this.onAction});

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }
}
