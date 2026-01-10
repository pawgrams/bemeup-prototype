// Datei: widgets\elements\options.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';

class OptionsIcon extends StatelessWidget {
  
  final VoidCallback? onTap;

  const OptionsIcon({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? darkThemeMap : lightThemeMap;
    final Color iconColor = theme['contrast']!;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: SizedBox(
        width: 30,
        height: 30,
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/svg/options.svg',
            width: 20,
            height: 20,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
