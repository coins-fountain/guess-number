import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class AnimatedGradientBackground extends Component {
  final Vector2 size;
  final List<List<Color>> gradients;
  final double duration;

  int _currentIndex = 0;
  double _time = 0;

  AnimatedGradientBackground(
      this.size, {
        required this.gradients,
        this.duration = 4,
      });

  @override
  void update(double dt) {
    _time += dt;

    if (_time >= duration) {
      _time = 0;
      _currentIndex = (_currentIndex + 1) % gradients.length;
    }
  }

  @override
  void render(Canvas canvas) {
    final nextIndex = (_currentIndex + 1) % gradients.length;
    final t = (_time / duration).clamp(0.0, 1.0);

    final colors = List.generate(
      gradients[_currentIndex].length,
          (i) => Color.lerp(
        gradients[_currentIndex][i],
        gradients[nextIndex][i],
        t,
      )!,
    );

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors,
      ).createShader(
        Rect.fromLTWH(0, 0, size.x, size.y),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      paint,
    );
  }
}
