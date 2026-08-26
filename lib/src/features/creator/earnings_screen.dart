import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnings = ref.watch(earningsProvider);
    final payouts = ref.watch(payoutsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Earnings & Payouts')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(earningsProvider);
          ref.invalidate(payoutsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text('Creator Earnings', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            AsyncValueWidget<List<CreatorEarning>>(
              value: earnings,
              data: (items) {
                if (items.isEmpty) return const EmptyState(title: 'No earnings yet', message: 'Monthly earnings will appear after reward calculations.', icon: Icons.wallet_outlined);
                return Column(
                  children: items.map((item) => Card(child: ListTile(leading: const Icon(Icons.account_balance_wallet_rounded), title: Text(moneyTzs(item.amountTzs)), subtitle: Text('Score ${item.creatorScore} • ${item.status}')))).toList(),
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('Payouts', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            AsyncValueWidget<List<PayoutRecord>>(
              value: payouts,
              data: (items) {
                if (items.isEmpty) return const EmptyState(title: 'No payouts yet', message: 'Payout history will appear here.', icon: Icons.payments_outlined);
                return Column(
                  children: items.map((item) => Card(child: ListTile(leading: const Icon(Icons.payments_rounded), title: Text(moneyTzs(item.amountTzs)), subtitle: Text('${item.status} • ${item.payoutReference}')))).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
