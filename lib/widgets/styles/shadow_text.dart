// Datei: widgets\styles\shadow_text.dart
import 'package:flutter/material.dart';

class ShadowText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight? fontWeight;
  final TextAlign? textAlign;
  final int? maxLines;
  final double? letterSpacing;

  const ShadowText({
    super.key,
    required this.text,
    this.fontSize = 18,
    this.color = Colors.white,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {

    final double blur = fontSize * 0.4;

    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: fontWeight,
        letterSpacing: letterSpacing,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(1),
            offset: Offset(0, 0),
            blurRadius: blur,
          ),
          Shadow(
            color: Colors.black.withOpacity(0.8),
            offset: Offset(0, 0),
            blurRadius: blur,
          ),
          Shadow(
            color: Colors.black.withOpacity(0.6),
            offset: Offset(0, 0),
            blurRadius: blur,
          ),

        ],
      ),
    );
  }
}
