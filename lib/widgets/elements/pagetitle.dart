// Datei: widgets\elements\pagetitle.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../contents/fonts.dart';
import 'tooltip.dart';

final Map<String, dynamic> pageTitleStyle = {
  'fontColor':    'contrast',
  'font':         'caption',
  'fontSize':     20.0,
  'fontWeight':   FontWeight.bold,
  'letterSpacing': 1.2,
};

TextStyle buildPageTitleTextStyle(Map<String, dynamic> style, bool isDark) {
  final fontFn = appFonts[style['font']] ?? textFont;
  final theme = isDark ? darkThemeMap : lightThemeMap;

  return fontFn(style['fontSize']).copyWith(
    color: theme[style['fontColor']],
    fontWeight: style['fontWeight'],
    letterSpacing: style['letterSpacing'],
  );
}

Widget pageTitleWithTooltip({
  required BuildContext context,
  required String text,
  required String tooltip,
  VoidCallback? onBack,
  Map<String, dynamic>? style,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final styleMap = style ?? pageTitleStyle;

  return Row(
    children: [
      GestureDetector(
        onTap: onBack,
        child: Text(
          text,
          style: buildPageTitleTextStyle(styleMap, isDark),
        ),
      ),
      infoTooltip(context: context, text: tooltip),
    ],
  );
}
