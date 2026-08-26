import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/form_field_label.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

class AdminToolsScreen extends ConsumerStatefulWidget {
  const AdminToolsScreen({super.key});

  @override
  ConsumerState<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends ConsumerState<AdminToolsScreen> {
  final _contentId = TextEditingController();
  final _reelId = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _contentId.dispose();
    _reelId.dispose();
    super.dispose();
  }

  Future<void> _approveContent() async {
    final id = _contentId.text.trim();
    if (id.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(contentRepositoryProvider).approve(id);
      ref.invalidate(contentItemsProvider);
      if (mounted) showSnack(context, 'Content approved');
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _approveReel() async {
    final id = _reelId.text.trim();
    if (id.isEmpty) return;
    setState(() => _loading = true);
    try {
      await ref.read(reelsRepositoryProvider).approve(id);
      ref.invalidate(reelsFeedProvider);
      if (mounted) showSnack(context, 'Reel approved');
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Quick Tools')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('This screen uses the same authenticated token. Login with a Django admin/staff account before using approval actions.', style: TextStyle(height: 1.5)),
          const FormFieldLabel(label: 'Content UUID'),
          TextField(controller: _contentId, decoration: const InputDecoration(hintText: 'Paste content ID')),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Approve Content', icon: Icons.check_circle_rounded, onPressed: _approveContent, isLoading: _loading),
          const SizedBox(height: 24),
          const FormFieldLabel(label: 'Reel UUID'),
          TextField(controller: _reelId, decoration: const InputDecoration(hintText: 'Paste reel ID')),
          const SizedBox(height: 12),
          PrimaryButton(label: 'Approve Reel', icon: Icons.verified_rounded, onPressed: _approveReel, isLoading: _loading),
        ],
      ),
    );
  }
}
