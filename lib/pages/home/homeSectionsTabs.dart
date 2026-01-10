// Datei: pages/home/homeSectionsTabs.dart
import 'package:flutter/material.dart';

class ProfileSectionsTabs {
  final IconData? icon;
  final String? svgPath;
  const ProfileSectionsTabs({this.icon, this.svgPath});
}

final Map<String, List<String>> sectionMap = {
  'hot': ['hot', 'feed', 'charts'],
  'feed': ['upcoming', 'done'],
  'charts': ['new', 'event', 'app'],
};

final Map<String, ProfileSectionsTabs> sectionIcons = {
  'hot': ProfileSectionsTabs(svgPath: 'assets/icons/svg/hot.svg'),
  'feed': ProfileSectionsTabs(svgPath: 'assets/icons/svg/feed.svg'),
  'charts': ProfileSectionsTabs(icon: Icons.star),
};
