import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedEyes extends StatefulWidget {
  const AnimatedEyes({super.key});

  @override
  State<AnimatedEyes> createState() => _AnimatedEyesState();
}

class _AnimatedEyesState extends State<AnimatedEyes>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final dx = sin(_controller.value * pi * 2) * 4;
        final rotate = sin(_controller.value * pi * 2) * 0.08;

        return Transform.translate(
          offset: Offset(dx, 0),
          child: Transform.rotate(
            angle: rotate,
            child: const Text(
              '👀',
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      },
    );
  }

}
