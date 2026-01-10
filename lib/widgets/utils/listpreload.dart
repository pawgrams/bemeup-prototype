// Datei: widgets\utils\listpreload.dart
import 'package:flutter/material.dart';

class ListPreLoader extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final Axis scrollDirection;
  final ScrollPhysics physics;
  final PageController? controller;
  final double? height;
  final double? width;
  final int cacheExtent;

  const ListPreLoader({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.scrollDirection = Axis.horizontal,
    this.physics = const ClampingScrollPhysics(),
    this.controller,
    this.height,
    this.width,
    this.cacheExtent = 1200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: PageView.builder(
        controller: controller,
        scrollDirection: scrollDirection,
        physics: physics,
        itemCount: itemCount,
        padEnds: false,
        pageSnapping: true,
        allowImplicitScrolling: true,
        itemBuilder: itemBuilder,
        clipBehavior: Clip.none,
      ),
    );
  }
}
