import 'dart:math';
import 'package:flame/components.dart';
import 'package:guess_number_game/game/components/guess_game_state.dart';
import 'package:guess_number_game/game/state/guess_number_state.dart';

enum GuessHintType { none, tooLow, tooHigh }

class GuessLogicComponent extends Component {
  final Random _random = Random();
  int? _target;
  late GuessStateComponent stateComponent;

  @override
  void onMount() {
    super.onMount();
    stateComponent = parent!.children.whereType<GuessStateComponent>().first;
  }

  void start(int min, int max) {
    _target = _random.nextInt(max - min + 1) + min;

    stateComponent.setState(
      GuessGameState(
        min: min,
        max: max,
        lower: min,
        upper: max,
        attemptsLeft: 4,
        status: GameStatus.playing,
        message: 'Game started! Use the Guess Range',
      ),
    );
  }

  void submitGuess(int guess) {
    final s = stateComponent.state;
    if (s.status != GameStatus.playing || _target == null) return;
    final attemptsLeft = s.attemptsLeft;

    final attempts = s.attemptsLeft - 1;

    if (guess == _target) {
      stateComponent.setState(s.copyWith(status: GameStatus.win, attemptsLeft: attempts, message: '🎉 Correct!'));
      return;
    }

    if (attempts <= 0) {
      stateComponent.setState(s.copyWith(status: GameStatus.lose, attemptsLeft: 0, message: '❌ Number was $_target'));
      return;
    }

    stateComponent.setState(
      s.copyWith(
        attemptsLeft: attempts,
        lower: guess < _target! ? max(s.lower, guess + 1) : s.lower,
        upper: guess > _target! ? min(s.upper, guess - 1) : s.upper,
        message: guess < _target! ? '⬆️ Too low • $attemptsLeft Tries left' : '⬇️ Too high • $attemptsLeft Tries left',
      ),
    );
  }
}
