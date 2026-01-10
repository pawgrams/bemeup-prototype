// Datei:  widgets\utils\childscroll.dart
import 'package:flutter/material.dart';

const Set<String> childScrollPages = {
  'ranking'
};

Widget childScrollWrapper(BuildContext context, String pageTitle, Widget child, Widget Function(Widget) buildScrollable) {
  final isSelfScroll = childScrollPages.contains(pageTitle.toLowerCase());
  return isSelfScroll ? child : buildScrollable(child);
}
