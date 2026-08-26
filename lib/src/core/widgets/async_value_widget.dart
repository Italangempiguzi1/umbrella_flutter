import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'empty_state.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  const AsyncValueWidget({super.key, required this.value, required this.data, this.loading, this.emptyMessage});

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget? loading;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      loading: () => loading ?? const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) => EmptyState(
        title: 'Unable to load data',
        message: error.toString().replaceFirst('Exception: ', ''),
        icon: Icons.cloud_off_rounded,
      ),
    );
  }
}
