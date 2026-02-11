import 'dart:math';
import 'package:flame/components.dart';
import 'package:guess_number_game/game/components/guess_game_state.dart';
import 'package:guess_number_game/game/state/guess_number_state.dart';

enum GuessHintType { none, tooLow, tooHigh }

class GuessLogicComponent extends Component {
  final Random _random = Random();
  int? _target;
  late GuessStateComponent stateComponent;

  int _maxAttempts = 4;

  int _gamesPlayed = 0;
  bool _shouldShowAdThisRound = false;

  bool get shouldShowAd => _shouldShowAdThisRound;


  @override
  void onMount() {
    super.onMount();
    stateComponent =
        parent!.children.whereType<GuessStateComponent>().first;
  }

  int _calculateMaxAttempts(int min, int max) {
    final rangeSize = max - min + 1;
    return rangeSize.bitLength;
  }

  void _evaluateAdDisplay() {
    _gamesPlayed++;
    if (_gamesPlayed == 1) {
      _shouldShowAdThisRound = false;
      return;
    }

    final randomChance = _random.nextDouble();

    if (randomChance < 0.2) {
      _shouldShowAdThisRound = true;
    } else {
      _shouldShowAdThisRound = false;
    }
  }


  void start(int min, int max) {
    _target = _random.nextInt(max - min + 1) + min;
    _maxAttempts = _calculateMaxAttempts(min, max);
    stateComponent.setState(
      GuessGameState(
        min: min,
        max: max,
        lower: min,
        upper: max,
        attemptsLeft: _maxAttempts,
        status: GameStatus.playing,
        message:
        'Game started! Range: $min–$max • $_maxAttempts Tries',
      ),
    );
  }


  void submitGuess(int guess) {
    final s = stateComponent.state;
    if (s.status != GameStatus.playing || _target == null) return;

    final updatedAttempts = s.attemptsLeft - 1;

    //  WIN
    if (guess == _target) {
      _evaluateAdDisplay();

      stateComponent.setState(
        s.copyWith(
          status: GameStatus.win,
          attemptsLeft: updatedAttempts,
          message:
          '🎉 Correct! • ${updatedAttempts.clamp(0, _maxAttempts)} Tries left',
        ),
      );
      return;
    }

    // LOSE
    if (updatedAttempts <= 0) {
      _evaluateAdDisplay();
      stateComponent.setState(
        s.copyWith(
          status: GameStatus.lose,
          attemptsLeft: 0,
          message: '❌ Number was $_target',
        ),
      );
      return;
    }

    final isTooLow = guess < _target!;

    stateComponent.setState(
      s.copyWith(
        attemptsLeft: updatedAttempts,
        lower: isTooLow ? max(s.lower, guess + 1) : s.lower,
        upper: !isTooLow ? min(s.upper, guess - 1) : s.upper,
        message: isTooLow
            ? '⬆️ Too low • $updatedAttempts Tries left'
            : '⬇️ Too high • $updatedAttempts Tries left',
      ),
    );
  }
}

