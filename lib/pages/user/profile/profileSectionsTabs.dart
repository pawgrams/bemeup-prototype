// Datei: pages\user\profile\contentMap.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileSectionsTabs {
  final IconData? icon;
  final String? svgPath;
  const ProfileSectionsTabs({this.icon, this.svgPath});
}

final Map<String, List<String>> sectionMap = {
  'music': ['songs', 'likes', 'bundles', 'playlists'],
  'events': ['upcoming', 'done'],
  'tokens': ['fungible', 'nft'],
};

final Map<String, ProfileSectionsTabs> sectionIcons = {
  'music': ProfileSectionsTabs(icon: Icons.music_note),
  'events': ProfileSectionsTabs(icon: Icons.event),
  'tokens': ProfileSectionsTabs(icon: Icons.token),
};

final Map<String, ProfileSectionsTabs> itemIcons = {
  'songs': ProfileSectionsTabs(svgPath: 'assets/icons/svg/music_01.svg'),
  'bundles': ProfileSectionsTabs(icon: Icons.grid_view_sharp),
  'playlists': ProfileSectionsTabs(svgPath: 'assets/icons/svg/playlists.svg'),
  'likes': ProfileSectionsTabs(icon: Icons.favorite),
  'upcoming': ProfileSectionsTabs(icon: Icons.event),
  'done': ProfileSectionsTabs(icon: Icons.event_available),
  'fungible': ProfileSectionsTabs(icon: Icons.monetization_on_sharp),
  'nft': ProfileSectionsTabs(icon: Icons.image),
};

Widget getSectionTabIconWidget(ProfileSectionsTabs tab, {double size = 22}) {
  if (tab.icon != null) {
    return Icon(tab.icon, size: size);
  }
  if (tab.svgPath != null && tab.svgPath!.isNotEmpty) {
    return SvgPicture.asset(
      tab.svgPath!,
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
  return Icon(Icons.help_outline, size: size);
}