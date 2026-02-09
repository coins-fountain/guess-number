import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:guess_number_game/game/guess_number_game.dart';

class ConfettiPiece extends PositionComponent with HasGameReference<GuessNumberGame> {
  final Paint paint;
  final Vector2 velocity;
  final double rotationSpeed;

  ConfettiPiece({required Vector2 position, required this.paint, required this.velocity, required this.rotationSpeed}) {
    size = Vector2.all(8);
    anchor = Anchor.center;
    this.position = position;
  }

  @override
  void update(double dt) {
    position += velocity * dt;
    angle += rotationSpeed * dt;

    if (position.y > game.size.y + 20) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), paint);
  }
}
