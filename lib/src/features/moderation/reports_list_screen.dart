import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = ref.watch(reportsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My Reports')),
      body: AsyncValueWidget<List<ReportItem>>(
        value: reports,
        data: (items) {
          if (items.isEmpty) return const EmptyState(title: 'No reports', message: 'Reports you submit will appear here.', icon: Icons.flag_outlined);
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final report = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.flag_rounded),
                  title: Text(report.reason, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${report.targetType} • ${report.status}\n${report.description}', maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
