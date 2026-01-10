// Datei: theme\controller.dart
import 'package:flutter/material.dart';

class ThemeController extends ValueNotifier<ThemeMode> {
    ThemeController() : super(ThemeMode.dark);
    void toggle() {
        //value = value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
        value = ThemeMode.dark; // Prototype only dark mode
    }
}

final themeController = ThemeController();
