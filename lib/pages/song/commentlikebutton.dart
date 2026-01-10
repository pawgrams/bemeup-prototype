// Datei: pages\song\commentlikebutton.dart
import 'package:flutter/material.dart';
import 'buttonstyle.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../utils/formatBigNum.dart';

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black;
  if (key == "grey") return Colors.grey;
  return Colors.black;
}

class CommentLikeButton extends StatelessWidget {
  final VoidCallback onPressed;
  final int likes;
  const CommentLikeButton({super.key, required this.onPressed, required this.likes});

  @override
  Widget build(BuildContext context) {
    final double size = panelStyle['followButtonHeight'] + 1;
    final double fontSize = panelStyle['followButtonFontSize'] - 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: const Offset(0, -0.5),
          child: Padding(
            padding: const EdgeInsets.only(right: 0),
            child: Text(
              formatNumber(likes),
              style: TextStyle(
                fontSize: fontSize + 1,
                fontWeight: FontWeight.w400,
                color: panelColor(context, 'primary'),
              ),
            ),
          ),
        ),
        SizedBox(
          height: size -2,
          width: size -2,
          child: Transform.translate(
            offset: const Offset(0, 0),
            child: TextButton(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size(size, size),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                backgroundColor: panelColor(context, 'primary').withOpacity(0.0),
                shape: const CircleBorder(),
              ),
              onPressed: onPressed,
              child: Icon(
                Icons.favorite_border,
                size: fontSize + 2,
                color: panelColor(context, 'primary'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
