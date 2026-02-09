import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:guess_number_game/game/components/effect/confetti_piece_component.dart';

class WinConfettiEffect extends Component with HasGameRef {
  final Random _random = Random();

  @override
  void onMount() {
    super.onMount();

    final size = gameRef.size;
    if (size.isZero()) return;

    for (int i = 0; i < 40; i++) {
      gameRef.add(
        ConfettiPiece(
          position: Vector2(size.x / 2 + _random.nextDouble() * 140 - 70, -10),
          velocity: Vector2(_random.nextDouble() * 200 - 100, 200 + _random.nextDouble() * 200),
          rotationSpeed: _random.nextDouble() * 10,
          paint: Paint()..color = Colors.primaries[_random.nextInt(Colors.primaries.length)],
        ),
      );
    }

    removeFromParent(); // one-shot controller
  }
}
