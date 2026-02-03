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

  List<HintItem> hints = [];
  String message = '';

  void generateHintsHardcore() {
    final target = widget.game.debugTarget;
    if (target == null) return;
    final minValue = int.parse(_minController.text);
    final maxValue = int.parse(_maxController.text);

    final rand = Random();
    final List<HintItem> result = [];

    final rangeSize = maxValue - minValue + 1;

    int clamp(int v) => v.clamp(minValue, maxValue);
    if (rangeSize >= 7) {
      for (int i = 0; i < 2; i++) {
        final delta = rand.nextInt(3) + 3;
        final v = clamp(target + (rand.nextBool() ? delta : -delta));
        if (v != target && !result.any((e) => e.value == v)) {
          result.add(HintItem(v, '🔥'));
        }
      }
    }
    if (rangeSize >= 20) {
      for (int i = 0; i < 2; i++) {
        final delta = rand.nextInt(20) + 15;
        final v = clamp(target + (rand.nextBool() ? delta : -delta));
        if (v != target && !result.any((e) => e.value == v)) {
          result.add(HintItem(v, '❄️'));
        }
      }
    }

    final maxHints = max(1, min(4, rangeSize - 1));
    final candidates = List<int>.generate(rangeSize, (i) => minValue + i)
      ..shuffle();

    for (final v in candidates) {
      if (result.length >= maxHints) break;
      if (!result.any((e) => e.value == v)) {
        result.add(HintItem(v, '❓'));
      }
    }
    result.shuffle();
    hints = result;
  }

  void startGame() {
    final min = int.tryParse(_minController.text);
    final max = int.tryParse(_maxController.text);

    if (min == null || max == null || min >= max) {
      setState(() => message = 'Invalid min/max');
      return;
    }

    widget.game.startGame(min: min, max: max);

    generateHintsHardcore();

    setState(() => message = 'Game started! Use the Guess Range');
  }

  void submitGuess() {
    final guess = int.tryParse(_guessController.text);
    if (guess == null) return;

    final result = widget.game.checkGuess(guess);

    // final isWin = result.contains('You win'); // Unused

    if (widget.game.isGameOver) {
      setState(() => _showLoseFlash = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _showLoseFlash = false);
      });
    }
    setState(() => message = result);
    if (widget.game.isGameOver) {
      _guessController.clear();
      Future.delayed(const Duration(milliseconds: 400), () {
        final adController = Get.find<AdController>();
        adController.showInterstitial(
          onClosed: () {
            widget.game.overlays.add('GuessInput');
          },
        );
      });
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: _showLoseFlash
                        ? Colors.red.withValues(alpha: 0.15)
                        : Colors.transparent,
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
                          borderRadius: BorderRadius.circular(16),
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

  @override
  void dispose() {
    super.dispose();
    _minController.dispose();
    _maxController.dispose();
    _guessController.dispose();
  }
}
