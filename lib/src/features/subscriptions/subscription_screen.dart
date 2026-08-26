import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/primary_button.dart';
import '../../core/widgets/snack.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  String? _selectedCode;
  String _provider = 'mobile_money';
  final _phone = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    final code = _selectedCode;
    if (code == null) {
      showSnack(context, 'Select a plan first');
      return;
    }
    setState(() => _loading = true);
    try {
      final payment = await ref.read(paymentRepositoryProvider).initiate(planCode: code, provider: _provider, phone: _phone.text.trim());
      ref.invalidate(paymentHistoryProvider);
      if (mounted) showSnack(context, 'Payment created: ${payment.status}. Connect provider callback to activate subscription.');
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _activateDev() async {
    final code = _selectedCode;
    if (code == null) {
      showSnack(context, 'Select a plan first');
      return;
    }
    setState(() => _loading = true);
    try {
      await ref.read(subscriptionRepositoryProvider).activateDev(code);
      ref.invalidate(currentSubscriptionProvider);
      if (mounted) {
        showSnack(context, 'Subscription activated for MVP testing');
        context.go('/home');
      }
    } catch (error) {
      if (mounted) showSnack(context, error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider);
    final current = ref.watch(currentSubscriptionProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Choose Plan')),
      body: AsyncValueWidget<List<Plan>>(
        value: plans,
        data: (items) => ListView(
          padding: const EdgeInsets.all(18),
          children: [
            current.when(
              data: (sub) => sub.active
                  ? Card(
                      child: ListTile(
                        leading: const Icon(Icons.check_circle_rounded, color: Colors.greenAccent),
                        title: Text('Current: ${sub.subscription?.plan?.name ?? 'Active plan'}', style: const TextStyle(fontWeight: FontWeight.w900)),
                        subtitle: Text('Expires: ${sub.subscription?.expiresAt?.toLocal().toString().split('.').first ?? 'N/A'}'),
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const Text('Premium entertainment for every viewer', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -.7)),
            const SizedBox(height: 8),
            const Text('Select a subscription plan to unlock long-form content, reels, ad-free streaming and creator reward points.', style: TextStyle(color: AppTheme.muted, height: 1.5)),
            const SizedBox(height: 18),
            ...items.map((plan) => _PlanCard(plan: plan, selected: _selectedCode == plan.code, onTap: () => setState(() => _selectedCode = plan.code))),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              value: _provider,
              decoration: const InputDecoration(labelText: 'Payment provider'),
              items: const [
                DropdownMenuItem(value: 'mobile_money', child: Text('Mobile Money')),
                DropdownMenuItem(value: 'card', child: Text('Card')),
                DropdownMenuItem(value: 'bank', child: Text('Bank')),
                DropdownMenuItem(value: 'internal', child: Text('Internal')),
              ],
              onChanged: (value) => setState(() => _provider = value ?? 'mobile_money'),
            ),
            const SizedBox(height: 12),
            TextField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_rounded), hintText: 'Payment phone number')),
            const SizedBox(height: 18),
            PrimaryButton(label: 'Start Payment', icon: Icons.payments_rounded, onPressed: _initiatePayment, isLoading: _loading),
            const SizedBox(height: 10),
            OutlinedButton.icon(onPressed: _loading ? null : _activateDev, icon: const Icon(Icons.science_rounded), label: const Text('Activate for MVP Testing')),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.selected, required this.onTap});

  final Plan plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            gradient: selected ? AppTheme.heroGradient : null,
            color: selected ? null : AppTheme.surface,
            border: Border.all(color: selected ? Colors.transparent : Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(plan.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900))),
                  if (selected) const Icon(Icons.check_circle_rounded),
                ],
              ),
              const SizedBox(height: 8),
              Text(moneyTzs(plan.priceTzs), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              Text(plan.description, style: TextStyle(color: selected ? Colors.white : AppTheme.muted, height: 1.45)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Feature(label: '${plan.maxDevices} device(s)'),
                  _Feature(label: plan.maxQuality),
                  _Feature(label: '${plan.monthlyAwardPoints} award points'),
                  if (plan.downloadsEnabled) const _Feature(label: 'Downloads'),
                  if (plan.earlyAccessEnabled) const _Feature(label: 'Early access'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: Colors.black.withOpacity(.25), borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
    );
  }
}
