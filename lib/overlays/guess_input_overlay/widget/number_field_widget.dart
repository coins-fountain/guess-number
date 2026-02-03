import 'package:flutter/material.dart';

class NumberFieldWidget extends StatelessWidget {
  final TextEditingController c;
  final String title;
  final bool enabled;
  const NumberFieldWidget({
    super.key,
    required this.c,
    required this.enabled,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          enabled: enabled,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: title,
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
