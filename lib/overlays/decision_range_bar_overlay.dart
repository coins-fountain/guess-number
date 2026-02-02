import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DecisionRangeBar extends StatefulWidget {
  final int min;
  final int max;
  final int lower;
  final int upper;

  const DecisionRangeBar({
    super.key,
    required this.min,
    required this.max,
    required this.lower,
    required this.upper,
  });

  @override
  State<DecisionRangeBar> createState() => _DecisionRangeBarState();
}

class _DecisionRangeBarState extends State<DecisionRangeBar> {
  int? _lastLower;
  int? _lastUpper;

  double _n(int v) => (v - widget.min) / (widget.max - widget.min);

  @override
  void didUpdateWidget(covariant DecisionRangeBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lower != _lastLower || widget.upper != _lastUpper) {
      HapticFeedback.selectionClick();
      _lastLower = widget.lower;
      _lastUpper = widget.upper;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '🎯 Guess Range',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final left = width * _n(widget.lower);
            final barWidth = width * (_n(widget.upper) - _n(widget.lower));

            return Stack(
              children: [
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  left: left,
                  width: barWidth.clamp(6, width),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    height: 14,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF42A5F5),
                          Color(0xFF7E57C2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.35),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          '${widget.lower}  ←  Guess here  →  ${widget.upper}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }
}
