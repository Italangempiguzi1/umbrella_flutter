import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/form_field_label.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class CreatorProfileSetupScreen extends ConsumerStatefulWidget {
  const CreatorProfileSetupScreen({super.key});

  @override
  ConsumerState<CreatorProfileSetupScreen> createState() => _CreatorProfileSetupScreenState();
}

class _CreatorProfileSetupScreenState extends ConsumerState<CreatorProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayName = TextEditingController();
  final _bio = TextEditingController();
  final _profileImageUrl = TextEditingController();
  final _coverImageUrl = TextEditingController();
  final _payoutPhone = TextEditingController();
  final _bankName = TextEditingController();
  final _bankAccountName = TextEditingController();
  final _bankAccountNumber = TextEditingController();
  bool _loaded = false;
  bool _loading = false;

  @override
  void dispose() {
    for (final controller in [_displayName, _bio, _profileImageUrl, _coverImageUrl, _payoutPhone, _bankName, _bankAccountName, _bankAccountNumber]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fill(CreatorProfile? profile) {
    if (_loaded || profile == null) return;
    _loaded = true;
    _displayName.text = profile.displayName;
    _bio.text = profile.bio;
    _profileImageUrl.text = profile.profileImageUrl;
    _coverImageUrl.text = profile.coverImageUrl;
    _payoutPhone.text = profile.payoutPhone;
    _bankName.text = profile.bankName;
    _bankAccountName.text = profile.bankAccountName;
    _bankAccountNumber.text = profile.bankAccountNumber;
  }

  Future<void> _save(CreatorProfile? existing) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final payload = {
      'display_name': _displayName.text.trim(),
      'bio': _bio.text.trim(),
      'profile_image_url': _profileImageUrl.text.trim(),
      'cover_image_url': _coverImageUrl.text.trim(),
      'payout_phone': _payoutPhone.text.trim(),
      'bank_name': _bankName.text.trim(),
      'bank_account_name': _bankAccountName.text.trim(),
      'bank_account_number': _bankAccountNumber.text.trim(),
    };
    try {
      if (existing == null) {
        await ref.read(creatorRepositoryProvider).createProfile(payload);
      } else {
        await ref.read(creatorRepositoryProvider).updateProfile(payload);
      }
      ref.invalidate(creatorProfileProvider);
      await ref.read(authControllerProvider.notifier).refreshUser();
      if (mounted) {
        showSnack(context, 'Creator profile saved');
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
    final profile = ref.watch(creatorProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Creator Profile')),
      body: profile.when(
        data: (existing) {
          _fill(existing);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const FormFieldLabel(label: 'Display name'),
                TextFormField(controller: _displayName, validator: (value) => value == null || value.trim().isEmpty ? 'Display name is required' : null),
                const FormFieldLabel(label: 'Bio'),
                TextField(controller: _bio, minLines: 3, maxLines: 5),
                const FormFieldLabel(label: 'Profile image URL'),
                TextField(controller: _profileImageUrl, keyboardType: TextInputType.url),
                const FormFieldLabel(label: 'Cover image URL'),
                TextField(controller: _coverImageUrl, keyboardType: TextInputType.url),
                const FormFieldLabel(label: 'Payout phone'),
                TextField(controller: _payoutPhone, keyboardType: TextInputType.phone),
                const FormFieldLabel(label: 'Bank name'),
                TextField(controller: _bankName),
                const FormFieldLabel(label: 'Bank account name'),
                TextField(controller: _bankAccountName),
                const FormFieldLabel(label: 'Bank account number'),
                TextField(controller: _bankAccountNumber),
                const SizedBox(height: 22),
                PrimaryButton(label: existing == null ? 'Create Profile' : 'Save Changes', icon: Icons.save_rounded, onPressed: () => _save(existing), isLoading: _loading),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(error.toString())),
      ),
    );
  }
}
