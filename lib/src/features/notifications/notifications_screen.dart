import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: AsyncValueWidget<List<AppNotification>>(
        value: notifications,
        data: (items) {
          if (items.isEmpty) return const EmptyState(title: 'No notifications', message: 'Creator, subscription and moderation updates will appear here.', icon: Icons.notifications_none_rounded);
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  leading: Icon(item.isRead ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded),
                  title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text(item.body, maxLines: 3, overflow: TextOverflow.ellipsis),
                  trailing: item.isRead
                      ? null
                      : TextButton(
                          onPressed: () async {
                            try {
                              await ref.read(notificationRepositoryProvider).markRead(item.id);
                              ref.invalidate(notificationsProvider);
                            } catch (error) {
                              showSnack(context, error.toString());
                            }
                          },
                          child: const Text('Read'),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
