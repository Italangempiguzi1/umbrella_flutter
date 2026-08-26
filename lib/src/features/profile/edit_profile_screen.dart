import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/form_field_label.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _avatarUrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _username = TextEditingController(text: user?.username ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _phone = TextEditingController(text: user?.phone ?? '');
    _avatarUrl = TextEditingController(text: user?.avatarUrl ?? '');
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _avatarUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(
            username: _username.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            avatarUrl: _avatarUrl.text.trim(),
          );
      if (mounted) {
        showSnack(context, 'Profile updated');
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
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const FormFieldLabel(label: 'Username'),
            TextFormField(controller: _username, validator: (value) => value == null || value.trim().isEmpty ? 'Username is required' : null),
            const FormFieldLabel(label: 'Email'),
            TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, validator: (value) => value == null || !value.contains('@') ? 'Valid email required' : null),
            const FormFieldLabel(label: 'Phone'),
            TextField(controller: _phone, keyboardType: TextInputType.phone),
            const FormFieldLabel(label: 'Avatar URL'),
            TextField(controller: _avatarUrl, keyboardType: TextInputType.url),
            const SizedBox(height: 22),
            PrimaryButton(label: 'Save Profile', icon: Icons.save_rounded, onPressed: _save, isLoading: _loading),
          ],
        ),
      ),
    );
  }
}
