// Datei: pages\events\event\booststats.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/dark.dart';
import '../../../../theme/light.dart';
import 'itemtap.dart';

final Map<String, dynamic> songListStyle = {
  'boostIconSize': 17.0,
  'boostIconSizeRocket': 17.0,
  'boostIconSizeBolt': 19.0,
  'boostIconSizeFire': 19.0,
  'boostFontSize': 14.0,
  'boostFontWeight': FontWeight.bold,
  'boostColor': 'primary',
  'boostGap': 10.0,
  'boostBgColor': 'dark',
  'boostBgOpacity': 0.8,
  'boostCircleSize': 28.0,
  'boostRocketMainSize': 30.0,
  'boostRocketMainIconSize': 24.0,
  'boostRocketMainIconOpacity': 1.0,
  'boostRocketMainColor': 'primary',
  'boostRocketMainBgColor': 'primary',
  'boostRocketMainBgOpacity': 0.0,
  'boostRocketMainContainerSize': 36.0,
  'boostRocketMainShadowColor': Colors.black,
  'boostRocketMainShadowBlur': 14.0,
  'boostRocketMainShadowSpread': 0.0,
  'boostRocketMainShadowOffsetY': 3.0,
  'boostRocketMainShadowOpacity': 0.9,
  'boostDropdownXOffset': -14.0,
  'boostDropdownYOffset': -3.5,
  'boostIconBoltStretchX': 1.25,
  'boostIconFireStretchX': 0.9,
  'boostDropdownIconShadowColor': Colors.black,
  'boostDropdownIconShadowBlur': 10.0,
  'boostDropdownIconShadowSpread': 0.0,
  'boostDropdownIconShadowOffsetY': 2.0,
  'boostDropdownIconShadowOpacity': 0.4,
  'reduceIconDropdownOpenedViewportHeight': 140,
  'yOffestIconDropdownOpenedViewport': 30,
};

Color boostStatsColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[songListStyle[key]] ?? (songListStyle[key] is Color ? songListStyle[key] : Colors.black);
}

class BoostStats extends StatefulWidget {
  final int votes;
  final int spotlight;
  final int? highlight;
  final String stageId;
  final String songId;
  final void Function(String songId, String statKey)? onStatChanged;
  final ScrollController? scrollController;
  final GlobalKey? viewportKey;

  const BoostStats({
    super.key,
    required this.votes,
    required this.spotlight,
    this.highlight,
    required this.stageId,
    required this.songId,
    this.onStatChanged,
    this.scrollController,
    this.viewportKey,
  });

  @override
  State<BoostStats> createState() => _BoostStatsState();
}

class _BoostStatsState extends State<BoostStats> {
  late int fireMinutes;
  Timer? _timer;
  OverlayEntry? _overlayEntry;
  bool _expanded = false;
  final LayerLink _layerLink = LayerLink();

  Timer? _autoCloseTicker;
  VoidCallback? _scrollListener;

  @override
  void initState() {
    super.initState();
    fireMinutes = _calcFireMinutes();
    if (widget.highlight != null && widget.highlight! > DateTime.now().millisecondsSinceEpoch) {
      _timer = Timer.periodic(const Duration(minutes: 1), (t) {
        if (!mounted) return;
        setState(() {
          fireMinutes = _calcFireMinutes();
        });
      });
    }
  }

  int _calcFireMinutes() {
    if (widget.highlight == null) return 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = widget.highlight! - now;
    return diff > 0 ? (diff ~/ 60000) : 0;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopAutoCloseWatch();
    _removeDropdown();
    super.dispose();
  }

  void _toggleDropdown() {
    if (_expanded) {
      _removeDropdown();
    } else {
      _showDropdown();
    }
    if (!mounted) return;
    setState(() => _expanded = !_expanded);
  }

  void _showDropdown() {
    _overlayEntry = _buildOverlayEntry();
    Overlay.of(context, debugRequiredFor: widget).insert(_overlayEntry!);
    _startAutoCloseWatch();
  }

  void _removeDropdown() {
    _stopAutoCloseWatch();
    _overlayEntry?.remove();
    _overlayEntry = null;
    _expanded = false;
  }

  void _startAutoCloseWatch() {
    if (widget.scrollController != null) {
      _scrollListener ??= () => _checkVisibilityAndMaybeClose();
      widget.scrollController!.addListener(_scrollListener!);
    }
    _autoCloseTicker?.cancel();
    _autoCloseTicker = Timer.periodic(const Duration(milliseconds: 120), (_) {
      _checkVisibilityAndMaybeClose();
    });
    _checkVisibilityAndMaybeClose();
  }

  void _stopAutoCloseWatch() {
    if (widget.scrollController != null && _scrollListener != null) {
      widget.scrollController!.removeListener(_scrollListener!);
    }
    _scrollListener = null;
    _autoCloseTicker?.cancel();
    _autoCloseTicker = null;
  }

  void _checkVisibilityAndMaybeClose() {
    if (!_expanded) return;
    final targetBox = context.findRenderObject() as RenderBox?;
    final vpKey = widget.viewportKey;
    if (targetBox == null || vpKey == null || vpKey.currentContext == null) return;

    final viewportBox = vpKey.currentContext!.findRenderObject() as RenderBox?;
    if (viewportBox == null) return;

    final Offset targetTopLeft = targetBox.localToGlobal(Offset.zero);
    final Size targetSize = targetBox.size;
    final Rect targetRect = Rect.fromLTWH(targetTopLeft.dx, targetTopLeft.dy, targetSize.width, targetSize.height);

    final Offset vpTopLeft = viewportBox.localToGlobal(Offset(0, songListStyle["yOffestIconDropdownOpenedViewport"]));
    final Size vpSize = viewportBox.size;
    final Rect viewportRect = Rect.fromLTWH(vpTopLeft.dx, vpTopLeft.dy, vpSize.width, vpSize.height - songListStyle["reduceIconDropdownOpenedViewportHeight"]);

    final bool verticallyVisible = !(targetRect.bottom < viewportRect.top || targetRect.top > viewportRect.bottom);
    if (!verticallyVisible) {
      if (mounted) {
        setState(() {
          _removeDropdown();
        });
      } else {
        _removeDropdown();
      }
    }
  }

  OverlayEntry _buildOverlayEntry() {
    final circleSize = songListStyle['boostCircleSize'];
    final gap = songListStyle['boostGap'];
    final color = boostStatsColor(context, 'boostColor');
    final bgColor = boostStatsColor(context, 'boostBgColor').withOpacity(songListStyle['boostBgOpacity']);
    final mainRocketSize = songListStyle['boostRocketMainSize'];
    final xOffset = songListStyle['boostDropdownXOffset'];
    final yOffset = songListStyle['boostDropdownYOffset'];
    final iconCount = 3;
    final rowWidth = circleSize * iconCount + gap * (iconCount - 1);
    final boltStretchX = songListStyle['boostIconBoltStretchX'];
    final fireStretchX = songListStyle['boostIconFireStretchX'];

    final dropdownShadowColor = (songListStyle['boostDropdownIconShadowColor'] is Color)
        ? songListStyle['boostDropdownIconShadowColor']
        : Colors.black;
    final dropdownShadowBlur = songListStyle['boostDropdownIconShadowBlur'];
    final dropdownShadowSpread = songListStyle['boostDropdownIconShadowSpread'];
    final dropdownShadowOffsetY = songListStyle['boostDropdownIconShadowOffsetY'];
    final dropdownShadowOpacity = songListStyle['boostDropdownIconShadowOpacity'];

    Widget statContainer(
      IconData icon,
      double iconSize, {
      bool stretchBolt = false,
      bool stretchFire = false,
      required String actionType,
    }) {
      Widget iconWidget = Icon(icon, size: iconSize, color: color);
      if (stretchBolt) {
        iconWidget = Transform.scale(
          scaleX: boltStretchX,
          scaleY: 1.0,
          child: iconWidget,
        );
      } else if (stretchFire) {
        iconWidget = Transform.scale(
          scaleX: fireStretchX,
          scaleY: 1.0,
          child: iconWidget,
        );
      }
      return GestureDetector(
        onTap: () {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset position = box.localToGlobal(Offset.zero) +
              Offset(
                circleSize / 2 + (icon == Icons.rocket_launch ? 0 : icon == Icons.bolt ? circleSize + gap : 2 * (circleSize + gap)),
                0,
              );
          showItemTapEffect(
            context: context,
            icon: icon,
            iconSize: iconSize,
            color: color,
            globalOffset: position,
            type: actionType,
            stageId: widget.stageId,
            songId: widget.songId,
            onSuccess: () {
              if (widget.onStatChanged != null) {
                if (actionType == 'vote') widget.onStatChanged!(widget.songId, 'votes');
                if (actionType == 'spotlight') widget.onStatChanged!(widget.songId, 'spotlight');
                if (actionType == 'highlight') widget.onStatChanged!(widget.songId, 'highlight');
              }
            },
          );
        },
        child: Container(
          width: circleSize,
          height: circleSize,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: dropdownShadowColor.withOpacity(dropdownShadowOpacity),
                blurRadius: dropdownShadowBlur,
                offset: Offset(0, dropdownShadowOffsetY),
                spreadRadius: dropdownShadowSpread,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: iconWidget,
        ),
      );
    }

    return OverlayEntry(
      builder: (context) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          _removeDropdown();
          if (!mounted) return;
          setState(() {});
        },
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(
                  -(rowWidth - mainRocketSize) / 2 + xOffset,
                  (songListStyle['boostRocketMainContainerSize'] - circleSize) / 2 + yOffset,
                ),
                child: SizedBox(
                  width: rowWidth,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      statContainer(
                        Icons.rocket_launch,
                        songListStyle['boostIconSizeRocket'],
                        actionType: 'vote',
                      ),
                      statContainer(
                        Icons.bolt,
                        songListStyle['boostIconSizeBolt'],
                        stretchBolt: true,
                        actionType: 'spotlight',
                      ),
                      statContainer(
                        Icons.local_fire_department,
                        songListStyle['boostIconSizeFire'],
                        stretchFire: true,
                        actionType: 'highlight',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mainRocketSize = songListStyle['boostRocketMainSize'];
    final mainRocketIconSize = songListStyle['boostRocketMainIconSize'];
    final mainRocketIconOpacity = songListStyle['boostRocketMainIconOpacity'];
    final mainRocketColor = boostStatsColor(context, 'boostRocketMainColor');
    final mainRocketBgColor = boostStatsColor(context, 'boostRocketMainBgColor').withOpacity(songListStyle['boostRocketMainBgOpacity']);
    final mainRocketContainerSize = songListStyle['boostRocketMainContainerSize'];
    final boxShadowColor = (songListStyle['boostRocketMainShadowColor'] is Color)
        ? songListStyle['boostRocketMainShadowColor']
        : Colors.black;
    final boxShadowBlur = songListStyle['boostRocketMainShadowBlur'];
    final boxShadowSpread = songListStyle['boostRocketMainShadowSpread'];
    final boxShadowOffsetY = songListStyle['boostRocketMainShadowOffsetY'];

    return CompositedTransformTarget(
      link: _layerLink,
      child: !_expanded
          ? GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _toggleDropdown,
              child: Container(
                width: mainRocketContainerSize,
                height: mainRocketContainerSize,
                decoration: BoxDecoration(
                  color: mainRocketBgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: mainRocketSize,
                  height: mainRocketSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: boxShadowColor.withOpacity(songListStyle["boostRocketMainShadowOpacity"]),
                        blurRadius: boxShadowBlur,
                        offset: Offset(0, boxShadowOffsetY),
                        spreadRadius: boxShadowSpread,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Opacity(
                    opacity: mainRocketIconOpacity,
                    child: Icon(Icons.rocket_launch, size: mainRocketIconSize, color: mainRocketColor),
                  ),
                ),
              ),
            )
          : const SizedBox(width: 0, height: 0),
    );
  }
}
