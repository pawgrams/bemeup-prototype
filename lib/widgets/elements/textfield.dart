// Datei: widgets/elements/textfield.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../contents/fonts.dart';

final Map<String, dynamic> textFieldStyle = {
  'font': 'text',
  'fontSize': 15.0,
  'fontColor': 'contrast',
  'fontWeight': FontWeight.bold,
  'opacity': 1.0,
  'dividerColor': 'divider',
  'dividerThickness': 1.0,
  'dividerHeight': 16.0,
};

TextStyle buildTextFieldStyle(bool isDark) {
  final theme = isDark ? darkThemeMap : lightThemeMap;
  final fontFn = appFonts[textFieldStyle['font']] ?? textFont;
  return fontFn(textFieldStyle['fontSize']).copyWith(
    color: theme[textFieldStyle['fontColor']],
    fontWeight: textFieldStyle['fontWeight'],
  );
}

Widget styledTextField({
  required BuildContext context,
  required String text,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textStyle = buildTextFieldStyle(isDark);
  final opacity = textFieldStyle['opacity'];
  final theme = isDark ? darkThemeMap : lightThemeMap;

  final child = Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Opacity(
        opacity: opacity,
        child: Text(text, style: textStyle),
      ),
      SizedBox(height: 4),
      Divider(
        color: theme[textFieldStyle['dividerColor']],
        thickness: textFieldStyle['dividerThickness'],
        height: textFieldStyle['dividerHeight'],
      ),
    ],
  );

  return child;
}
