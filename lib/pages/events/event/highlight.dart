import 'package:flutter/material.dart';
import '../../../widgets/styles/glow_coverart.dart';

class HighlightEffect extends StatelessWidget {
  final Widget child;
  final int timestamp;
  final Color glowColor;

  const HighlightEffect({
    super.key,
    required this.child,
    required this.timestamp,
    required this.glowColor,
  });

  bool get isHighlighted => timestamp > DateTime.now().millisecondsSinceEpoch;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: buildGlow(
          isFocused: isHighlighted,
          color: glowColor,
        ),
      ),
      child: child,
    );
  }
}

Widget highlightContainer({
  required Widget child,
  required int timestamp,
  required Color glowColor,
}) {
  final isHighlighted = timestamp > DateTime.now().millisecondsSinceEpoch;

  return Container(
    foregroundDecoration: isHighlighted
        ? BoxDecoration(
            border: Border.all(
              color: glowColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: glowColor.withOpacity(0.9),
                blurRadius: 18,
                spreadRadius: 4,
              ),
            ],
          )
        : null,
    child: child,
  );
}
