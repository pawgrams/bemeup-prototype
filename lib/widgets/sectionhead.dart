// Datei: widgets/sectionhead.dart
import 'package:flutter/material.dart';
import '../theme/dark.dart';
import '../theme/light.dart';
import '../widgets/contents/fonts.dart';

final Map<String, dynamic> widgetStyle = {
  'horizontalPadding': 24.0,
  'verticalPadding': 8.0,
  'betweenTextPadding': 8.0,
  'bgColor': 'base',
  'height': 50.0,
};

final Map<String, dynamic> line1Large = {
  'font': 'caption',
  'fontSize': 18.0,
  'fontStyle': FontStyle.normal,
  'fontColor': 'primary',
  'yOffset': 0,
  'fontWeight': FontWeight.w700,
};
final Map<String, dynamic> line1Small = {
  'font': 'text',
  'fontSize': 14.0,
  'fontStyle': FontStyle.normal,
  'fontColor': 'primary',
  'yOffset': 0,
  'fontWeight': FontWeight.w300,
};
final Map<String, dynamic> line1At = {
  'font': 'text',
  'fontSize': 12.0,
  'fontStyle': FontStyle.normal,
  'fontColor': 'primary',
  'yOffset': -2,
  'fontWeight': FontWeight.w800,
};
final Map<String, dynamic> line2Large = {
  'font': 'caption',
  'fontSize': 14.0,
  'fontStyle': FontStyle.normal,
  'fontColor': 'contrast',
  'yOffset': 0,
  'fontWeight': FontWeight.w700,
};
final Map<String, dynamic> line2Small = {
  'font': 'text',
  'fontSize': 12.0,
  'fontStyle': FontStyle.normal,
  'fontColor': 'contrast',
  'yOffset': -1,
  'fontWeight': FontWeight.w400,
};
final Map<String, dynamic> line2At = {
  'font': 'text',
  'fontSize': 11.0,
  'fontStyle': FontStyle.normal,
  'fontColor': 'contrast',
  'yOffset': -2,
  'fontWeight': FontWeight.w800,
};

Map<String, dynamic> _getStyleMap(String name) {
  switch (name) {
    case 'line1Large':  return line1Large;
    case 'line1Small':  return line1Small;
    case 'line1At':     return line1At;
    case 'line2Large':  return line2Large;
    case 'line2Small':  return line2Small;
    case 'line2At':     return line2At;
    default:            return line1Large;
  }
}

Color _getStyleColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

class SectionHead extends StatelessWidget {
  final List<String> line1Texts;
  final List<String> line1Styles;
  final List<String> line2Texts;
  final List<String> line2Styles;

  const SectionHead({
    super.key,
    required this.line1Texts,
    required this.line1Styles,
    required this.line2Texts,
    required this.line2Styles,
  });

  List<Widget> _buildLine(BuildContext context, List<String> texts, List<String> styleMaps) {
    return List.generate(texts.length, (i) {
      final styleName = styleMaps[i];
      final style = _getStyleMap(styleName);
      final fontFn = appFonts[style['font']] ?? textFont;
      final yOffset = (style['yOffset'] ?? 0).toDouble();
      final fontWeight = style['fontWeight'] ?? FontWeight.normal;
      final bool noRightPadding = texts[i] == '@';
      final bool isLast = i == texts.length - 1;
      final double rightPad = (!isLast && !noRightPadding) ? widgetStyle['betweenTextPadding'] : 0.0;

      return Padding(
        padding: EdgeInsets.only(right: rightPad),
        child: Transform.translate(
          offset: Offset(0, yOffset),
          child: Text(
            texts[i],
            style: fontFn(style['fontSize']).copyWith(
              fontStyle: style['fontStyle'],
              color: _getStyleColor(context, style['fontColor']),
              fontWeight: fontWeight,
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeMap = isDark ? darkThemeMap : lightThemeMap;
    final bgColor = themeMap[widgetStyle['bgColor']] ?? Colors.transparent;
    final double bgOpacity = isDark ? 0.4 : 0.6;

    return Container(
      height: widgetStyle['height'],
      color: bgColor.withOpacity(bgOpacity),
      padding: EdgeInsets.symmetric(
        horizontal: widgetStyle['horizontalPadding'],
        vertical: 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (line1Texts.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: _buildLine(context, line1Texts, line1Styles),
            ),
          if (line2Texts.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: _buildLine(context, line2Texts, line2Styles),
            ),
        ],
      ),
    );
  }
}
