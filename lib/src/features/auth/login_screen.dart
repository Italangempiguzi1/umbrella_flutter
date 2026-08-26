import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_logo.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/providers/app_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await ref.read(authControllerProvider.notifier).login(username: _username.text.trim(), password: _password.text);
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const BrandLogo(),
              const SizedBox(height: 48),
              const Text('Welcome back', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, letterSpacing: -.8)),
              const SizedBox(height: 8),
              const Text('Sign in to continue watching, scrolling and rewarding creators.', style: TextStyle(color: AppTheme.muted, height: 1.5)),
              const SizedBox(height: 28),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _username,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.person_rounded), hintText: 'Username'),
                      validator: (value) => value == null || value.trim().isEmpty ? 'Enter your username' : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_rounded),
                        hintText: 'Password',
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(_obscure ? Icons.visibility_rounded : Icons.visibility_off_rounded),
                        ),
                      ),
                      validator: (value) => value == null || value.length < 8 ? 'Password must be at least 8 characters' : null,
                      onFieldSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 22),
                    PrimaryButton(label: 'Login', icon: Icons.login_rounded, onPressed: _submit, isLoading: auth.isLoading),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('New to Umbrella?', style: TextStyle(color: AppTheme.muted)),
                  TextButton(onPressed: () => context.go('/register'), child: const Text('Create account')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
