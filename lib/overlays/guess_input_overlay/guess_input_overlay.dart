import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_number_game/controller/ads_controller.dart';
import 'package:guess_number_game/model/hint_item_model.dart';
import 'package:guess_number_game/overlays/decision_range_bar_overlay.dart';
import 'package:guess_number_game/overlays/guess_input_overlay/widget/game_button_widget.dart';
import 'package:guess_number_game/overlays/guess_input_overlay/widget/number_field_widget.dart';
import '../../component/animated_eye_component.dart';
import '../../go_grey.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class GuessInputOverlay extends StatefulWidget {
  const GuessInputOverlay({super.key, required this.game});

  final GoGrey game;

  @override
  State<GuessInputOverlay> createState() => _GuessInputOverlayState();
}

class _GuessInputOverlayState extends State<GuessInputOverlay> {
  final _minController = TextEditingController(text: '0');
  final _maxController = TextEditingController(text: '100');
  final _guessController = TextEditingController();
  final AdController adController = Get.find<AdController>();

  bool _showLoseFlash = false;
  bool _showWinFlash = false;

  List<HintItem> hints = [];
  String message = '';



  void startGame() {
    final min = int.tryParse(_minController.text);
    final max = int.tryParse(_maxController.text);

    if (min == null || max == null || min >= max) {
      setState(() => message = 'Invalid min/max');
      return;
    }

    widget.game.startGame(min: min, max: max);

    setState(() => message = 'Game started! Use the Guess Range');
  }
  void submitGuess() {
    final guess = int.tryParse(_guessController.text);
    if (guess == null) return;
    final result = widget.game.checkGuess(guess);
    final target = widget.game.debugTarget;
    if (target == null) return;
    setState(() {
      message = result;
    });
    if (widget.game.isGameOver) {
      bool isWin = result.contains('win');
      if (isWin) {
        _triggerFlash(isVictory: true);
      } else {
        _triggerFlash(isVictory: false);
      }
      Future.delayed(const Duration(milliseconds: 400), () {
        _showGameDialog(
          title: isWin ? "VICTORY!" : "GAME OVER",
          subTitle: result,
          icon: isWin ? Icons.emoji_events_rounded : Icons.sentiment_very_dissatisfied,
          color: isWin ? Colors.green : Colors.redAccent,
          onDismiss: () {
            _guessController.clear();
            adController.showInterstitial(
              onClosed: () => widget.game.overlays.add('GuessInput'),
            );
          },
        );
      });
    } else {
      bool isTooLow = guess < target;
      _showGameDialog(
        onDismiss: () => _guessController.clear(),
        title: isTooLow ? "TOO LOW!" : "TOO HIGH!",
        subTitle: "You have ${widget.game.attemptsLeft} attempts left",
        icon: isTooLow ? Icons.arrow_circle_up_rounded : Icons.arrow_circle_down_rounded,
        color: isTooLow ? Colors.orange : Colors.blueAccent,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final started = widget.game.isGameStarted;
    final adController = Get.find<AdController>();

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        color: _showWinFlash
                            ? Colors.green.withOpacity(0.4) // Stronger green for win
                            : _showLoseFlash
                            ? Colors.red.withOpacity(0.4) // Stronger red for lose
                            : Colors.transparent,
                      ),
                    ),
                  ),
                  AnimatedPadding(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Center(
                      child: Container(
                        width: min(320, screenWidth - 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24), // Rounder corners
                          border: Border.all(color: kGameBorderColor, width: kGameBorderWidth),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              offset: Offset(8, 8), // Deep shadow for depth
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              NumberFieldWidget(
                                c: _minController,
                                title: 'Minimum',
                                enabled: !started,
                              ),
                              const SizedBox(height: 12),
                              NumberFieldWidget(
                                c: _maxController,
                                title: 'Maximum',
                                enabled: !started,
                              ),
                    
                              if (started &&
                                  widget.game.currentLower != null &&
                                  widget.game.currentUpper != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: DecisionRangeBar(
                                    min: int.parse(_minController.text),
                                    max: int.parse(_maxController.text),
                                    lower: widget.game.currentLower!,
                                    upper: widget.game.currentUpper!,
                                  ),
                                ),
                    
                              NumberFieldWidget(
                                c: _guessController,
                                title: 'Your guess',
                                enabled: started,
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    transitionBuilder: (child, anim) {
                                      final offset = Tween(
                                        begin: const Offset(0.1, 0),
                                        end: Offset.zero,
                                      ).animate(anim);
                                      return SlideTransition(
                                        position: offset,
                                        child: child,
                                      );
                                    },
                                    child: Text(message, key: ValueKey(message)),
                                  ),
                                  if (message.contains('Guess Range'))
                                    const Padding(
                                      padding: EdgeInsets.only(left: 6),
                                      child: AnimatedEyes(),
                                    ),
                                ],
                              ),
                    
                              const SizedBox(height: 16),
                              GameButtonWidget(
                                text: started ? 'GUESS 🎯' : 'START GAME 🚀',
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  started ? submitGuess() : startGame();
                                },
                                color: started
                                    ? const Color(0xFF4CAF50)
                                    : const Color(0xFF6C63FF),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Obx(() {
              if (adController.isBannerAdLoaded.value &&
                  adController.bannerAd != null) {
                return Container(
                  alignment: Alignment.center,
                  width: adController.bannerAd!.size.width.toDouble(),
                  height: adController.bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: adController.bannerAd!),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  void _triggerFlash({required bool isVictory}) {
    void setFlash(bool val) {
      if (mounted) {
        setState(() {
          if (isVictory) _showWinFlash = val;
          else _showLoseFlash = val;
        });
      }
    }
    setFlash(true);
    Future.delayed(const Duration(milliseconds: 100), () => setFlash(false));
    Future.delayed(const Duration(milliseconds: 200), () => setFlash(true));
    Future.delayed(const Duration(milliseconds: 300), () => setFlash(false));
  }

  void _showGameDialog({
    required String title,
    required String subTitle,
    required IconData icon,
    required Color color,
    VoidCallback? onDismiss,
  }) {
    showGeneralDialog(
      context: context,
      barrierDismissible: false, // Force them to engage with the UI
      barrierLabel: "GameResult",
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Center(
        child: Material(
          color: Colors.transparent,
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFF2C2C2C), width: 5),
                boxShadow: const [
                  BoxShadow(color: Colors.black38, offset: Offset(0, 10), blurRadius: 0),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 80, color: color),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  GameButtonWidget(
                    text: "CONTINUE",
                    onTap: () {
                      Navigator.pop(context);
                      if (onDismiss != null) onDismiss();
                    },
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _minController.dispose();
    _maxController.dispose();
    _guessController.dispose();
  }
}
