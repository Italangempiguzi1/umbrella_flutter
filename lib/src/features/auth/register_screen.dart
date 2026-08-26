import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).register(
            username: _username.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            password: _password.text,
          );
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(onPressed: () => context.go('/login'), icon: const Icon(Icons.arrow_back_rounded)),
                const SizedBox(height: 12),
                const BrandLogo(),
                const SizedBox(height: 34),
                const Text('Create your account', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -.8)),
                const SizedBox(height: 8),
                const Text('Join viewers and creators under one entertainment umbrella.', style: TextStyle(color: AppTheme.muted, height: 1.5)),
                const SizedBox(height: 26),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded), hintText: 'Username'),
                  validator: (value) => value == null || value.trim().isEmpty ? 'Username is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.email_rounded), hintText: 'Email'),
                  validator: (value) => value == null || !value.contains('@') ? 'Enter a valid email' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_rounded), hintText: 'Phone number'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _password,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_rounded),
                    hintText: 'Password',
                    suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded)),
                  ),
                  validator: (value) => value == null || value.length < 8 ? 'Password must be at least 8 characters' : null,
                ),
                const SizedBox(height: 22),
                PrimaryButton(label: 'Create Account', icon: Icons.person_add_alt_1_rounded, onPressed: _submit, isLoading: auth.isLoading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
