// Datei: widgets\elements\fallbackground.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FallbackBackground extends StatelessWidget {
  const FallbackBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? '#000000' : '#FFFFFF';

    final svgString = '''
    <svg width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
      <rect width="100%" height="100%" fill="$color"/>
    </svg>
    ''';

    return SvgPicture.string(
      svgString,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
