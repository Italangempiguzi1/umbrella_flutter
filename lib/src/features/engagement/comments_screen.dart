import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class CommentsScreen extends ConsumerStatefulWidget {
  const CommentsScreen({super.key, required this.targetType, required this.targetId});

  final String targetType;
  final String targetId;

  @override
  ConsumerState<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends ConsumerState<CommentsScreen> {
  final _controller = TextEditingController();
  bool _posting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _post() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _posting = true);
    try {
      await ref.read(engagementRepositoryProvider).addComment(targetType: widget.targetType, targetId: widget.targetId, text: text);
      _controller.clear();
      ref.invalidate(commentsProvider((targetType: widget.targetType, targetId: widget.targetId)));
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _posting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comments = ref.watch(commentsProvider((targetType: widget.targetType, targetId: widget.targetId)));
    return Scaffold(
      appBar: AppBar(title: const Text('Comments')),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueWidget<List<CommentItem>>(
              value: comments,
              data: (items) {
                if (items.isEmpty) return const EmptyState(title: 'No comments yet', message: 'Be the first to start the conversation.', icon: Icons.comment_bank_rounded);
                return ListView.separated(
                  padding: const EdgeInsets.all(18),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 20),
                  itemBuilder: (context, index) {
                    final comment = items[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(child: Text(comment.username.isEmpty ? 'U' : comment.username[0].toUpperCase())),
                      title: Text(comment.username, style: const TextStyle(fontWeight: FontWeight.w900)),
                      subtitle: Text(comment.text, style: const TextStyle(color: Colors.white70, height: 1.4)),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(child: TextField(controller: _controller, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'Write a comment...'))),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    backgroundColor: AppTheme.primary,
                    child: IconButton(onPressed: _posting ? null : _post, icon: _posting ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send_rounded)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
