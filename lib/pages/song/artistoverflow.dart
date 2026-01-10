// Datei: pages\song\artistoverflow.dart
import 'package:flutter/material.dart';

class ArtistOverflowLine extends StatelessWidget {
  final List<Map<String, String>> artists;
  final void Function(String uuid) onArtistTap;
  final TextStyle style;
  final double availableWidth;

  const ArtistOverflowLine({
    super.key,
    required this.artists,
    required this.onArtistTap,
    required this.style,
    required this.availableWidth,
  });

  double _measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const SizedBox.shrink();

    final dotWidth = _measureText('...', style);
    final arrowWidth = 24.0;
    final separatorWidth = _measureText(', ', style);

    double usedWidth = 0;
    int visibleCount = 0;
    for (var i = 0; i < artists.length; i++) {
      final name = artists[i]['name'] ?? '';
      double nameWidth = _measureText(name, style);
      if (i > 0) usedWidth += separatorWidth;
      if (usedWidth + nameWidth + dotWidth + arrowWidth > availableWidth) {
        break;
      }
      usedWidth += nameWidth;
      visibleCount++;
    }

    List<Widget> line = [];
    if (visibleCount >= artists.length) {
      for (var i = 0; i < artists.length; i++) {
        if (i > 0) line.add(Text(', ', style: style));
        line.add(
          GestureDetector(
            onTap: () => onArtistTap(artists[i]['uuid'] ?? ''),
            child: Text(artists[i]['name'] ?? '', style: style),
          ),
        );
      }
      return SizedBox(
        height: (style.fontSize ?? 14) * 1.22,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: line,
        ),
      );
    }

    for (var i = 0; i < visibleCount; i++) {
      if (i > 0) line.add(Text(', ', style: style));
      line.add(
        GestureDetector(
          onTap: () => onArtistTap(artists[i]['uuid'] ?? ''),
          child: Text(artists[i]['name'] ?? '', style: style),
        ),
      );
    }

    final rest = artists.sublist(visibleCount);
    line.add(SizedBox(width: 4));
    line.add(Text('...', style: style));
    line.add(
      PopupMenuButton<Map<String, String>>(
        icon: Icon(Icons.arrow_drop_down, size: (style.fontSize ?? 14) + 7, color: style.color),
        itemBuilder: (ctx) => rest
            .map(
              (a) => PopupMenuItem<Map<String, String>>(
                value: a,
                onTap: () => onArtistTap(a['uuid'] ?? ''),
                child: Text(a['name'] ?? '', style: style),
              ),
            )
            .toList(),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(maxWidth: 250),
      ),
    );

    return SizedBox(
      height: (style.fontSize ?? 14) * 1.22,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: line,
      ),
    );
  }
}
