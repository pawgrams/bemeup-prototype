// Datei: widgets/elements/fieldtitles.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../contents/fonts.dart';
import '../elements/tooltip.dart';
import '../../translations/translations.dart';
import '../styles/shadow_text.dart';

final Map<String, dynamic> fieldTitleStyle = {
  'font': 'text',
  'fontSize': 14.0,
  'fontColor': 'primary',
  'fontWeight': FontWeight.bold,
  'letterSpacing': 1.8,
  'spaceBelow': 8,
};

TextStyle buildFieldTitleTextStyle(Map<String, dynamic> style, bool isDark) {
  final theme = isDark ? darkThemeMap : lightThemeMap;
  final fontFn = appFonts[style['font']] ?? textFont;
  return fontFn(style['fontSize']).copyWith(
    color: theme[style['fontColor']],
    fontWeight: style['fontWeight'],
    letterSpacing: style['letterSpacing'],
  );
}

Widget styledFieldTitleWithTooltip({
  required BuildContext context,
  required String textKey,
  String tooltipCategory = '',
  String tooltipKey = '',
  Map<String, dynamic>? style,
  double? spaceBelow,
  bool useTextShadow = true,
}) {
  final locale = Localizations.localeOf(context).languageCode;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final styleMap = style ?? fieldTitleStyle;
  final _spaceBelow = spaceBelow ?? fieldTitleStyle['spaceBelow'];
  final bool showTooltip = tooltipCategory.isNotEmpty && tooltipKey.isNotEmpty;

  final textWidget = useTextShadow
      ? ShadowText(
          text: tr(textKey, locale),
          fontSize: styleMap['fontSize'],
          color: (isDark ? darkThemeMap : lightThemeMap)[styleMap['fontColor']]!,
          fontWeight: styleMap['fontWeight'],
          letterSpacing: styleMap['letterSpacing'],
        )
      : Text(
          tr(textKey, locale),
          style: buildFieldTitleTextStyle(styleMap, isDark),
        );

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          textWidget,
          if (showTooltip)
            infoTooltip(
              context: context,
              text: tr('tt_$tooltipKey', locale),
            ),
        ],
      ),
      SizedBox(height: _spaceBelow),
    ],
  );
}
