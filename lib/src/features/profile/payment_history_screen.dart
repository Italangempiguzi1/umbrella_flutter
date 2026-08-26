import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';

class PaymentHistoryScreen extends ConsumerWidget {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payments = ref.watch(paymentHistoryProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Payment History')),
      body: AsyncValueWidget<List<PaymentRecord>>(
        value: payments,
        data: (items) {
          if (items.isEmpty) return const EmptyState(title: 'No payments yet', message: 'Payment records will appear after you start checkout.', icon: Icons.receipt_long_outlined);
          return ListView.separated(
            padding: const EdgeInsets.all(18),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final payment = items[index];
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.payments_rounded),
                  title: Text('${payment.currency} ${payment.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w900)),
                  subtitle: Text('${payment.provider} • ${payment.status}\n${payment.phone}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
