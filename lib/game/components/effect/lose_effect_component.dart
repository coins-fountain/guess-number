import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

class LoseShakeEffect extends Component with HasGameRef {
  final Random _random = Random();

  @override
  void onMount() {
    super.onMount();

    gameRef.camera.viewfinder.removeWhere((c) => c is MoveEffect);
    gameRef.camera.viewfinder.add(
      MoveEffect.by(Vector2(_random.nextBool() ? 16 : -16, 0), EffectController(duration: 0.06, alternate: true, repeatCount: 5)),
    );

    removeFromParent();
  }
}
