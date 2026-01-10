// Datei: widgets\contents\fonts.dart
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';

TextStyle captionFont(double size) => GoogleFonts.orbitron(fontSize: size);
TextStyle textFont(double size)    => GoogleFonts.roboto(fontSize: size);

final Map<String, TextStyle Function(double)> appFonts = {
    'caption': captionFont,
    'text':    textFont,
};
