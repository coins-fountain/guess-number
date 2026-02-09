import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:guess_number_game/game/components/background/background_component.dart';
import 'package:guess_number_game/game/components/effect/lose_effect_component.dart';
import 'package:guess_number_game/game/components/effect/win_effect_component.dart';
import 'package:guess_number_game/game/components/guess_game_state.dart';
import 'package:guess_number_game/game/state/guess_number_state.dart';
import 'components/guess_logic_component.dart';

class GuessNumberGame extends FlameGame {
  late GuessLogicComponent _logic;
  late GuessStateComponent _state;

  GuessGameState get state => _state.state;

  bool get isGameStarted => state.status == GameStatus.playing;

  bool get isGameOver => state.status == GameStatus.win || state.status == GameStatus.lose;

  int? get currentLower => state.lower;

  int? get currentUpper => state.upper;

  int get attemptsLeft => state.attemptsLeft;

  @override
  Future<void> onLoad() async {
    add(
      BackgroundComponent(
        assetPath: 'background/background_image.png',
      ),
    );
    _state = GuessStateComponent();
    _logic = GuessLogicComponent();

    addAll([_state, _logic]);

    overlays.add('GuessInput');
  }

  void startGame({required int min, required int max}) {
    _logic.start(min, max);
  }

  void submitGuess(int value) {
    final prev = state.status;
    _logic.submitGuess(value);

    if (state.status == GameStatus.win && prev != GameStatus.win) {
      overlays.add('Confetti');
      add(WinConfettiEffect());
    }

    if (state.status == GameStatus.lose && prev != GameStatus.lose) {
      add(LoseShakeEffect());
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
  }

  @override
  Color backgroundColor() => Colors.transparent;
}
