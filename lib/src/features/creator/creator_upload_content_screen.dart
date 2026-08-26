import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/form_field_label.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class CreatorUploadContentScreen extends ConsumerStatefulWidget {
  const CreatorUploadContentScreen({super.key});

  @override
  ConsumerState<CreatorUploadContentScreen> createState() => _CreatorUploadContentScreenState();
}

class _CreatorUploadContentScreenState extends ConsumerState<CreatorUploadContentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _language = TextEditingController(text: 'Swahili');
  final _ageRating = TextEditingController(text: 'General');
  final _thumbnailUrl = TextEditingController();
  final _trailerUrl = TextEditingController();
  final _sourceUrl = TextEditingController();
  final _hlsUrl = TextEditingController();
  final _mp4Url = TextEditingController();
  final _duration = TextEditingController(text: '0');
  String _type = 'movie';
  String? _category;
  bool _isPremium = true;
  bool _earlyAccess = false;
  bool _submitReview = true;
  bool _loading = false;

  @override
  void dispose() {
    for (final controller in [_title, _description, _language, _ageRating, _thumbnailUrl, _trailerUrl, _sourceUrl, _hlsUrl, _mp4Url, _duration]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final item = await ref.read(contentRepositoryProvider).create({
        'category': _category,
        'title': _title.text.trim(),
        'description': _description.text.trim(),
        'content_type': _type,
        'language': _language.text.trim(),
        'age_rating': _ageRating.text.trim(),
        'thumbnail_url': _thumbnailUrl.text.trim(),
        'trailer_url': _trailerUrl.text.trim(),
        'duration_seconds': int.tryParse(_duration.text.trim()) ?? 0,
        'is_premium': _isPremium,
        'early_access': _earlyAccess,
        'source_file_url': _sourceUrl.text.trim(),
        'hls_manifest_url': _hlsUrl.text.trim(),
        'mp4_url': _mp4Url.text.trim(),
        'quality_label': '720p',
      });
      if (_submitReview) await ref.read(contentRepositoryProvider).submitForReview(item.id);
      ref.invalidate(contentItemsProvider);
      ref.invalidate(creatorDashboardProvider);
      if (mounted) {
        showSnack(context, _submitReview ? 'Content uploaded and submitted for review' : 'Content saved as draft');
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
      appBar: AppBar(title: const Text('Upload Long Video')),
      body: AsyncValueWidget<List<Category>>(
        value: categories,
        data: (categoryList) => Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const FormFieldLabel(label: 'Title'),
              TextFormField(controller: _title, validator: (value) => value == null || value.trim().isEmpty ? 'Title is required' : null),
              const FormFieldLabel(label: 'Description'),
              TextField(controller: _description, minLines: 4, maxLines: 8),
              const FormFieldLabel(label: 'Content type'),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'movie', child: Text('Movie')),
                  DropdownMenuItem(value: 'series', child: Text('TV Series')),
                  DropdownMenuItem(value: 'documentary', child: Text('Documentary')),
                  DropdownMenuItem(value: 'educational', child: Text('Educational')),
                  DropdownMenuItem(value: 'premium_creator', child: Text('Premium Creator Content')),
                ],
                onChanged: (value) => setState(() => _type = value ?? 'movie'),
              ),
              const FormFieldLabel(label: 'Category'),
              DropdownButtonFormField<String?>(
                value: _category,
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('No category')),
                  ...categoryList.map((category) => DropdownMenuItem<String?>(value: category.id, child: Text(category.name))),
                ],
                onChanged: (value) => setState(() => _category = value),
              ),
              const FormFieldLabel(label: 'Language'),
              TextField(controller: _language),
              const FormFieldLabel(label: 'Age rating'),
              TextField(controller: _ageRating),
              const FormFieldLabel(label: 'Thumbnail URL'),
              TextField(controller: _thumbnailUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'Trailer URL'),
              TextField(controller: _trailerUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'Video source URL'),
              TextField(controller: _sourceUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'HLS manifest URL'),
              TextField(controller: _hlsUrl, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'MP4 URL'),
              TextField(controller: _mp4Url, keyboardType: TextInputType.url),
              const FormFieldLabel(label: 'Duration in seconds'),
              TextField(controller: _duration, keyboardType: TextInputType.number),
              SwitchListTile(value: _isPremium, onChanged: (value) => setState(() => _isPremium = value), title: const Text('Premium content')),
              SwitchListTile(value: _earlyAccess, onChanged: (value) => setState(() => _earlyAccess = value), title: const Text('Early access')),
              SwitchListTile(value: _submitReview, onChanged: (value) => setState(() => _submitReview = value), title: const Text('Submit for review immediately')),
              const SizedBox(height: 18),
              PrimaryButton(label: 'Upload Content', icon: Icons.cloud_upload_rounded, onPressed: _submit, isLoading: _loading),
            ],
          ),
        ),
      ),
    );
  }
}
