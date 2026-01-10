// Datei: pages\events\event\songlist.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../theme/dark.dart';
import '../../../../theme/light.dart';
import 'package:bemeow/widgets/getThumb.dart';
import 'highlightfilter.dart';
import 'dart:ui';
import 'package:bemeow/widgets/utils/shape.dart';
import 'booststats.dart';
import '../../song/artistoverflow.dart';
import '../../../../utils/formatBigNum.dart';
import '../../../../widgets/player.dart';

final Map<String, dynamic> songListStyle = {
  'containerColor': 'light',
  'containerMarginV': 10.0,
  'screenPadH': 8,
  'containerPadH': 12.0,
  'containerPadV': 3.0,
  'containerHeight': 66.0,
  'containerRadius': 12.0,
  'containerOpacity': 0.2,
  'thumbSize': 52.0,
  'thumbRadius': 8.0,
  'titleFontSize': 13.0,
  'titleFontWeight': FontWeight.bold,
  'titleColor': 'contrast',
  'versionFontSize': 10.0,
  'versionColor': 'contrast',
  'votesFontSize': 13.0,
  'votesColor': 'contrast',
  'votesIconSize': 14.0,
  'votesIconColor': 'contrast',
  'votesIconYOffset': -0.5,
  'votesContainerWidth': 58.0,
  'heartSize': 12.0,
  'heartColor': 'contrast',
  'artistFontSize': 11.0,
  'artistColor': 'primary',
  'artistFontWeight': FontWeight.bold,
  'artistLineWidth': 150,
  'genreFontSize': 11.0,
  'genreColor': 'yellow',
  'genrePadLeft': 2.0,
  'genrePadRight': 3.0,
  'genreMinWidth': 10.0,
  'genreLineWidth': 90,
  'cacheExtent': 1200,
  'containerBgHighlightLayer': 'base',
  'highlightShadowColor': Colors.yellow,
  'highlightShadowOpacity': 0.85,
  'highlightShadowBlurRadius': 6.0,
  'highlightShadowSpreadRadius': 1.0,
  'itemsToWaitFor': 8,
  'boostStatsHeight': 28.0,
  'boostStatsYOffset': -12.0,
};

const int _reorderAnimMs = 400;

Color songListColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[songListStyle[key]]!;
}

class SongList extends StatefulWidget {
  final List<Map<String, dynamic>> songs;
  final String stageId;
  final String shape;
  final void Function(String songId, String statKey)? onStatChanged;

  const SongList({
    super.key,
    required this.stageId,
    required this.songs,
    this.shape = 'square',
    this.onStatChanged,
  });

  @override
  State<SongList> createState() => _SongListState();
}

class _SongListState extends State<SongList> {
  bool _ready = false;
  late List<Map<String, dynamic>> _songs;
  final Map<String, int> _voteDelta = {};
  Timer? _debounce;
  final Map<String, ImageProvider> _coverMap = {};
  Map<String, int> _lastIndexById = {};
  Map<String, int> _moveDeltaById = {};

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _viewportKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _songs = _clone(widget.songs);
    _indexSnapshot(_songs);
    _prepare();
  }

  @override
  void didUpdateWidget(covariant SongList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.songs, widget.songs)) {
      final incoming = _clone(widget.songs);

      final Map<String, Map<String, dynamic>> byId = {
        for (final s in incoming) (s['uuid'] ?? '').toString(): s
      };

      for (int i = 0; i < _songs.length; i++) {
        final id = (_songs[i]['uuid'] ?? '').toString();
        if (byId.containsKey(id)) {
          _songs[i] = byId[id]!;
          byId.remove(id);
        }
      }
      _songs.addAll(byId.values);

      _indexSnapshot(_songs);
      _moveDeltaById.clear();

      _precacheTopHighlightCovers();
      if (!mounted) return;
      setState(() {});
    }
  }

  List<Map<String, dynamic>> _clone(List<Map<String, dynamic>> src) =>
      src.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);

  void _indexSnapshot(List<Map<String, dynamic>> list) {
    _lastIndexById = {
      for (int i = 0; i < list.length; i++) (list[i]['uuid'] ?? '').toString(): i
    };
  }

  Future<void> _prepare() async {
    final futures = <Future>[];
    for (int i = 0; i < _songs.length && i < songListStyle['itemsToWaitFor']; i++) {
      final song = _songs[i];
      final highlight = (song['highlight'] ?? 0) is int &&
          (song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;
      if (highlight) {
        final url = await GetThumb.getStaticCThumb(song['uuid'], path: 'music/cover/');
        if (url != null) {
          final image = NetworkImage(url);
          futures.add(precacheImage(image, context));
          _coverMap[song['uuid']] = image;
        }
      }
    }
    await Future.wait(futures);
    if (!mounted) return;
    setState(() => _ready = true);
  }

  Future<void> _precacheTopHighlightCovers() async {
    final futures = <Future>[];
    for (int i = 0; i < _songs.length && i < songListStyle['itemsToWaitFor']; i++) {
      final song = _songs[i];
      if (_coverMap.containsKey(song['uuid'])) continue;
      final highlight = (song['highlight'] ?? 0) is int &&
          (song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;
      if (highlight) {
        final url = await GetThumb.getStaticCThumb(song['uuid'], path: 'music/cover/');
        if (url != null) {
          final image = NetworkImage(url);
          futures.add(precacheImage(image, context));
          _coverMap[song['uuid']] = image;
        }
      }
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
      if (!mounted) return;
      setState(() {});
    }
  }

  void _onChildStatChanged(String songId, String statKey) {
    if (statKey == 'votes') {
      _voteDelta[songId] = (_voteDelta[songId] ?? 0) + 1;

      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 3), _applyReRanking);
    }

    if (widget.onStatChanged != null) widget.onStatChanged!(songId, statKey);
  }

  int _effectiveVotes(Map<String, dynamic> song) {
    final base = (song['votes'] ?? 0) is int ? song['votes'] as int : 0;
    final d = _voteDelta[(song['uuid'] ?? '').toString()] ?? 0;
    return base + d;
  }

  void _applyReRanking() {
    if (!mounted) return;

    final oldIndex = Map<String, int>.from(_lastIndexById);

    final List<Map<String, dynamic>> sorted = List<Map<String, dynamic>>.from(_songs);
    sorted.sort((a, b) {
      final av = _effectiveVotes(a);
      final bv = _effectiveVotes(b);
      final cmp = bv.compareTo(av);
      if (cmp != 0) return cmp;
      final at = (a['title'] ?? '').toString().toLowerCase();
      final bt = (b['title'] ?? '').toString().toLowerCase();
      return at.compareTo(bt);
    });

    final Map<String, int> newIndex = {
      for (int i = 0; i < sorted.length; i++) (sorted[i]['uuid'] ?? '').toString(): i
    };

    bool changed = false;
    if (sorted.length == _songs.length) {
      for (int i = 0; i < sorted.length; i++) {
        if ((sorted[i]['uuid'] ?? '') != (_songs[i]['uuid'] ?? '')) {
          changed = true;
          break;
        }
      }
    } else {
      changed = true;
    }

    if (changed) {
      _moveDeltaById = {
        for (final id in newIndex.keys)
          id: (newIndex[id]! - (oldIndex[id] ?? newIndex[id]!))
      };
      _indexSnapshot(sorted);
      if (!mounted) return;
      setState(() {
        _songs = sorted;
      });

      Timer(const Duration(milliseconds: _reorderAnimMs + 50), () {
        _moveDeltaById.clear();
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());

    final double itemHeight =
        songListStyle['containerHeight'] + songListStyle['containerMarginV'] * 2;
    final double listPaddingBottom = 100.0;
    final double totalHeight = _songs.length * itemHeight + listPaddingBottom;

    final List<Map<String, dynamic>> movingUp = [];
    final List<Map<String, dynamic>> movingDown = [];
    final List<Map<String, dynamic>> staticOnes = [];

    for (final s in _songs) {
      final id = (s['uuid'] ?? '').toString();
      final delta = _moveDeltaById[id] ?? 0;
      if (delta < 0) {
        movingUp.add(s);
      } else if (delta > 0) {
        movingDown.add(s);
      } else {
        staticOnes.add(s);
      }
    }

    List<Widget> _buildPositioned(List<Map<String, dynamic>> src) {
      return src.map((song) {
        final id = (song['uuid'] ?? '').toString();
        final index = _lastIndexById[id] ?? _songs.indexWhere((e) => (e['uuid'] ?? '').toString() == id);
        final top = index * itemHeight;
        final image = _coverMap[id];
        final effectiveVotes = _effectiveVotes(song);

        return AnimatedPositioned(
          key: ValueKey('pos_$id'),
          duration: const Duration(milliseconds: _reorderAnimMs),
          curve: Curves.easeInOutCubic,
          left: 0,
          right: 0,
          top: top,
          height: itemHeight,
          child: SizedBox(
            height: itemHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: songListStyle['containerMarginV'],
                horizontal: songListStyle['screenPadH'],
              ),
              child: SongListItem(
                key: ValueKey(id),
                song: song,
                stageId: widget.stageId,
                shape: widget.shape,
                backgroundImage: image,
                effectiveVotes: effectiveVotes,
                onStatChanged: _onChildStatChanged,
                scrollController: _scrollController,
                viewportKey: _viewportKey,
              ),
            ),
          ),
        );
      }).toList();
    }

    final children = <Widget>[
      ..._buildPositioned(staticOnes),
      ..._buildPositioned(movingDown),
      ..._buildPositioned(movingUp),
    ];

return ScrollConfiguration(
  behavior: const NoGlowScrollBehavior().copyWith(scrollbars: false),
  child: SingleChildScrollView(
    key: _viewportKey,
    controller: _scrollController,
    padding: EdgeInsets.zero,
    child: SizedBox(
      height: totalHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: children,
      ),
    ),
  ),
);

  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  const NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class SongListItem extends StatefulWidget {
  final Map<String, dynamic> song;
  final String stageId;
  final String shape;
  final ImageProvider? backgroundImage;
  final int effectiveVotes;
  final void Function(String songId, String statKey)? onStatChanged;
  final ScrollController scrollController;
  final GlobalKey viewportKey;

  const SongListItem({
    super.key,
    required this.song,
    required this.stageId,
    required this.shape,
    this.backgroundImage,
    required this.effectiveVotes,
    this.onStatChanged,
    required this.scrollController,
    required this.viewportKey,
  });

  @override
  State<SongListItem> createState() => _SongListItemState();
}

class _SongListItemState extends State<SongListItem> {
  late int votes;

  @override
  void initState() {
    super.initState();
    final base = widget.song['votes'] ?? 0;
    votes = (base is int ? base : 0);
    if (widget.effectiveVotes > votes) votes = widget.effectiveVotes;
  }

  @override
  void didUpdateWidget(covariant SongListItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.effectiveVotes > votes) {
      votes = widget.effectiveVotes;
    }
  }

  void _visitUserProfile(String userId) {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'userId': userId,
        'visitorUserId': null,
      },
    );
  }

  void _visitSongPage(String songId) {
    Navigator.pushNamed(
      context,
      '/song',
      arguments: {
        'songId': songId,
      },
    );
  }

  void _playSong(Map<String, dynamic> song) {
    PlayerController.instance.play(song['uuid'], songData: song);
  }

  void _onStatChanged(String songId, String statKey) async {
    if (statKey == 'votes') {
      if (!mounted) return;
      setState(() => votes++);
    }
    if (widget.onStatChanged != null) widget.onStatChanged!(songId, statKey);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color thumbShadowColor = isDark ? Colors.white : Colors.black;
    final double thumbSize = songListStyle['thumbSize'];
    final double votesContainerWidth = songListStyle['votesContainerWidth'];
    final double genrePadLeft = songListStyle['genrePadLeft'];
    final double genrePadRight = songListStyle['genrePadRight'];
    final double genreMinWidth = songListStyle['genreMinWidth'];
    final Map<String, dynamic> song = widget.song;
    final String shape = widget.shape;
    final highlight = (song['highlight'] ?? 0) is int &&
        (song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;

    final Widget thumb = GestureDetector(
      onTap: () => _playSong(song),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(thumbSize, thumbSize),
            painter: _GlowPainter(
              shape: shape,
              glowColor: thumbShadowColor.withOpacity(0.3),
              blur: 6,
            ),
          ),
          applyShape(
            GetThumb(
              uuid: song['uuid'] ?? '',
              size: thumbSize,
              path: 'music/cover/thumb/',
              filetype: 'jpg',
              fallbackPath: 'assets/defaults/cover_thumb.png',
            ),
            shape,
          ),
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Center(
                child: Icon(Icons.play_arrow, color: Colors.white.withOpacity(0.7), size: 40),
              ),
            ),
          ),
        ],
      ),
    );

    final List<String> artists =
        (song['artists'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [];
    final List<String> artistnames =
        (song['artistnames'] as List?)?.map((e) => e?.toString() ?? '').toList() ?? [];
    final List<Map<String, String>> artistObjsList = [];
    for (var i = 0; i < artists.length && i < artistnames.length; i++) {
      artistObjsList.add({'uuid': artists[i], 'name': artistnames[i]});
    }
    final primaryColor = songListColor(context, 'artistColor');
    final genre = song['genre'] ?? '';

    double genreWidth = 0;
    if (genre.toString().isNotEmpty) {
      TextPainter(
        text: TextSpan(
          text: genre,
          style: TextStyle(
            fontSize: songListStyle['genreFontSize'],
            color: songListColor(context, 'genreColor'),
          ),
        ),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      ).layout();
      genreWidth = songListStyle["genreLineWidth"];
      if (genreWidth < genreMinWidth) genreWidth = genreMinWidth;
    }

    final content = Container(
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
                          child: Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () => _visitSongPage(song['uuid']),
                                  child: Text(
                                    "${song['title'] ?? ''}",
                                    style: TextStyle(
                                      fontSize: songListStyle['titleFontSize'],
                                      fontWeight: songListStyle['titleFontWeight'],
                                      color: songListColor(context, 'titleColor'),
                                      decoration: TextDecoration.none,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${song['version'] ?? ''})",
                                style: TextStyle(
                                  fontSize: songListStyle['versionFontSize'],
                                  color: songListColor(context, 'versionColor'),
                                  decoration: TextDecoration.none,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: votesContainerWidth,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                formatNumber(votes),
                                style: TextStyle(
                                  fontSize: songListStyle['votesFontSize'],
                                  color: songListColor(context, 'votesColor'),
                                  decoration: TextDecoration.none,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Transform.translate(
                                offset: Offset(0, songListStyle['votesIconYOffset']),
                                child: Icon(
                                  Icons.rocket_launch,
                                  size: songListStyle['votesIconSize'],
                                  color: songListColor(context, 'votesIconColor'),
                                ),
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
                          child: LayoutBuilder(
                            builder: (context, box) {
                              return ArtistOverflowLine(
                                artists: artistObjsList,
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: songListStyle['artistFontSize'],
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.none,
                                ),
                                onArtistTap: (uuid) => _visitUserProfile(uuid),
                                availableWidth: songListStyle["artistLineWidth"],
                              );
                            },
                          ),
                        ),
                        SizedBox(
                          width: genreWidth,
                          child: genre.toString().isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(left: genrePadLeft, right: genrePadRight),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "$genre",
                                      style: TextStyle(
                                        fontSize: songListStyle['genreFontSize'],
                                        color: songListColor(context, 'genreColor'),
                                        decoration: TextDecoration.none,
                                      ),
                                      textAlign: TextAlign.right,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
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
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (!highlight)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: songListColor(context, 'containerColor')
                    .withOpacity(songListStyle['containerOpacity']),
                borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
              ),
            ),
          ),
        if (highlight)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                boxShadow: [
                  BoxShadow(
                    color: songListStyle['highlightShadowColor']
                        .withOpacity(songListStyle['highlightShadowOpacity']),
                    blurRadius: songListStyle['highlightShadowBlurRadius'],
                    spreadRadius: songListStyle['highlightShadowSpreadRadius'],
                  ),
                ],
              ),
            ),
          ),
        if (highlight)
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
              child: HighlightFilter(
                backgroundImage:
                    widget.backgroundImage ?? const AssetImage('assets/defaults/cover.png'),
              ),
            ),
          ),
        Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            height: songListStyle['containerHeight'],
            child: content,
          ),
        ),
        Positioned(
          bottom: songListStyle['boostStatsYOffset'],
          left: 0,
          right: 0,
          child: Center(
            child: SizedBox(
              height: songListStyle['boostStatsHeight'],
              child: BoostStats(
                votes: votes,
                spotlight: (song['spotlight'] ?? 0) < 0 ? 0 : (song['spotlight'] ?? 0),
                highlight: song['highlight'] is int ? song['highlight'] : null,
                stageId: widget.stageId,
                songId: song['uuid'],
                onStatChanged: _onStatChanged,
                scrollController: widget.scrollController,
                viewportKey: widget.viewportKey,
              ),
            ),
          ),
        ),
      ],
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
