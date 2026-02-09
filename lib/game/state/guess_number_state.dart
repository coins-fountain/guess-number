enum GameStatus { idle, playing, win, lose }

class GuessGameState {
  final int min;
  final int max;
  final int attemptsLeft;
  final int lower;
  final int upper;
  final GameStatus status;
  final String message;

  const GuessGameState({
    required this.min,
    required this.max,
    required this.attemptsLeft,
    required this.lower,
    required this.upper,
    required this.status,
    required this.message,
  });

  GuessGameState copyWith({int? attemptsLeft, int? lower, int? upper, GameStatus? status, String? message}) {
    return GuessGameState(
      min: min,
      max: max,
      attemptsLeft: attemptsLeft ?? this.attemptsLeft,
      lower: lower ?? this.lower,
      upper: upper ?? this.upper,
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }
}
