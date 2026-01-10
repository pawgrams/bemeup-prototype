// Datei: pages\home\songshowcase.dart
import 'package:flutter/material.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/utils/listpreload.dart';
import 'package:firebase_database/firebase_database.dart';
import '../song/artistoverflow.dart';
import '../../../widgets/getThumb.dart';

final Map<String, dynamic> panelStyle = {
  'coverSize': 100,
  'itemsPerView': 1,
  'height': 110.0,
  'opacity': 0.3,
  'color': 'base',
  'cacheExtent': 60,
  'itemGap': 6.0,
  'animationTimeMs': 200,
  'arrowColor': 'contrast',
  'arrowPadH': 2.0,
  'arrowOffsetLeft': -1.0,
  'arrowOffsetRight': -6.0,
  'arrowOpacity': 0.5,
  'highlightColor': 'yellow',
};

final Map<String, dynamic> showcaseStyle = {
  'panelRadius': 18.0,
  'avatarSize': 94.0,
  'avatarBorderWidth': 0.0,
  'backgroundOpacity': 0.1,
  'gap': 0.0,
  'titleFontSize': 14.0,
  'titleFontWeight': FontWeight.bold,
  'titleColor': 'contrast',
  'artistFontSize': 12.0,
  'artistFontWeight': FontWeight.w500,
  'artistColor': 'primary',
  'artistIconGap': 5.0,
  'panelBgOpacity': 0.3,
  'panelBgColor': 'base',
  'outerPadding': 10.0,
  'panelPaddingH': 14.0,
  'panelPaddingV': 10.0,
  'panelPaddingTop':16.0,
  'panelPaddingBottom': 16.0,
  'avatarPanelInnerPadLeft': 16.0,
  'avatarPanelInnerPadRight': 12.0,
  'statsFontSize': 11.0,
  'statsFontWeight': FontWeight.w700,
  'statsFontColor': 'primary',
  'statsIconSize': 15.0,
  'statsIconColor': 'primary',
  'statsIconGap': 8.0,
  'descFontSize': 12.0,
  'descFontColor': 'light',
  'descGapV': 2.0,
  'artistsLineWidth': 200
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[panelStyle[key]]!;
}

Color showcaseColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[showcaseStyle[key]] ?? Colors.black;
}

class SongShowCase extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  const SongShowCase({super.key, required this.items});

  @override
  State<SongShowCase> createState() => _SpotlightState();
}

class _SpotlightState extends State<SongShowCase> {
  final int itemsPerView = panelStyle['itemsPerView'];
  final PageController controller = PageController(viewportFraction: 1);
  final int animationTimeMs = panelStyle['animationTimeMs'];
  Offset? dragStart;
  int currentPage = 0;
  int totalPages = 0;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    if (!mounted) return;
    setState(() => _ready = true);
  }

  void simulateSwipe(bool forward) {
    if (forward && controller.page! < totalPages - 1) {
      controller.nextPage(
        duration: Duration(milliseconds: animationTimeMs),
        curve: Curves.easeOut,
      );
    } else if (!forward && controller.page! > 0) {
      controller.previousPage(
        duration: Duration(milliseconds: animationTimeMs),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const SizedBox(height: 132, child: Center(child: CircularProgressIndicator()));

    final spotlightData = widget.items
        .where((d) => d['spotlight'] > 0)
        .toList()
      ..sort((a, b) => (a['spotlight'] as int).compareTo(b['spotlight'] as int));

    totalPages = (spotlightData.length / itemsPerView).ceil();
    final double height = panelStyle['height'];
    final double opacity = panelStyle['opacity'];
    final int cache = panelStyle['cacheExtent'];
    final Color bg = panelColor(context, 'color').withOpacity(opacity);
    final Color arrowColor = Colors.white;
    final double arrowPadH = panelStyle['arrowPadH'];
    final double arrowOffsetLeft = panelStyle['arrowOffsetLeft'];
    final double arrowOffsetRight = panelStyle['arrowOffsetRight'];
    final double arrowOpacity = panelStyle['arrowOpacity'];
    final bool showArrows = spotlightData.length > itemsPerView;

    return Container(
      height: height,
      width: double.infinity,
      color: bg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Listener(
            onPointerDown: (event) {
              dragStart = event.position;
            },
            onPointerMove: (event) {
              if (dragStart != null) {
                final dx = event.position.dx - dragStart!.dx;
                if (dx.abs() > 20) {
                  if (dx > 0 && controller.page! > 0) {
                    controller.previousPage(
                      duration: Duration(milliseconds: animationTimeMs),
                      curve: Curves.easeOut,
                    );
                  } else if (dx < 0 && controller.page! < totalPages - 1) {
                    controller.nextPage(
                      duration: Duration(milliseconds: animationTimeMs),
                      curve: Curves.easeOut,
                    );
                  }
                  dragStart = null;
                }
              }
            },
            onPointerUp: (_) => dragStart = null,
            child: ListPreLoader(
              itemCount: totalPages,
              controller: controller,
              height: height,
              cacheExtent: cache,
              itemBuilder: (context, pageIndex) {
                final data = spotlightData
                    .skip(pageIndex * itemsPerView)
                    .take(itemsPerView)
                    .toList();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data.map((dataset) {
                    return Expanded(
                      child: _SongShowcaseEmbedded(songId: dataset['uuid']),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          if (showArrows)
            Positioned(
              left: arrowOffsetLeft,
              child: Opacity(
                opacity: arrowOpacity,
                child: IconButton(
                  padding: EdgeInsets.symmetric(horizontal: arrowPadH),
                  icon: Icon(Icons.arrow_back_ios, color: arrowColor),
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
          if (showArrows)
            Positioned(
              right: arrowOffsetRight,
              child: Opacity(
                opacity: arrowOpacity,
                child: IconButton(
                  padding: EdgeInsets.symmetric(horizontal: arrowPadH),
                  icon: Icon(Icons.arrow_forward_ios, color: arrowColor),
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
        ],
      ),
    );
  }
}

class _SongShowcaseEmbedded extends StatefulWidget {
  final String songId;
  const _SongShowcaseEmbedded({required this.songId});
  @override
  State<_SongShowcaseEmbedded> createState() => _SongShowcaseEmbeddedState();
}

class _SongShowcaseEmbeddedState extends State<_SongShowcaseEmbedded> {
  Map<String, dynamic>? songData;
  List<Map<String, String>> artistObjs = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSong();
  }

  Future<void> _loadSong() async {
    final snap = await FirebaseDatabase.instance.ref('songs/${widget.songId}').get();
    final Map<String, dynamic> data = snap.exists && snap.value != null
        ? Map<String, dynamic>.from(snap.value as Map)
        : {};
    final artists = await _getArtists(data);
    if (!mounted) return;
    setState(() {
      songData = data;
      artistObjs = artists;
      loading = false;
    });
  }

  Future<List<Map<String, String>>> _getArtists(Map<String, dynamic> song) async {
    Set<String> artistUuids = {};
    if (song['user'] != null && song['user'].toString().isNotEmpty) artistUuids.add(song['user'].toString());
    if (song['remixer'] != null && song['remixer'] is List) {
      artistUuids.addAll((song['remixer'] as List).map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty));
    }
    if (song['featured'] != null && song['featured'] is List) {
      artistUuids.addAll((song['featured'] as List).map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty));
    }
    Map<String, Map<String, String>> artistMap = {};
    for (final uuid in artistUuids) {
      if (uuid.isEmpty) continue;
      final userSnap = await FirebaseDatabase.instance.ref('users/$uuid').get();
      if (userSnap.exists && userSnap.value != null) {
        final user = Map<String, dynamic>.from(userSnap.value as Map);
        artistMap[uuid] = {
          'uuid': uuid,
          'name': user['name']?.toString() ?? '',
        };
      }
    }
    Set<String> added = {};
    List<Map<String, String>> objs = [];
    if (song['user'] != null && artistMap.containsKey(song['user'].toString())) {
      added.add(song['user'].toString());
      objs.add(artistMap[song['user'].toString()]!);
    }
    if (song['remixer'] != null && song['remixer'] is List) {
      for (final uuid in (song['remixer'] as List).map((e) => e?.toString() ?? '')) {
        if (!added.contains(uuid) && artistMap.containsKey(uuid)) {
          added.add(uuid);
          objs.add(artistMap[uuid]!);
        }
      }
    }
    if (song['featured'] != null && song['featured'] is List) {
      for (final uuid in (song['featured'] as List).map((e) => e?.toString() ?? '')) {
        if (!added.contains(uuid) && artistMap.containsKey(uuid)) {
          added.add(uuid);
          objs.add(artistMap[uuid]!);
        }
      }
    }
    return objs;
  }

  void _gotoSong() {
    Navigator.pushNamed(
      context,
      '/song',
      arguments: {'songId': widget.songId, 'visitorUserId': null},
    );
  }

  void _gotoProfile(String userId) {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {'userId': userId, 'visitorUserId': null},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));

    final String title = songData?['title'] ?? '-';
    final String genre = songData?['genre'] ?? '';
    final String version = songData?['version'] ?? '';
    final double avatarSize = showcaseStyle['avatarSize'];
    final double radius = showcaseStyle['panelRadius'];
    final double gap = showcaseStyle['gap'];
    final double panelPadH = showcaseStyle['panelPaddingH'];
    final double panelPadTop = showcaseStyle['panelPaddingTop'];
    final double panelPadBottom = showcaseStyle['panelPaddingBottom'];
    final double panelBgOpacity = showcaseStyle['panelBgOpacity'];
    final double outerPad = showcaseStyle['outerPadding'];
    final double avatarPanelInnerPadLeft = showcaseStyle['avatarPanelInnerPadLeft'];
    final Color panelBg = showcaseColor(context, 'panelBgColor').withOpacity(panelBgOpacity);
    final Color titleColor = showcaseColor(context, 'titleColor');
    final Color artistColor = showcaseColor(context, 'artistColor');
    final Color descFontColor = showcaseColor(context, 'descFontColor');
    final double descFontSize = showcaseStyle['descFontSize'];
    final double descGapV = showcaseStyle['descGapV'];

    return LayoutBuilder(
      builder: (ctx, cons) {
        final double avatarPanelSide = avatarSize + showcaseStyle['panelPaddingV'] * 2;
        final double availableWidth = cons.maxWidth - gap - outerPad * 2;
        final double infoPanelWidth = availableWidth - avatarPanelSide;

        final infoPanel = Padding(
          padding: EdgeInsets.all(outerPad),
          child: Container(
            width: infoPanelWidth,
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: EdgeInsets.only(
              left: panelPadH,
              right: panelPadH,
              top: panelPadTop,
              bottom: panelPadBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _gotoSong,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: showcaseStyle['titleFontSize'],
                      fontWeight: showcaseStyle['titleFontWeight'],
                      color: titleColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                //SizedBox(height: 2),
                if (artistObjs.isNotEmpty)
                  ArtistOverflowLine(
                    artists: artistObjs,
                    style: TextStyle(
                      fontSize: showcaseStyle['artistFontSize'],
                      fontWeight: showcaseStyle['artistFontWeight'],
                      color: artistColor,
                      decoration: TextDecoration.none,
                    ),
                    availableWidth: showcaseStyle["artistsLineWidth"],
                    onArtistTap: _gotoProfile,
                  ),
                SizedBox(height: descGapV),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (genre.isNotEmpty)
                      Text(
                        genre,
                        style: TextStyle(
                          fontSize: descFontSize,
                          color: descFontColor,
                        ),
                      ),
                    if (genre.isNotEmpty && version.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Center(
                          child: Text(
                            '\u2022',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: descFontSize + 3,
                              height: 1.1,
                              color: descFontColor,
                            ),
                          ),
                        ),
                      ),
                    if (version.isNotEmpty)
                      Text(
                        version,
                        style: TextStyle(
                          fontSize: descFontSize,
                          color: descFontColor,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: descGapV),
              ],
            ),
          ),
        );

        Widget avatarInner = GestureDetector(
          onTap: _gotoSong,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(avatarSize, avatarSize),
                painter: _GlowPainter(
                  glowColor: showcaseColor(context, 'artistColor').withOpacity(1.0),
                  blur: 4,
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: GetThumb(
                  uuid: widget.songId,
                  size: avatarSize,
                  path: 'music/cover/thumb/',
                  filetype: 'jpg',
                  fallbackPath: 'assets/defaults/cover.png',
                  shape: 'square',
                ),
              ),
            ],
          ),
        );

        Widget avatarPanel = Container(
          width: avatarPanelSide,
          height: avatarPanelSide,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(left: avatarPanelInnerPadLeft),
            child: avatarInner,
          ),
        );

        final rowChildren = [avatarPanel, SizedBox(width: gap), infoPanel];

        return Container(
          width: double.infinity,
          height: avatarPanelSide + outerPad * 2,
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          ),
        );
      },
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color glowColor;
  final double blur;
  _GlowPainter({required this.glowColor, required this.blur});
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(12.0)),
      paint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
