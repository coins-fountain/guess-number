import 'dart:ui';

class ConfettiParticle {
  Offset position;
  Offset velocity;
  double rotation;
  final double rotationSpeed;
  final Color color;

  ConfettiParticle({
    required this.position,
    required this.velocity,
    required this.rotationSpeed,
    required this.color,
  }) : rotation = 0;

  static const double gravity = 0;

  void update(double dt) {
    velocity = Offset(
      velocity.dx,
      velocity.dy + gravity * dt,
    );

    position += velocity * dt;
    rotation += rotationSpeed * dt;
  }
}
