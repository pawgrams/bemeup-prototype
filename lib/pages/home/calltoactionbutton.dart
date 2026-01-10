// Datei: pages/home/calltoactionbutton.dart
import 'package:flutter/material.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';

final Map<String, dynamic> ctaStyle = {
  'followButtonFontSize': 9.0,
  'followButtonHeight': 16.0,
  'followButtonPaddingH': 10.0,
  'followButtonPaddingV': 0.0,
  'followButtonRadius': 16.0,
  'followButtonGap': 0.0,
  'followButtonAlignY': 0.0,
  'followButtonBoxShadowColor': Colors.black,
  'followButtonBoxShadowBlur': 14.0,
  'followButtonBoxShadowSpread': 4.0,
  'followButtonBoxShadowOffsetX': 0.0,
  'followButtonBoxShadowOffsetY': 0.0,
};

Color ctaColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black.withOpacity(0.5);
  if (key == "grey") return Colors.white.withOpacity(0.5);
  return Colors.black.withOpacity(0.5);
}

class CTAButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final Color? bgColor;
  final Color? textColor;
  const CTAButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.bgColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ctaStyle['followButtonHeight'],
      child: Transform.translate(
        offset: const Offset(0, -1),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: ctaStyle['followButtonPaddingH'],
              vertical: ctaStyle['followButtonPaddingV'],
            ),
            minimumSize: Size(0, ctaStyle['followButtonHeight']),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: bgColor ?? ctaColor(context, 'primary').withOpacity(0.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(ctaStyle['followButtonRadius']),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            label,
            style: TextStyle(
              fontSize: ctaStyle['followButtonFontSize'],
              color: textColor ?? ctaColor(context, 'primary'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
