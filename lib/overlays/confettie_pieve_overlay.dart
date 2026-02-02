import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:guess_number_game/model/confetti_particle_model.dart';


class ConfettiOverlay extends StatefulWidget {
  final VoidCallback onFinished;

  const ConfettiOverlay({super.key, required this.onFinished});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final Random _random = Random();
  Duration _lastTime = Duration.zero;

  final List<ConfettiParticle> _particles = [];
  late Size _screenSize;


  static const int particleCount = 40;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_tick)..start();
  }

  void _tick(Duration elapsed) {
    final dt = (elapsed - _lastTime).inMicroseconds / 1e6;
    _lastTime = elapsed;

    setState(() {
      for (final p in _particles) {
        p.update(dt);
      }

      _particles.removeWhere(
            (p) => p.position.dy > _screenSize.height + 20,
      );

      if (_particles.isEmpty) {
        widget.onFinished();
      }
    });
  }

  void _spawnParticles(Size size) {
    _screenSize = size;
    if (_particles.isNotEmpty) return;

    for (int i = 0; i < particleCount; i++) {
      _particles.add(
        ConfettiParticle(
          position: Offset(
            size.width / 2 + _random.nextDouble() * 140 - 70,
            -10,
          ),
          velocity: Offset(
            _random.nextDouble() * 200 - 100,
            200 + _random.nextDouble() * 200,
          ),
          rotationSpeed: _random.nextDouble() * 10,
          color: Colors.primaries[
          _random.nextInt(Colors.primaries.length)],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (_, constraints) {
          final size = Size(
            constraints.maxWidth,
            constraints.maxHeight,
          );

          _spawnParticles(size);

          return CustomPaint(
            size: size,
            painter: _ConfettiPainter(_particles),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}
class _ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;

  _ConfettiPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      canvas.save();

      canvas.translate(p.position.dx, p.position.dy);
      canvas.rotate(p.rotation);

      final paint = Paint()..color = p.color;
      canvas.drawRect(
         Rect.fromCenter(
          center: Offset.zero,
          width: 8,
          height: 8,
        ),
        paint,
      );

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_) => true;
}

