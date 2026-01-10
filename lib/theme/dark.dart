// Datei: theme\dark.dart
import 'package:flutter/material.dart';
import '../widgets/contents/colors.dart';

final Map<String, Color> darkThemeMap = {
    'base':         colors['dark']!,
    'contrast':     colors['light']!,
    'primary':      colors['yellow']!,
    'secondary':    colors['turqoise']!,
    'placeholder':  colors['placeholder']!,
    'dark':         colors['dark']!,
    'light':        colors['light']!,
    'yellow':       colors['yellow']!,
    'turqoise':     colors['turqoise']!,
};

final ThemeData darkTheme = ThemeData(

    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkThemeMap['base']!,
    appBarTheme: AppBarTheme(backgroundColor: darkThemeMap['base']!),

    textTheme: TextTheme(
        bodyMedium: TextStyle(color: darkThemeMap['contrast']!),
        titleLarge: TextStyle(color: darkThemeMap['contrast']!),
    ),

    iconTheme: IconThemeData(color: darkThemeMap['secondary']!),

);
