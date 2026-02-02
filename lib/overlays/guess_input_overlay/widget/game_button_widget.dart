import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GameButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const GameButtonWidget({super.key, required this.text, required this.onTap, this.color = const Color(0xFF6C63FF)});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => HapticFeedback.lightImpact(),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), offset: const Offset(0, 6), blurRadius: 10)],
        ),
        child: Center(child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.6))),
      ),
    );
  }
}
