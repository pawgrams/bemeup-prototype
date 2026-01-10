// Datei: pages/user/profile/followbutton.dart
import 'package:flutter/material.dart';
import 'buttonstyle.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black;
  if (key == "grey") return Colors.grey;
  return Colors.blue;
}

class FollowButton extends StatelessWidget {
  final VoidCallback onPressed;
  const FollowButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: panelStyle['followButtonHeight'],
      child: Transform.translate(
        offset: const Offset(0, -1),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: panelStyle['followButtonPaddingH'],
              vertical: panelStyle['followButtonPaddingV'],
            ),
            minimumSize: Size(0, panelStyle['followButtonHeight']),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: panelColor(context, 'primary').withOpacity(0.15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(panelStyle['followButtonRadius']),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            'Follow',
            style: TextStyle(
              fontSize: panelStyle['followButtonFontSize'],
              color: panelColor(context, 'primary'),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
