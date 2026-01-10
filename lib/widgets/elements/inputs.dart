// Datei: widgets\elements\inputs.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../contents/fonts.dart';
import '../styles/edges.dart';
import '../styles/glow_element.dart';

final Map<String, dynamic> inputActive = {
  'font':                 'text',
  'fontSize':             15.0,
  'fontColor':            'contrast',
  'itemHover':            'primary',
  'borderColor':          'primary',
  'borderWidth':          1.0,
  'bgColor':              'base',
  'fontWeight':           FontWeight.bold,
  'opacity':              1.0,
  'vertPad':              10.0,
  'horiPad':              12.0,
  'phColor':              'placeholder',
  'phFontStyle':          FontStyle.italic,
  'phFontWeight':         FontWeight.bold,
  'phLetterSpacing':      1.8,
  'phFontSize':           14.0,
};


final Map<String, dynamic> inputDisabled = {
  ...inputActive,
  'opacity': 0.5,
};

OutlineInputBorder buildBorder(Map<String, dynamic> style, Map<String, Color> theme) {
  return OutlineInputBorder(
    borderRadius: appEdges(),
    borderSide: BorderSide(
      color: theme[style['borderColor']]!,
      width: style['borderWidth'],
    ),
  );
}

InputDecoration buildInputDecoration(
  Map<String, dynamic> style,
  bool isDark,
  String hint,
  bool isFocused,
  int lines,
) {
  final theme = isDark ? darkThemeMap : lightThemeMap;
  final border = OutlineInputBorder(
    borderRadius: appEdges(),
    borderSide: BorderSide(
      color: theme[style['borderColor']]!,
      width: style['borderWidth'],
    ),
  );
  final vertPad = style['vertPad'];
  return InputDecoration(
    isDense: true,
    alignLabelWithHint: true,
    filled: true,
    fillColor: theme[style['bgColor']],
    enabledBorder: border,
    focusedBorder: border,
    hintText: hint,
    hintStyle: textFont(style['phFontSize']).copyWith(
      color: theme[style['phColor']],
      fontStyle: style['phFontStyle'],
      fontWeight: style['phFontWeight'],
      letterSpacing: style['phLetterSpacing'],
    ),
    contentPadding: EdgeInsets.only(
      left: style['horiPad'],
      right: style['horiPad'],
      top: vertPad,
      bottom: vertPad,
    ),
  );
}

TextStyle buildInputTextStyle(Map<String, dynamic> style, bool isDark) {
  final theme = isDark ? darkThemeMap : lightThemeMap;
  return textFont(style['fontSize']).copyWith(
    color: theme[style['fontColor']],
    fontWeight: style['fontWeight'],
  );
}

Widget styledInputField({
  required BuildContext context,
  required Map<String, dynamic> style,
  required String hint,
  TextEditingController? controller,
  bool enabled = true,
  int lines = 1,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final opacity = style['opacity'];
  final focusNode = FocusNode();
  double fontSize = style['fontSize'];

  return StatefulBuilder(
    builder: (context, setState) {
      focusNode.addListener(() { setState(() {}); });
      final isFocused = focusNode.hasFocus;
      final theme = isDark ? darkThemeMap : lightThemeMap;

      final field = AnimatedContainer(
  duration: const Duration(milliseconds: 50),
  decoration: BoxDecoration(
    borderRadius: appEdges(),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        blurRadius: 22,
        spreadRadius: 2,
        offset: Offset(0, 0),
      ),
      ...buildGlow(
        isFocused: isFocused,
        color: theme[style['borderColor']]!,
      ), 
    ],
  ),
  child: TextField(
    enabled: enabled,
    controller: controller,
    focusNode: focusNode,
    maxLines: lines,
    minLines: lines,
    style: textFont(fontSize).copyWith(
      color: theme[style['fontColor']],
      fontWeight: style['fontWeight'],
    ),
    decoration: buildInputDecoration(style, isDark, hint, isFocused, lines),
  ),
);


      return Column(
        children: [
          opacity != inputActive["opacity"]
              ? Opacity(opacity: opacity, child: field)
              : field,
          SizedBox(height: 5),
        ],
      );
    },
  );
}