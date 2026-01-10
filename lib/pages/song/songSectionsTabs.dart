// Datei: pages\song\SongSectionsTabs.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SongSectionsTabs {
  final IconData? icon;
  final String? svgPath;
  const SongSectionsTabs({this.icon, this.svgPath});
}

final Map<String, List<String>> sectionMap = {
  'info': ['comments', 'likes', 'lyrics'],
  'boost': ['votes', 'spotlight', 'highlight'],
  'milestones': ['eventplays', 'bundles', 'playlists'],
  'fungible': ['chart', 'details', 'orderbook'],
  'collectible': ['details', 'orderbook'], 
};

final Map<String, SongSectionsTabs> sectionIcons = {
  'info': SongSectionsTabs(icon: Icons.info),
  'boost': SongSectionsTabs(icon: Icons.rocket_launch),
  'milestones': SongSectionsTabs(icon: Icons.star),
  'fungible': SongSectionsTabs(icon: Icons.monetization_on_sharp),
  'collectible': SongSectionsTabs(icon: Icons.image),
};

final Map<String, SongSectionsTabs> itemIcons = {

  'comments': SongSectionsTabs(icon: Icons.comment),
  'eventplays': SongSectionsTabs(icon: Icons.event_available),
  'lyrics': SongSectionsTabs(icon: Icons.lyrics),
  'votes': SongSectionsTabs(icon: Icons.rocket_launch),
  'spotlight': SongSectionsTabs(icon: Icons.center_focus_strong),
  'highlight': SongSectionsTabs(icon: Icons.whatshot),
  'events': SongSectionsTabs(icon: Icons.event),
  'likes': SongSectionsTabs(icon: Icons.favorite),
  'bundles': SongSectionsTabs(icon: Icons.grid_view_sharp),
  'playlists': SongSectionsTabs(svgPath: 'assets/icons/svg/playlists.svg'),
  'upcoming': SongSectionsTabs(icon: Icons.event), 
  'done': SongSectionsTabs(icon: Icons.event_available),
  'chart': SongSectionsTabs(icon: Icons.trending_up),
  'details': SongSectionsTabs(icon: Icons.article),
  'orderbook': SongSectionsTabs(icon: Icons.menu_book)

};

Widget getSectionTabIconWidget(SongSectionsTabs tab, {double size = 22}) {
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