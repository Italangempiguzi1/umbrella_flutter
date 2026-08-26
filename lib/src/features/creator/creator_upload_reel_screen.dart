import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/form_field_label.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class CreatorUploadReelScreen extends ConsumerStatefulWidget {
  const CreatorUploadReelScreen({super.key});

  @override
  ConsumerState<CreatorUploadReelScreen> createState() => _CreatorUploadReelScreenState();
}

class _CreatorUploadReelScreenState extends ConsumerState<CreatorUploadReelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _caption = TextEditingController();
  final _videoUrl = TextEditingController();
  final _hlsUrl = TextEditingController();
  final _thumbnailUrl = TextEditingController();
  final _duration = TextEditingController(text: '0');
  String? _category;
  bool _submitReview = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final controller in [_title, _caption, _videoUrl, _hlsUrl, _thumbnailUrl, _duration]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final item = await ref.read(reelsRepositoryProvider).create({
        'category': _category,
        'title': _title.text.trim(),
        'caption': _caption.text.trim(),
        'video_url': _videoUrl.text.trim(),
        'hls_manifest_url': _hlsUrl.text.trim(),
        'thumbnail_url': _thumbnailUrl.text.trim(),
        'duration_seconds': int.tryParse(_duration.text.trim()) ?? 0,
      });
      if (_submitReview) await ref.read(reelsRepositoryProvider).submitForReview(item.id);
      ref.invalidate(reelsFeedProvider);
      ref.invalidate(allReelsProvider);
      ref.invalidate(creatorDashboardProvider);
      if (mounted) {
        showSnack(context, _submitReview ? 'Reel uploaded and submitted for review' : 'Reel saved as draft');
        context.go('/creator');
      }
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Reel')),
      body: AsyncValueWidget<List<Category>>(
        value: categories,
        data: (categoryList) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const FormFieldLabel(label: 'Reel title'),
              TextFormField(controller: _title, validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null),
              const FormFieldLabel(label: 'Caption'),
              TextField(controller: _caption, minLines: 3, maxLines: 6),
              const FormFieldLabel(label: 'Category'),
              DropdownButtonFormField<String?>(
                value: _category,
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('No category')),
                  ...categoryList.map((category) => DropdownMenuItem<String?>(value: category.id, child: Text(category.name))),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
              const FormFieldLabel(label: 'Video URL'),
              TextField(controller: _videoUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'HLS manifest URL'),
              TextField(controller: _hlsUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'Thumbnail URL'),
              TextField(controller: _thumbnailUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'Duration in seconds'),
              TextField(controller: _duration, keyboardType: TextInputType.number),
              SwitchListTile(value: _submitReview, onChanged: (value) => setState(() => _submitReview = value), title: const Text('Submit for review immediately')),
              const SizedBox(height: 18),
              PrimaryButton(label: 'Upload Reel', icon: Icons.cloud_upload_rounded, onPressed: _submit, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
