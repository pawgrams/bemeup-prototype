// Datei: widgets/elements/accordion.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../styles/shadow_text.dart';
import '../contents/fonts.dart';
import '../../translations/translations.dart';

final Map<String, dynamic> accordionStyle = {
  'titleFont': 'text',
  'titleFontSize': 14.0,
  'titleFontWeight': FontWeight.bold,
  'titleLetterSpacing': 1.5,
  'titleColor': 'contrast',
  'borderOpacity': 0.3,
  'tilePadH': 24.0,
  'tilePadV': 12.0,
  'childrenPadH': 24.0,
  'childrenPadV': 8.0,
  'mapKeyFontWeight': FontWeight.bold,
  'mapKeyColor': 'primary',
  'mapSpacing': 6.0,
  'sectionSpacing': 8.0,
  'dividerHeight': 1.0,
  'dividerThickness': 1.0,
  'dividerColor': 'divider',
  'animationDurationMs': 250,
  'iconSize': 20.0,
  'keyWidth': 120.0,
};

Color accordionColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[accordionStyle[key]]!;
}

class AccordionSection {
  final String title;
  final dynamic content;

  AccordionSection({required this.title, required this.content});
}

class Accordion extends StatefulWidget {
  final List<AccordionSection> sections;
  final bool useTextShadow;

  const Accordion({
    super.key,
    required this.sections,
    this.useTextShadow = true,
  });

  @override
  State<Accordion> createState() => _AccordionState();
}

class _AccordionState extends State<Accordion> {
  int? _expandedIndex;

  TextStyle _resolvedTitleStyle(BuildContext context) {
    final fontFn = appFonts[accordionStyle['titleFont']] ?? textFont;
    return fontFn(accordionStyle['titleFontSize']).copyWith(
      color: accordionColor(context, 'titleColor'),
      fontWeight: accordionStyle['titleFontWeight'],
      letterSpacing: accordionStyle['titleLetterSpacing'],
    );
  }

Widget _buildContent(dynamic data) {
  if (data == null) return const SizedBox.shrink();

  if (data is String || data is num || data is bool) {
    return Text(data.toString());
  }

  if (data is List) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.map<Widget>((e) => _buildContent(e)).toList(),
    );
  }

  if (data is Map) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: data.entries.map<Widget>((e) {
        final locale = Localizations.localeOf(context).languageCode;
        final rawKey = e.key.toString();
        final translatedKey = tr(rawKey.contains('.') ? rawKey.split('.').last : rawKey, locale);
        final keyLabel = rawKey.contains('.') ? '' : translatedKey;
        return Padding(
          padding: EdgeInsets.only(bottom: accordionStyle['mapSpacing']),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: accordionStyle['keyWidth'],
                child: Text(
                  "$keyLabel",
                  style: TextStyle(
                    fontWeight: accordionStyle['mapKeyFontWeight'],
                    color: accordionColor(context, 'mapKeyColor'),
                  ),
                ),
              ),
              Expanded(child: _buildContent(e.value)),
            ],
          ),
        );
      }).toList(),
    );
  }

  return Text(data.toString());
}


  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerColor.withOpacity(accordionStyle['borderOpacity']);
    final titleStyle = _resolvedTitleStyle(context);
    final iconColor = titleStyle.color ?? Colors.black;

    return Column(
      children: widget.sections.asMap().entries.map((entry) {
        final index = entry.key;
        final section = entry.value;
        final isExpanded = _expandedIndex == index;

        return Column(
          children: [
            if (index > 0)
              Divider(
                color: borderColor,
                height: accordionStyle['dividerHeight'],
                thickness: accordionStyle['dividerThickness'],
              ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!mounted) return;
                  setState(() {
                    _expandedIndex = isExpanded ? null : index;
                  });
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: accordionStyle['tilePadH'],
                    vertical: accordionStyle['tilePadV'],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: widget.useTextShadow
                            ? ShadowText(
                                text: section.title,
                                fontSize: titleStyle.fontSize ?? accordionStyle['titleFontSize'],
                                color: iconColor,
                                fontWeight: titleStyle.fontWeight,
                                letterSpacing: titleStyle.letterSpacing,
                              )
                            : Text(
                                section.title,
                                style: titleStyle,
                              ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: iconColor,
                        size: accordionStyle['iconSize'],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: accordionStyle['childrenPadH'],
                  vertical: accordionStyle['childrenPadV'],
                ),
                child: Column(
                  children: [
                    SizedBox(height: accordionStyle['sectionSpacing']),
                    _buildContent(section.content),
                  ],
                ),
              ),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: Duration(milliseconds: accordionStyle['animationDurationMs']),
              firstCurve: Curves.easeOut,
              secondCurve: Curves.easeIn,
            ),
          ],
        );
      }).toList(),
    );
  }
}
