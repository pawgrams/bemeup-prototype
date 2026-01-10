// Datei: pages/song/likebutton.dart
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

class LikeButton extends StatelessWidget {
  final VoidCallback onPressed;
  const LikeButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final double size = panelStyle['followButtonHeight'];
    return SizedBox(
      height: size,
      width: size,
      child: Transform.translate(
        offset: const Offset(0, -2),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size(size, size),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: panelColor(context, 'primary').withOpacity(0.15),
            shape: const CircleBorder(),
          ),
          onPressed: onPressed,
          child: Icon(
            Icons.favorite,
            size: panelStyle['followButtonFontSize'] + 2,
            color: panelColor(context, 'primary'),
          ),
        ),
      ),
    );
  }
}
