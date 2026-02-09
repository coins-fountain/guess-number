import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_number_game/component/confetti_piece_component.dart';

class GoGrey extends FlameGame {
  int? _target;

  int attemptsLeft = 4;
  bool isGameStarted = false;
  bool isGameOver = false;
  int? get debugTarget => _target;

  int? currentLower;
  int? currentUpper;


  final Random _random = Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleComponent(
        size: size,
        priority: -20,
        paint: Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFE0E0E0),
            ],
          ).createShader(
            Rect.fromLTWH(0, 0, size.x, size.y),
          ),
      ),
    );
    final image = await images.load('background/background_image.png');

    final sprite = Sprite(image);
    final bg = SpriteComponent(
      sprite: sprite,
      anchor: Anchor.center,
      position: size / 2,
      priority: -10,
    );

    final imageSize = Vector2(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final scaleX = size.x / imageSize.x;
    final scaleY = size.y / imageSize.y;
    final scale = max(scaleX, scaleY);

    bg
      ..size = imageSize
      ..scale = Vector2.all(scale);

    add(bg);


    overlays.add('GuessInput');
  }


  void startGame({required int min, required int max}) {
    attemptsLeft = 4;
    isGameStarted = true;
    isGameOver = false;

    currentLower = min;
    currentUpper = max;

    _target = _random.nextInt(max - min + 1) + min;
    debugPrint('🎯 Target: $_target');
  }



  String checkGuess(int guess) {
    if (!isGameStarted) return 'Game not started';

    attemptsLeft--;
    HapticFeedback.lightImpact();

    if (guess == _target) {
      isGameStarted = false;
      isGameOver = true;

      overlays.add('Confetti');
      playWinAnimation();

      return '🎉 Correct! You win!';
    }
    if (guess < _target!) {
      currentLower = max(currentLower!, guess + 1);
    } else {
      currentUpper = min(currentUpper!, guess - 1);
    }

    if (attemptsLeft <= 0) {
      isGameStarted = false;
      isGameOver = true;

      HapticFeedback.heavyImpact();

      playShake();
      return '❌ You Wrong Guess! Number was $_target';
    }

    playShake();

    return guess < _target!
        ? '⬆️ Too low — $attemptsLeft attempts left'
        : '⬇️ Too high — $attemptsLeft attempts left';
  }
  void playWinAnimation() {
    if (size.isZero()) return;

    for (int i = 0; i < 40; i++) {
      add(
        ConfettiPiece(
          position: Vector2(
            size.x / 2 + _random.nextDouble() * 140 - 70,
            -10,
          ),
          velocity: Vector2(
            _random.nextDouble() * 200 - 100,
            200 + _random.nextDouble() * 200,
          ),
          rotationSpeed: _random.nextDouble() * 10,
          paint: Paint()
            ..color = Colors.primaries[
            _random.nextInt(Colors.primaries.length)],
        ),
      );
    }
  }

  void playShake() {
    camera.viewfinder.removeWhere((c) => c is MoveEffect);
    camera.viewfinder.add(
      MoveEffect.by(
        Vector2(_random.nextBool() ? 16 : -16, 0), // stronger
        EffectController(
          duration: 0.06,
          alternate: true,
          repeatCount: 5,
        ),
      ),
    );
  }


  @override
  Color backgroundColor() => Colors.transparent;
}
