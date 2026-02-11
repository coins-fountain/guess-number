import 'package:flutter/material.dart';

const kGameBorderWidth = 4.0;
const kGameBorderColor = Color(0xFF2C2C2C);
const kGameShadowColor = Color(0x33000000);

class NumberFieldWidget extends StatelessWidget {
  final TextEditingController c;
  final String title;
  final bool enabled;

  const NumberFieldWidget({
    super.key,
    required this.c,
    required this.enabled,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 4),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: kGameBorderColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kGameBorderColor, width: kGameBorderWidth),
            boxShadow: const [
              BoxShadow(color: kGameShadowColor, offset: Offset(0, 4), blurRadius: 0),
            ],
          ),
          child: TextField(
            controller: c,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center, // Numbers look better centered in games
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              letterSpacing: 0.5,
            ),
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              border: InputBorder.none, // Remove standard border
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
