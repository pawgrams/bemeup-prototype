// Datei: pages\create\createFormController.dart
import 'package:flutter/material.dart';

class CreateFormController {
  static final genreController = ValueNotifier<String?>(null);
  static final styleController = TextEditingController();
  static final voiceController = ValueNotifier<String?>(null);
  static final langController = ValueNotifier<String?>(null);
  static final lyricsController = TextEditingController();

  static void reset() {
    genreController.value = null;
    styleController.clear();
    voiceController.value = null;
    langController.value = null;
    lyricsController.clear();
  }
}
