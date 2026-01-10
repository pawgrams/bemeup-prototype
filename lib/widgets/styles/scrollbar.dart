// Datei: widgets\styles\scrollbar.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';

class HoverScrollbar extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final double thickness;
  final Radius radius;
  final bool? isDark;

  const HoverScrollbar({
    required this.child,
    required this.controller,
    this.thickness = 6,
    this.radius = const Radius.circular(3),
    this.isDark,
    super.key,
  });

  @override
  State<HoverScrollbar> createState() => _HoverScrollbarState();
}

class _HoverScrollbarState extends State<HoverScrollbar> {
  bool _thumbHover = false;

  Color _resolveThumbColor(BuildContext context) {
    final isDark = widget.isDark ?? Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? darkThemeMap : lightThemeMap;
    return theme["primary"]!;
  }

  @override
  Widget build(BuildContext context) {
    final thumbColor = _resolveThumbColor(context);

    return ScrollConfiguration(
      behavior: const _NoGlowBehavior(),
      child: MouseRegion(
        onHover: (e) {
          final box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(e.position);
          final w = box.size.width;
          if (local.dx > w - widget.thickness) {
            if (!_thumbHover) {
              if (!mounted) return;
              setState(() => _thumbHover = true);
            }
          } else {
            if (_thumbHover) {
              if (!mounted) return;
              setState(() => _thumbHover = false);
            }
          }
        },
        onExit: (_) {
          if (_thumbHover) {
            if (!mounted) return;
            setState(() => _thumbHover = false);
          }
        },
        child: RawScrollbar(
          controller: widget.controller,
          thumbVisibility: true,
          thickness: widget.thickness,
          radius: widget.radius,
          thumbColor: thumbColor.withOpacity(_thumbHover ? 0.7 : 0.3),
          child: widget.child,
        ),
      ),
    );
  }
}

class _NoGlowBehavior extends ScrollBehavior {
  const _NoGlowBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}
