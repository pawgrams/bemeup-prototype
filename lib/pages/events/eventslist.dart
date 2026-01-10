// Datei: pages/events/eventslist.dart
import 'package:flutter/material.dart';
import 'package:bemeow/widgets/getThumb.dart';
import '../../../../theme/dark.dart';
import '../../../../theme/light.dart';
import 'event/highlightfilter.dart';
import 'dart:async';
import 'dart:ui';
import '../../widgets/utils/shape.dart';
import 'event/event.dart';

final Map<String, dynamic> songListStyle = {
  'containerColor': 'light',
  'containerMarginV': 7.0,
  'screenPadH': 14,
  'containerPadH': 14.0,
  'containerPadV': 3.0,
  'containerHeight': 66.0,
  'containerRadius': 12.0,
  'containerOpacity': 0.2,
  'thumbSize': 52.0,
  'thumbRadius': 8.0,
  'titleFontSize': 13.0,
  'titleFontWeight': FontWeight.bold,
  'titleColor': 'contrast',
  'titleLetterSpacing': 1.5,
  'versionFontSize': 10.0,
  'versionColor': 'contrast',
  'likesFontSize': 13.0,
  'likesColor': 'contrast',
  'heartSize': 12.0,
  'heartColor': 'contrast',
  'artistFontSize': 11.0,
  'artistColor': 'contrast',
  'artistFontWeight': FontWeight.bold,
  'cityCountryColor': 'primary',
  'genreFontSize': 11.0,
  'genreColor': 'yellow',
  'genrePadLeft': 2.0,
  'cacheExtent': 1200,
  'containerBgHighlightLayer': 'base',
  'highlightShadowColor': Colors.yellow,
  'highlightShadowOpacity': 0.85,
  'highlightShadowBlurRadius': 6.0,
  'highlightShadowSpreadRadius': 1.0,
  'itemsToWaitFor': 8,
};

Color songListColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[songListStyle[key]]!;
}

class EventsList extends StatefulWidget {
  final List<Map<String, dynamic>> events;
  final String shape;

  const EventsList({
    super.key,
    required this.events,
    this.shape = 'square',
  });

  @override
  State<EventsList> createState() => _EventsState();
}

class _EventsState extends State<EventsList> {
  final Map<String, ImageProvider> _coverMap = {};
  final Map<String, ImageProvider> _bgMap = {};
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepareCovers();
  }

  Future<void> _prepareCovers() async {
    final futures = <Future>[];
    for (final e in widget.events) {
      final h = e['highlight'] is int && e['highlight'] > DateTime.now().millisecondsSinceEpoch;
      final id = e['uuid'];
      if (h) {
        final thumbUrl = await GetThumb.getStaticCThumb(id, path: 'events/', filetype: 'jpg');
        if (thumbUrl != null) {
          final img = NetworkImage(thumbUrl);
          futures.add(precacheImage(img, context));
          _coverMap[id] = img;
        }
        final bgUrl = await GetThumb.getStaticCThumb(id, path: 'events/9-16/', filetype: 'jpg');
        if (bgUrl != null) {
          final bg = NetworkImage(bgUrl);
          futures.add(precacheImage(bg, context));
          _bgMap[id] = bg;
        }
      }
    }
    await Future.wait(futures);
    if (!mounted) return;
    setState(() => _ready = true);
  }

  String formatDateRange(int start, int end) {
    final s = DateTime.fromMillisecondsSinceEpoch(start);
    final e = DateTime.fromMillisecondsSinceEpoch(end);
    if (s.year == e.year && s.month == e.month && s.day == e.day) {
      return "${s.day} ${_monthName(s.month)} ${s.year}";
    }
    return "${s.day} – ${e.day} ${_monthName(e.month)} ${e.year}";
  }

  String _monthName(int month) {
    const names = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());

    final double itemH = songListStyle['containerHeight'] + 2 * songListStyle['containerMarginV'];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color shadowColor = isDark ? Colors.white : Colors.black;
    final String shape = widget.shape;
    final double thumbSize = songListStyle['thumbSize'];

    return ListView.builder(
      itemCount: widget.events.length,
      cacheExtent: songListStyle['cacheExtent'],
      padding: EdgeInsets.zero,
      itemBuilder: (context, idx) {
        final e = widget.events[idx];
        final h = e['highlight'] is int && e['highlight'] > DateTime.now().millisecondsSinceEpoch;
        final id = e['uuid'];
        final bg = _bgMap[id];

        final Widget thumb = Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(thumbSize, thumbSize),
              painter: _GlowPainter(
                shape: shape,
                glowColor: shadowColor.withOpacity(0.7),
                blur: 3,
              ),
            ),
            applyShape(
              GetThumb(
                uuid: id,
                size: thumbSize,
                path: 'events/thumb/',
                filetype: 'jpg',
                fallbackPath: 'assets/defaults/cover_thumb.png',
              ),
              shape,
            ),
          ],
        );

        final content = GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => Event(event: e)),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: songListStyle['containerPadH'],
              vertical: songListStyle['containerPadV'],
            ),
            height: songListStyle['containerHeight'],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: thumbSize, height: thumbSize, child: thumb),
                const SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: thumbSize,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                  e['name'] ?? '',
                                  style: TextStyle(
                                    fontSize: songListStyle['titleFontSize'],
                                    fontWeight: songListStyle['titleFontWeight'],
                                    letterSpacing: songListStyle['titleLetterSpacing'],
                                    color: songListColor(context, 'titleColor'),
                                    decoration: TextDecoration.none,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${e['favorites'] ?? 0}",
                                      style: TextStyle(
                                        fontSize: songListStyle['likesFontSize'],
                                        color: songListColor(context, 'likesColor'),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      Icons.favorite,
                                      size: songListStyle['heartSize'],
                                      color: songListColor(context, 'heartColor'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Text(
                                  "${e['city'] ?? ''} / ${(e['country'] ?? '').toString().toUpperCase()}",
                                  style: TextStyle(
                                    fontSize: songListStyle['artistFontSize'],
                                    fontWeight: songListStyle['artistFontWeight'],
                                    color: songListColor(context, 'cityCountryColor'),
                                    decoration: TextDecoration.none,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: EdgeInsets.only(left: songListStyle['genrePadLeft']),
                                  child: Text(
                                    formatDateRange(e['start'] ?? 0, e['end'] ?? 0),
                                    style: TextStyle(
                                      fontSize: songListStyle['genreFontSize'],
                                      color: songListColor(context, 'genreColor'),
                                      decoration: TextDecoration.none,
                                    ),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );

        return SizedBox(
          height: itemH,
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: songListStyle['containerMarginV'],
              horizontal: songListStyle['screenPadH'],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (!h)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: songListColor(context, 'containerColor').withOpacity(songListStyle['containerOpacity']),
                        borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                      ),
                    ),
                  ),
                if (h)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                        boxShadow: [
                          BoxShadow(
                            color: songListStyle['highlightShadowColor'].withOpacity(songListStyle['highlightShadowOpacity']),
                            blurRadius: songListStyle['highlightShadowBlurRadius'],
                            spreadRadius: songListStyle['highlightShadowSpreadRadius'],
                          ),
                        ],
                      ),
                    ),
                  ),
                if (h && bg != null)
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                      child: HighlightFilter(backgroundImage: bg),
                    ),
                  ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: songListStyle['containerHeight'],
                    child: content,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _GlowPainter extends CustomPainter {
  final String shape;
  final Color glowColor;
  final double blur;

  _GlowPainter({required this.shape, required this.glowColor, required this.blur});

  @override
  void paint(Canvas canvas, Size size) {
    final path = getShapePath(shape, size);
    final paint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
