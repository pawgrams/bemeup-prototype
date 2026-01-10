// Datei: widgets\menu.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import 'package:flutter/foundation.dart';

class Menu extends StatelessWidget {
  const Menu({super.key});

  static const menuItems = [
    {'icon': 'events.svg',    'slug': '/events'},
    {'icon': 'create.svg',    'slug': '/create'},
    {'icon': 'playlists.svg', 'slug': '/playlists'},
    {'icon': 'wallet.svg',    'slug': '/wallet'},
    {'icon': 'bemeow.svg',    'slug': '/profile'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuTheme = isDark ? darkThemeMap : lightThemeMap;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final size = MediaQuery.of(context).size;

    if (isPortrait) {
      return Container(
        color: menuTheme['contrast'],
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: menuItems.map((item) {
            return GestureDetector(
              onTap: () => _navigate(context, item['slug']!),
              child: SizedBox(
                width: 30,
                height: 30,
                child: SvgPicture.network(
                  '/icons/svg/${item['icon']}',
                  color: menuTheme['base'],
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    final bool isWeb = kIsWeb;
    final int itemCount = menuItems.length;
    final double availableHeight = size.height;
    final double iconSize = isWeb
    ? (availableHeight / itemCount) * 0.30
    : (availableHeight / itemCount) * 0.42;
    final double rightPadding =  16.0;
    final double spacing = (availableHeight - (iconSize * itemCount)) / (itemCount + 1);

    return Container(
      color: menuTheme['contrast'],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: menuItems.map((item) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: spacing / 2),
            child: Row(
              children: [
                Expanded(child: Container()),
                Padding(
                  padding: EdgeInsets.only(right: rightPadding),
                  child: GestureDetector(
                    onTap: () => _navigate(context, item['slug']!),
                    child: SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: SvgPicture.asset(
                        'assets/icons/svg/${item['icon']}',
                        color: menuTheme['base'],
                        fit: BoxFit.contain,
                      )
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigate(BuildContext context, String target) {
    final current = ModalRoute.of(context)?.settings.name;
    if (current != target) {
      Navigator.pushNamed(context, target);
    }
  }
}
