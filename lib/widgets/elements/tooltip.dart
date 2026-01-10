// Datei: widgets/elements/tooltip.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';

Widget infoTooltip({
  required BuildContext context,
  required String text,
  double spacing = 8,
  double size = 14,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(width: spacing),
      Tooltip(
        message: text,
        child: Opacity(
          opacity: 0.7,
          child: SvgPicture.network(
            '/icons/svg/info.svg',
            width: size,
            height: size,
            color: (isDark ? darkThemeMap : lightThemeMap)['contrast'],
          ),
        ),
      ),
    ],
  );
}
