// Datei: widgets/elements/sectioncaption.dart
import 'package:flutter/material.dart';
import '../../translations/translations.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import 'tooltip.dart';

final Map<String, dynamic> captionStyle = {
  'fontSize': 10.0,
  'letterSpacing': 1.5,
  'fontWeight': FontWeight.w300,
  'paddingH': 0.0,
  'paddingV': 3.0,
  'bgColor': 'dark',
  'bgOpacity': 0.3,
  'fontColor': 'light',
  'fontOpacity': 0.7,
  'tooltipYOffset': 0.8,
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[captionStyle[key]]!;
}

class SectionCaption extends StatelessWidget {
  final String translationKey;
  final int? amount;
  final bool showTooltip;

  const SectionCaption({
    super.key,
    required this.translationKey,
    this.amount,
    this.showTooltip = true,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final bg = panelColor(context, 'bgColor').withOpacity(captionStyle['bgOpacity']);
    final fontColor = panelColor(context, 'fontColor').withOpacity(captionStyle['fontOpacity']);
    final double tooltipYOffset = captionStyle['tooltipYOffset'];
    final String text = tr(translationKey, locale).toUpperCase();
    final String combined = amount != null ? "$amount $text" : text;

    return Container(
      width: double.infinity,
      color: bg,
      padding: EdgeInsets.symmetric(
        horizontal: captionStyle['paddingH'],
        vertical: captionStyle['paddingV'],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            combined,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: captionStyle['fontSize'],
              letterSpacing: captionStyle['letterSpacing'],
              fontWeight: captionStyle['fontWeight'],
              color: fontColor,
            ),
          ),
          if (showTooltip)
            Transform.translate(
              offset: Offset(0, tooltipYOffset),
              child: infoTooltip(
                context: context,
                text: tr('tt_$translationKey', locale),
                size: 10,
                spacing: 4,
              ),
            ),
        ],
      ),
    );
  }
}
