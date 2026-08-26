import 'package:flutter/material.dart';

class FormFieldLabel extends StatelessWidget {
  const FormFieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 8, top: 16),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }
}
