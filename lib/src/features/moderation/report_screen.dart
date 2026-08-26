import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/form_field_label.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

class ReportScreen extends ConsumerStatefulWidget {
  const ReportScreen({super.key, required this.targetType, required this.targetId});

  final String targetType;
  final String targetId;

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> {
  final _description = TextEditingController();
  String _reason = 'copyright';
  bool _loading = false;

  @override
  void dispose() {
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      await ref.read(moderationRepositoryProvider).createReport(
            targetType: widget.targetType,
            targetId: widget.targetId,
            reason: _reason,
            description: _description.text.trim(),
          );
      ref.invalidate(reportsProvider);
      if (mounted) {
        showSnack(context, 'Report submitted for review');
        context.pop();
      }
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report content')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text('Help us keep Umbrella safe, legal and high quality.', style: TextStyle(height: 1.5)),
          const FormFieldLabel(label: 'Reason'),
          DropdownButtonFormField<String>(
            value: _reason,
            items: const [
              DropdownMenuItem(value: 'copyright', child: Text('Copyright or ownership issue')),
              DropdownMenuItem(value: 'harmful', child: Text('Harmful or unsafe content')),
              DropdownMenuItem(value: 'adult', child: Text('Adult or inappropriate content')),
              DropdownMenuItem(value: 'spam', child: Text('Spam or misleading')),
              DropdownMenuItem(value: 'other', child: Text('Other')),
            ],
            onChanged: (value) => setState(() => _reason = value ?? 'other'),
          ),
          const FormFieldLabel(label: 'Description'),
          TextField(controller: _description, minLines: 5, maxLines: 8, decoration: const InputDecoration(hintText: 'Explain the issue clearly...')),
          const SizedBox(height: 22),
          PrimaryButton(label: 'Submit report', icon: Icons.flag_rounded, onPressed: _submit, isLoading: _loading),
        ],
      ),
    );
  }
}
