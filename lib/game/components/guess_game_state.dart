import 'package:flame/components.dart';
import 'package:guess_number_game/game/state/guess_number_state.dart';

class GuessStateComponent extends Component {
  GuessGameState state = const GuessGameState(min: 0, max: 0, lower: 0, upper: 0, attemptsLeft: 0, status: GameStatus.idle, message: '');

  void setState(GuessGameState newState) {
    state = newState;
  }
}
