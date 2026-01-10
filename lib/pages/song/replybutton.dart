// Datei: pages\song\replybutton.dart
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
  return Colors.black;
}

class ReplyButton extends StatelessWidget {
  final VoidCallback onPressed;
  const ReplyButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final double size = panelStyle['followButtonHeight'];
    final double fontSize = panelStyle['followButtonFontSize'];
    return SizedBox(
      height: size -2,
      width: size -2,
      child: Transform.translate(
        offset: const Offset(0, -1),
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
            Icons.reply,
            size: fontSize + 2,
            color: panelColor(context, 'primary'),
          ),
        ),
      ),
    );
  }
}
