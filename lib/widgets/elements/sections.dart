// Datei: widgets/elements/sections.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/contents/fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math';

final Map<String, dynamic> tabsStyle = {
  'horizontalPadding': 12.0,
  'betweenButtonPadding': 12.0,
  'bgColor': 'base',
  'buttonBgActive': 'primary',
  'buttonBgInactive': 'light',
  'buttonBgInactiveOpacity': 0.1,
  'buttonTextActive': 'base',
  'buttonTextInactive': 'primary',
  'buttonRadius': 16.0,
  'buttonHeight': 30.0,
  'buttonMinWidth': 60.0,
  'arrowSize': 22.0,
  'arrowBg': 'base',
  'arrowIcon': 'primary',
  'containerHeight': 50.0,
  'itemsPerView': 3,
  'animationTimeMs': 200,
  'arrowPadH': 2.0,
  'arrowOpacity': 0.5,
  'arrowDistanceLeft': 0.0,
  'arrowDistanceRight': 0.0,
  'iconTextGap': 4.0,
  'iconSize': 15.0,
  'fontSize': 14.0,
};

Color _getTabsBgColor(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final Color base = themeMap[tabsStyle['bgColor']] ?? Colors.transparent;
  final double bgOpacity = isDark ? 0.4 : 0.6;
  return base.withOpacity(bgOpacity);
}

Color tabsColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

Widget buildSectionIcon(
  dynamic tab,
  BuildContext context,
  bool active,
) {
  final double size = tabsStyle['iconSize'];
  final Color color = tabsColor(
      context, active ? tabsStyle['buttonTextActive'] : tabsStyle['buttonTextInactive']);
  if (tab == null) return Icon(Icons.help_outline, size: size, color: color);
  if (tab.icon != null) {
    return Icon(tab.icon, size: size, color: color);
  }
  if (tab.svgPath != null && tab.svgPath.isNotEmpty) {
    return SvgPicture.asset(
      tab.svgPath,
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
  return Icon(Icons.help_outline, size: size, color: color);
}

class Sections extends StatefulWidget {
  final List<dynamic> icons;
  final List<String> labels;
  final int selectedIndex;
  final Function(int) onTap;

  const Sections({
    super.key,
    required this.icons,
    required this.labels,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<Sections> createState() => _TabsState();
}

class _TabsState extends State<Sections> {
  final PageController controller = PageController(viewportFraction: 1);
  Offset? dragStart;
  int currentPage = 0;

  int get itemsPerView => tabsStyle['itemsPerView'];
  int get totalPages => (widget.labels.length / itemsPerView).ceil();

  void simulateSwipe(bool forward) {
    if (forward && controller.page! < totalPages - 1) {
      controller.nextPage(
        duration: Duration(milliseconds: tabsStyle['animationTimeMs']),
        curve: Curves.easeOut,
      );
    } else if (!forward && controller.page! > 0) {
      controller.previousPage(
        duration: Duration(milliseconds: tabsStyle['animationTimeMs']),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double height = tabsStyle['containerHeight'];
    final Color bg = _getTabsBgColor(context);
    final Color arrowColor = tabsColor(context, tabsStyle['arrowIcon']);
    final double arrowPadH = tabsStyle['arrowPadH'];
    final double arrowSize = tabsStyle['arrowSize'];
    final double arrowDistanceLeft = tabsStyle['arrowDistanceLeft'];
    final double arrowDistanceRight = tabsStyle['arrowDistanceRight'];
    final double horizontalPadding = tabsStyle['horizontalPadding'];
    final double iconTextGap = tabsStyle['iconTextGap'];
    final double fontSize = tabsStyle['fontSize'];
    final bool showArrows = widget.labels.length > itemsPerView;
    final Color buttonBgActive = tabsColor(context, tabsStyle['buttonBgActive']);
    final Color buttonBgInactive = tabsColor(context, tabsStyle['buttonBgInactive']);
    final double buttonBgInactiveOpacity = tabsStyle['buttonBgInactiveOpacity'];

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: height,
            width: double.infinity,
            color: bg,
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Center(
              child: Listener(
                onPointerDown: (event) {
                  dragStart = event.position;
                },
                onPointerMove: (event) {
                  if (dragStart != null) {
                    final dx = event.position.dx - dragStart!.dx;
                    if (dx.abs() > 20) {
                      if (dx > 0 && controller.page! > 0) {
                        controller.previousPage(
                          duration: Duration(milliseconds: tabsStyle['animationTimeMs']),
                          curve: Curves.easeOut,
                        );
                      } else if (dx < 0 && controller.page! < totalPages - 1) {
                        controller.nextPage(
                          duration: Duration(milliseconds: tabsStyle['animationTimeMs']),
                          curve: Curves.easeOut,
                        );
                      }
                      dragStart = null;
                    }
                  }
                },
                onPointerUp: (_) => dragStart = null,
                child: PageView.builder(
                  controller: controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: totalPages,
                  onPageChanged: (i) {
                    if (!mounted) return;
                    setState(() => currentPage = i);
                  },
                  itemBuilder: (context, pageIndex) {
                    final start = pageIndex * itemsPerView;
                    final end = min(start + itemsPerView, widget.labels.length);
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(end - start, (j) {
                        final i = start + j;
                        final bool active = i == widget.selectedIndex;
                        return Padding(
                          padding: EdgeInsets.only(
                            right: (j != end - start - 1) ? tabsStyle['betweenButtonPadding'] : 0,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(tabsStyle['buttonRadius']),
                            onTap: () => widget.onTap(i),
                            child: Container(
                              constraints: BoxConstraints(minWidth: tabsStyle['buttonMinWidth']),
                              height: tabsStyle['buttonHeight'],
                              decoration: BoxDecoration(
                                color: active
                                    ? buttonBgActive
                                    : buttonBgInactive.withOpacity(buttonBgInactiveOpacity),
                                borderRadius: BorderRadius.circular(tabsStyle['buttonRadius']),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 18.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  buildSectionIcon(widget.icons[i], context, active),
                                  SizedBox(width: iconTextGap),
                                  Text(
                                    widget.labels[i],
                                    style: appFonts['text']!(fontSize).copyWith(
                                      color: tabsColor(context, active ? tabsStyle['buttonTextActive'] : tabsStyle['buttonTextInactive']),
                                      fontWeight: active ? FontWeight.bold : FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ),
          if (showArrows)
            Positioned(
              left: arrowDistanceLeft,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: tabsStyle['arrowOpacity'],
                  child: IconButton(
                    padding: EdgeInsets.symmetric(horizontal: arrowPadH),
                    icon: Icon(Icons.arrow_back_ios, color: arrowColor, size: arrowSize),
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    disabledColor: Colors.transparent,
                    enableFeedback: false,
                    onPressed: () => simulateSwipe(false),
                  ),
                ),
              ),
            ),
          if (showArrows)
            Positioned(
              right: arrowDistanceRight,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(
                  opacity: tabsStyle['arrowOpacity'],
                  child: IconButton(
                    padding: EdgeInsets.symmetric(horizontal: arrowPadH),
                    icon: Icon(Icons.arrow_forward_ios, color: arrowColor, size: arrowSize),
                    splashColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    disabledColor: Colors.transparent,
                    enableFeedback: false,
                    onPressed: () => simulateSwipe(true),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
