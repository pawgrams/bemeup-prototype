// Datei: context\timezone.dart
import 'package:flutter/material.dart';

class TimezoneProvider extends ChangeNotifier {
  String? _timezone;
  String? get timezone => _timezone;

  void setTimezone(String tz) {
    _timezone = tz;
    notifyListeners();
  }
}
