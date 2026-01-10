// Datei: widgets\styles\shadow_element.dart
import 'package:flutter/material.dart';

class ShadowElement extends StatelessWidget {
  final Widget child;
  final double blur;
  final double spread;
  final double opacity;

  const ShadowElement({
    super.key,
    required this.child,
    this.blur = 18,
    this.spread = 0,
    this.opacity = 0.9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(opacity),
            blurRadius: blur,
            spreadRadius: spread,
            offset: Offset(0, 0),
          ),
        ],
      ),
      child: child,
    );
  }
}
