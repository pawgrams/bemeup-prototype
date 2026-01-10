// Datei: widgets\styles\glow_coverart.dart
import 'package:flutter/material.dart';

List<BoxShadow> buildGlow({
  required bool isFocused,
  required Color color,
  double blurRadius = 5,
  double spreadRadius = 2,
}) {
  return [
    BoxShadow(
      color: isFocused ? color.withOpacity(0.85) : Colors.transparent,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    ),
  ];
}
