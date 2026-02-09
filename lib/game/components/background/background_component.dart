import 'package:flame/components.dart';
import 'package:flame/game.dart';

class BackgroundComponent extends SpriteComponent
    with HasGameReference<FlameGame> {

  final String assetPath;

  BackgroundComponent({required this.assetPath});

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite(assetPath);

    size = game.size;
    position = Vector2.zero();
    anchor = Anchor.topLeft;

    priority = -100;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    super.onGameResize(gameSize);
    size = gameSize;
  }
}
