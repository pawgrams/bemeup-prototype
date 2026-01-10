// Datei: utils\transoff.dart
import 'package:flutter/material.dart';

Widget TransOffWrapper({required String type, required Widget child}) {
  switch (type) {
    case 'route': return child;
    case 'dialog': return child;
    case 'expansion': return child;
    case 'tab': return child;
    default: return child;
  }
}
