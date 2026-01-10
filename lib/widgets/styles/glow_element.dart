// Datei: widgets\styles\glow_element.dart
import 'package:flutter/material.dart';

List<BoxShadow> buildGlow({
  required bool isFocused,
  required Color color,
  double blurRadius = 10,
  double spreadRadius = 2,
}) {
  return [
    BoxShadow(
      color: isFocused ? color.withOpacity(0.45) : Colors.transparent,
      blurRadius: blurRadius,
      spreadRadius: spreadRadius,
    ),
  ];
}
