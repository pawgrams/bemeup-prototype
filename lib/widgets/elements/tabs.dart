// Datei: widgets\elements\tabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';

final Map<String, dynamic> tabsStyle = {
  'height': 32.0,
  'iconSize': 14.0,
  'iconTextGap': 6.0,
  'fontSize': 15.0,
  'activeIconColor': 'primary',
  'inactiveIconColor': 'contrast',
  'inactiveIconOpacity': 0.6,
  'activeTabBgColor': 'contrast',
  'inactiveTabBgColor': 'base',
  'activeTabBgOpacity': 0.1,
  'inactiveTabBgOpacity': 0.4,
  'bgColor': 'base',
  'bgOpacity': 0.0,
  'borderColor': 'contrast',
  'borderWidth': 0.0,
  'borderRadius': 0.0,
  'dividerOpacity': 0.1,
  'glassEffectOpacity': 0.5,
  'shadowBlurRadius': 0.0,
  'shadowOffsetY': 1.5,
  'shadowOpacity': 0.0,
  'shadowColor': 'primary',
};

Color tabsColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

class Tabs extends StatelessWidget {
  final List<dynamic> icons;
  final int selectedIndex;
  final Function(int) onTap;

  const Tabs({
    super.key,
    required this.icons,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Color activeIconColor = tabsColor(context, tabsStyle['activeIconColor']);
    final Color inactiveIconColor = tabsColor(context, tabsStyle['inactiveIconColor']).withOpacity(tabsStyle['inactiveIconOpacity']);
    final Color borderColor = tabsColor(context, tabsStyle['borderColor']);
    final Color activeTabBgColor = tabsColor(context, tabsStyle['activeTabBgColor']).withOpacity(tabsStyle['activeTabBgOpacity']);
    final Color inactiveTabBgColor = tabsColor(context, tabsStyle['inactiveTabBgColor']).withOpacity(tabsStyle['inactiveTabBgOpacity']);
    final double borderWidth = tabsStyle['borderWidth'];
    final double borderRadius = tabsStyle['borderRadius'];
    final double dividerOpacity = tabsStyle['dividerOpacity'];
    final double shadowBlurRadius = tabsStyle['shadowBlurRadius'];
    final double shadowOffsetY = tabsStyle['shadowOffsetY'];
    final double shadowOpacity = tabsStyle['shadowOpacity'];
    final Color shadowColor = tabsColor(context, tabsStyle['shadowColor']);
    final double iconSize = tabsStyle['iconSize'];

    return Container(
      height: tabsStyle['height'],
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withOpacity(dividerOpacity), width: borderWidth),
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(shadowOpacity),
            offset: Offset(0, shadowOffsetY),
            blurRadius: shadowBlurRadius,
          )
        ],
      ),
      child: Row(
        children: List.generate(icons.length, (i) {
          final bool isActive = i == selectedIndex;
          final dynamic iconObj = icons[i];
          Widget iconWidget;
          if (iconObj.icon != null) {
            iconWidget = Icon(
              iconObj.icon,
              size: iconSize,
              color: isActive ? activeIconColor : inactiveIconColor,
            );
          } else if (iconObj.svgPath != null) {
            iconWidget = SvgPicture.asset(
              iconObj.svgPath!,
              width: iconSize,
              height: iconSize,
              color: isActive ? activeIconColor : inactiveIconColor,
            );
          } else {
            iconWidget = SizedBox(width: iconSize, height: iconSize);
          }
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.only(
                topLeft: i == 0 ? Radius.circular(borderRadius) : Radius.zero,
                bottomLeft: i == 0 ? Radius.circular(borderRadius) : Radius.zero,
                topRight: i == icons.length - 1 ? Radius.circular(borderRadius) : Radius.zero,
                bottomRight: i == icons.length - 1 ? Radius.circular(borderRadius) : Radius.zero,
              ),
              onTap: () => onTap(i),
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isActive ? activeTabBgColor : inactiveTabBgColor,
                  border: Border(
                    left: i > 0
                        ? BorderSide(color: borderColor.withOpacity(dividerOpacity), width: borderWidth)
                        : BorderSide.none,
                  ),
                ),
                child: Center(child: iconWidget),
              ),
            ),
          );
        }),
      ),
    );
  }
}
