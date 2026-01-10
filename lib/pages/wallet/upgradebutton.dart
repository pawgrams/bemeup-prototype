// Datei: pages/wallet/upgradebutton.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';

final Map<String, dynamic> panelStyle = {
  'upgradeButtonFontSize': 12.0,
  'upgradeButtonHeight': 24.0,
  'upgradeButtonPaddingH': 16.0,
  'upgradeButtonPaddingV': 2.0,
  'upgradeButtonRadius': 16.0,
  'upgradeButtonGap': 6.0,
  'upgradeButtonAlignY': 0.0,
  'upgradeButtonBoxShadowColor': Colors.black,
  'upgradeButtonBoxShadowBlur': 14.0,
  'upgradeButtonBoxShadowSpread': 4.0,
  'upgradeButtonBoxShadowOffsetX': 0.0,
  'upgradeButtonBoxShadowOffsetY': 0.0,
};

Color _c(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black;
  if (key == "grey") return Colors.grey;
  return Colors.blue;
}

class UpgradeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const UpgradeButton({
    super.key,
    required this.onPressed,
    this.label = '🐱 Upgrade',
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = _c(context, 'primary');
    return SizedBox(
      height: (panelStyle['upgradeButtonHeight'] as num).toDouble(),
      child: Transform.translate(
        offset: const Offset(0, 0.2),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: (panelStyle['upgradeButtonPaddingH'] as num).toDouble(),
              vertical: (panelStyle['upgradeButtonPaddingV'] as num).toDouble(),
            ),
            minimumSize: Size(
              0,
              (panelStyle['upgradeButtonHeight'] as num).toDouble(),
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: primaryColor.withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                (panelStyle['upgradeButtonRadius'] as num).toDouble(),
              ),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: (panelStyle['upgradeButtonFontSize'] as num).toDouble(),
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
