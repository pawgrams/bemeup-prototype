// Datei: theme\light.dart
import 'package:flutter/material.dart';
import '../widgets/contents/colors.dart';

final Map<String, Color> lightThemeMap = {
    'base':         colors['light']!,
    'contrast':     colors['dark']!,
    'primary':      colors['turqoise']!,
    'secondary':    colors['yellow']!,
    'placeholder':  colors['placeholder']!,
    'dark':         colors['dark']!,
    'light':        colors['light']!,
    'yellow':       colors['yellow']!,
    'turqoise':     colors['turqoise']!,
};

final ThemeData lightTheme = ThemeData(

    brightness: Brightness.light,
    scaffoldBackgroundColor: lightThemeMap['base']!,
    appBarTheme: AppBarTheme(backgroundColor: lightThemeMap['base']!),

    textTheme: TextTheme(
        bodyMedium: TextStyle(color: lightThemeMap['contrast']!),
        titleLarge: TextStyle(color: lightThemeMap['contrast']!),
    ),

    iconTheme: IconThemeData(color: lightThemeMap['secondary']!),

);
