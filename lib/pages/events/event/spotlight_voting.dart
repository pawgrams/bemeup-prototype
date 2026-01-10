// Datei: pages/events/event/spotlight_voting.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/getThumb.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/utils/listpreload.dart';
import 'highlight.dart';
import '../../../widgets/utils/shape.dart';
import '../../../utils/formatBigNum.dart';
import 'dart:ui';

final Map<String, dynamic> panelStyle = {
  'coverSize': 100,
  'itemsPerView': 3,
  'height': 120.0,
  'opacity': 0.3,
  'color': 'dark',
  'cacheExtent': 60,
  'itemGap': 6.0,
  'animationTimeMs': 200,
  'arrowColor': 'contrast',
  'arrowPadH': 2.0,
  'arrowOffsetLeft': -1.0,
  'arrowOffsetRight': -6.0,
  'arrowOpacity': 0.5,
  'highlightColor': 'yellow',
  'lightningTextSize': 12.0,
  'lightningTextWeight': FontWeight.bold,
  'lightningTextColor': 'primary',
  'lightningIconSize': 14.0,
  'lightningIconColor': 'primary',
  'lightningIconYOffset': 0.0,
  'lightningPanelXOffset': 2.0,
  'lightningPanelYOffset': 1.0,
  'lightingPanelBgColor': 'base',
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[panelStyle[key]]!;
}

class SpotlightVoting extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String imagePath;
  final String imageThumbPath;
  final String fileType;
  final String fallback;
  final String fallbackThumb;
  final String shape;
  final void Function(Map<String, dynamic> item)? onTap;
  final Map<String, int> spotlightMap;
  final void Function(String songId)? onSpotlightIncrement;

  const SpotlightVoting({
    super.key,
    required this.items,
    required this.imagePath,
    required this.imageThumbPath,
    required this.fileType,
    required this.fallback,
    required this.fallbackThumb,
    this.shape = 'square',
    this.onTap,
    required this.spotlightMap,
    this.onSpotlightIncrement,
  });

  @override
  State<SpotlightVoting> createState() => _SpotlightVotingState();
}

class _SpotlightVotingState extends State<SpotlightVoting> {
  final double coverSize = panelStyle['coverSize'];
  final int itemsPerView = panelStyle['itemsPerView'];
  final PageController controller = PageController(viewportFraction: 1);
  final int animationTimeMs = panelStyle['animationTimeMs'];

  Offset? dragStart;
  int totalPages = 0;
  bool _ready = false;
  late List<Map<String, dynamic>> _items;
  final Map<String, int> _spotlightDelta = {};
  Timer? _debounce;
  Map<String, int> _lastIndexById = {};
  Map<String, int> _moveDeltaById = {};
  final Map<String, ImageProvider> _coverMap = {};

  @override
  void initState() {
    super.initState();
    _items = _clone(widget.items);
    _indexSnapshot(_sortedAll(_items));
    _prepare();
  }

  @override
  void didUpdateWidget(covariant SpotlightVoting oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.items, widget.items) || oldWidget.spotlightMap != widget.spotlightMap) {
      final incoming = _clone(widget.items);
      final Map<String, Map<String, dynamic>> byId = {
        for (final s in incoming) (s['uuid'] ?? '').toString(): s
      };

      for (int i = 0; i < _items.length; i++) {
        final id = (_items[i]['uuid'] ?? '').toString();
        if (byId.containsKey(id)) {
          _items[i] = byId[id]!;
          byId.remove(id);
        }
      }
      _items.addAll(byId.values);

      _indexSnapshot(_sortedAll(_items));
      _precacheTopCovers();
      if (!mounted) return;
      setState(() {});
    }
  }

  List<Map<String, dynamic>> _clone(List<Map<String, dynamic>> src) =>
      src.map((e) => Map<String, dynamic>.from(e)).toList(growable: true);

  int _baseSpotlightOf(Map<String, dynamic> song) {
    final id = (song['uuid'] ?? '').toString();
    final backend = widget.spotlightMap[id] ?? (song['spotlight'] ?? 0);
    return backend is int ? backend : 0;
  }

  int _effectiveSpotlight(Map<String, dynamic> song) {
    final id = (song['uuid'] ?? '').toString();
    return _baseSpotlightOf(song) + (_spotlightDelta[id] ?? 0);
  }

  List<Map<String, dynamic>> _sortedAll(List<Map<String, dynamic>> src) {
    final list = List<Map<String, dynamic>>.from(src);
    list.sort((a, b) {
      final asv = _effectiveSpotlight(a);
      final bsv = _effectiveSpotlight(b);
      final cmp1 = bsv.compareTo(asv);
      if (cmp1 != 0) return cmp1;
      final av = (a['votes'] ?? 0) is int ? a['votes'] as int : 0;
      final bv = (b['votes'] ?? 0) is int ? b['votes'] as int : 0;
      final cmp2 = bv.compareTo(av);
      if (cmp2 != 0) return cmp2;
      final at = (a['title'] ?? '').toString().toLowerCase();
      final bt = (b['title'] ?? '').toString().toLowerCase();
      return at.compareTo(bt);
    });
    return list;
  }

  List<Map<String, dynamic>> get _visibleSpotlightItems {
    final filtered = _items.where((s) => _baseSpotlightOf(s) > 0).toList();
    return _sortedAll(filtered);
  }

  void _indexSnapshot(List<Map<String, dynamic>> list) {
    _lastIndexById = {
      for (int i = 0; i < list.length; i++) (list[i]['uuid'] ?? '').toString(): i
    };
  }

  Future<void> _prepare() async {
    final futures = <Future>[];
    final first = _visibleSpotlightItems;
    for (int i = 0; i < first.length && i < itemsPerView; i++) {
      final song = first[i];
      final highlight = (song['highlight'] ?? 0) is int &&
          (song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;
      if (highlight) {
        final url = await GetThumb.getStaticCThumb(
          song['uuid'],
          path: widget.imagePath,
          filetype: widget.fileType,
        );
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

  Future<void> _precacheTopCovers() async {
    final futures = <Future>[];
    final first = _visibleSpotlightItems;
    for (int i = 0; i < first.length && i < itemsPerView; i++) {
      final song = first[i];
      if (_coverMap.containsKey(song['uuid'])) continue;
      final highlight = (song['highlight'] ?? 0) is int &&
          (song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;
      if (highlight) {
        final url = await GetThumb.getStaticCThumb(
          song['uuid'],
          path: widget.imagePath,
          filetype: widget.fileType,
        );
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

  void _onChildSpotlightIncrement(String songId) {
    _spotlightDelta[songId] = (_spotlightDelta[songId] ?? 0) + 1;

    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), _applyReRanking);

    if (widget.onSpotlightIncrement != null) widget.onSpotlightIncrement!(songId);
  }

  void _applyReRanking() {
    if (!mounted) return;

    final oldSorted = _sortedAll(_items);
    final oldIndex = {
      for (int i = 0; i < oldSorted.length; i++) (oldSorted[i]['uuid'] ?? '').toString(): i
    };

    final newSorted = _sortedAll(_items);
    final newIndex = {
      for (int i = 0; i < newSorted.length; i++) (newSorted[i]['uuid'] ?? '').toString(): i
    };

    bool changed = false;
    if (oldSorted.length == newSorted.length) {
      for (int i = 0; i < newSorted.length; i++) {
        if ((newSorted[i]['uuid'] ?? '') != (oldSorted[i]['uuid'] ?? '')) {
          changed = true;
          break;
        }
      }
    } else {
      changed = true;
    }

    if (changed) {
      _moveDeltaById = {
        for (final id in newIndex.keys) id: (newIndex[id]! - (oldIndex[id] ?? newIndex[id]!))
      };
      _indexSnapshot(newSorted);
      if (!mounted) return;
      setState(() {
        _items = newSorted;
      });

      Timer(Duration(milliseconds: animationTimeMs + 50), () {
        _moveDeltaById.clear();
        if (!mounted) return;
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));
    }

    final spotlightSongs = _visibleSpotlightItems;
    totalPages = (spotlightSongs.length / itemsPerView).ceil().clamp(1, 1 << 30);

    final double height = panelStyle['height'];
    final double opacity = panelStyle['opacity'];
    final int cache = panelStyle['cacheExtent'];
    final double itemGap = panelStyle['itemGap'];
    final Color bg = panelColor(context, 'color').withOpacity(opacity);
    final Color arrowColor = panelColor(context, 'arrowColor');
    final double arrowPadH = panelStyle['arrowPadH'];
    final double arrowOffsetLeft = panelStyle['arrowOffsetLeft'];
    final double arrowOffsetRight = panelStyle['arrowOffsetRight'];
    final double arrowOpacity = panelStyle['arrowOpacity'];
    final bool showArrows = spotlightSongs.length > itemsPerView;

    return Container(
      height: height,
      width: double.infinity,
      color: bg,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Listener(
            onPointerDown: (event) {
              if (kIsWeb ||
                  defaultTargetPlatform == TargetPlatform.macOS ||
                  defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux) {
                dragStart = event.position;
              }
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
                final pageItems = spotlightSongs
                    .skip(pageIndex * itemsPerView)
                    .take(itemsPerView)
                    .toList();

                final List<Map<String, dynamic>> movingLeft = [];
                final List<Map<String, dynamic>> movingRight = [];
                final List<Map<String, dynamic>> staticOnes = [];

                for (final s in pageItems) {
                  final id = (s['uuid'] ?? '').toString();
                  final delta = _moveDeltaById[id] ?? 0;
                  if (delta < 0) {
                    movingLeft.add(s);
                  } else if (delta > 0) {
                    movingRight.add(s);
                  } else {
                    staticOnes.add(s);
                  }
                }

                return KeyedSubtree(
                  key: PageStorageKey('sv_page_$pageIndex'),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final pageWidth = constraints.maxWidth;
                      final slotWidth = coverSize + 2 * itemGap;
                      final rowWidth = itemsPerView * slotWidth;
                      final left0 = (pageWidth - rowWidth) / 2.0 + itemGap;
                      final double top = (height - coverSize) / 2.0;

                      final Map<String, double> targetLeftById = {
                        for (int i = 0; i < pageItems.length; i++)
                          (pageItems[i]['uuid'] ?? '').toString(): left0 + i * slotWidth
                      };

                      Widget itemBuilder(Map<String, dynamic> song) {
                        final id = (song['uuid'] ?? '').toString();
                        final image = _coverMap[id];
                        final effSpot = _effectiveSpotlight(song);
                        return RepaintBoundary(
                          child: SpotlightVotingItem(
                            key: ValueKey(id),
                            song: song,
                            image: image,
                            shape: widget.shape,
                            imageThumbPath: widget.imageThumbPath,
                            fileType: widget.fileType,
                            fallbackThumb: widget.fallbackThumb,
                            onTap: widget.onTap,
                            effectiveSpotlightValue: effSpot,
                            onSpotlightIncrement: _onChildSpotlightIncrement,
                          ),
                        );
                      }

                      return _AnimatedSlotLayer(
                        height: height,
                        top: top,
                        coverSize: coverSize,
                        animationMs: animationTimeMs,
                        targetLeftById: targetLeftById,
                        staticItems: staticOnes,
                        movingRight: movingRight,
                        movingLeft: movingLeft,
                        itemBuilder: itemBuilder,
                      );
                    },
                  ),
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
                  onPressed: () {
                    if (controller.page! > 0) {
                      controller.previousPage(
                        duration: Duration(milliseconds: animationTimeMs),
                        curve: Curves.easeOut,
                      );
                    }
                  },
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
                  onPressed: () {
                    if (controller.page! < totalPages - 1) {
                      controller.nextPage(
                        duration: Duration(milliseconds: animationTimeMs),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedSlotLayer extends StatefulWidget {
  final double height;
  final double top;
  final double coverSize;
  final int animationMs;

  final Map<String, double> targetLeftById;

  final List<Map<String, dynamic>> staticItems;
  final List<Map<String, dynamic>> movingRight;
  final List<Map<String, dynamic>> movingLeft;

  final Widget Function(Map<String, dynamic> song) itemBuilder;

  const _AnimatedSlotLayer({
    Key? key,
    required this.height,
    required this.top,
    required this.coverSize,
    required this.animationMs,
    required this.targetLeftById,
    required this.staticItems,
    required this.movingRight,
    required this.movingLeft,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  State<_AnimatedSlotLayer> createState() => _AnimatedSlotLayerState();
}

class _AnimatedSlotLayerState extends State<_AnimatedSlotLayer> {
  final Map<String, double> _leftById = {};

  @override
  void didUpdateWidget(covariant _AnimatedSlotLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool needsSetState = false;
      widget.targetLeftById.forEach((id, targetLeft) {
        final prev = _leftById[id];
        if (prev == null) {
          _leftById[id] = targetLeft;
        } else if ((prev - targetLeft).abs() > 0.5) {
          _leftById[id] = targetLeft;
          needsSetState = true;
        }
      });
      if (needsSetState) {
        if (!mounted) return;
        setState(() {});
      }
    });
  }

  List<Widget> _buildGroup(List<Map<String, dynamic>> list) {
    return list.map((song) {
      final id = (song['uuid'] ?? '').toString();
      final left = _leftById[id] ?? widget.targetLeftById[id] ?? 0.0;
      return AnimatedPositioned(
        key: ValueKey('pos_$id'),
        duration: Duration(milliseconds: widget.animationMs),
        curve: Curves.easeInOutCubic,
        top: widget.top,
        left: left,
        width: widget.coverSize,
        height: widget.coverSize,
        child: widget.itemBuilder(song),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        ..._buildGroup(widget.staticItems),
        ..._buildGroup(widget.movingRight),
        ..._buildGroup(widget.movingLeft),
      ],
    );
  }
}

class SpotlightVotingItem extends StatefulWidget {
  final Map<String, dynamic> song;
  final ImageProvider? image;
  final String shape;
  final String imageThumbPath;
  final String fileType;
  final String fallbackThumb;
  final void Function(Map<String, dynamic> item)? onTap;
  final int effectiveSpotlightValue;
  final void Function(String songId)? onSpotlightIncrement;

  const SpotlightVotingItem({
    super.key,
    required this.song,
    required this.image,
    required this.shape,
    required this.imageThumbPath,
    required this.fileType,
    required this.fallbackThumb,
    this.onTap,
    required this.effectiveSpotlightValue,
    this.onSpotlightIncrement,
  });

  @override
  State<SpotlightVotingItem> createState() => _SpotlightVotingItemState();
}

class _SpotlightVotingItemState extends State<SpotlightVotingItem> {
  late int spotlightValue;

  @override
  void initState() {
    super.initState();
    final base = (widget.song['spotlight'] ?? 0) is int ? widget.song['spotlight'] as int : 0;
    spotlightValue = base;
    if (widget.effectiveSpotlightValue > spotlightValue) {
      spotlightValue = widget.effectiveSpotlightValue;
    }
  }

  @override
  void didUpdateWidget(covariant SpotlightVotingItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.effectiveSpotlightValue > spotlightValue) {
      spotlightValue = widget.effectiveSpotlightValue;
    }
  }

  void incrementSpotlight() {
    if (!mounted) return;
    setState(() => spotlightValue++);
    if (widget.onSpotlightIncrement != null) {
      widget.onSpotlightIncrement!(widget.song['uuid']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double coverSize = panelStyle['coverSize'];
    final Color glowColor = panelColor(context, 'highlightColor');
    final double lightningTextSize = panelStyle['lightningTextSize'];
    final FontWeight lightningTextWeight = panelStyle['lightningTextWeight'];
    final Color lightningTextColor = panelColor(context, 'lightningTextColor');
    final double lightningIconSize = panelStyle['lightningIconSize'];
    final Color lightningIconColor = panelColor(context, 'lightningIconColor');
    final double lightningIconYOffset = panelStyle['lightningIconYOffset'];
    final double lightningPanelXOffset = panelStyle['lightningPanelXOffset'];
    final double lightningPanelYOffset = panelStyle['lightningPanelYOffset'];
    final Color lightingPanelBgColor = panelColor(context, 'lightingPanelBgColor');
    final bool isHighlighted =
        (widget.song['highlight'] ?? 0) is int &&
        (widget.song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;

    return RepaintBoundary(
      
      child: GestureDetector(
        onTap: widget.onTap != null ? () => widget.onTap!(widget.song) : null,
        child: SizedBox(
          width: coverSize,
          height: coverSize,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isHighlighted)
                      CustomPaint(
                        size: Size(coverSize, coverSize),
                        painter: _GlowPainter(
                          shape: widget.shape,
                          glowColor: glowColor,
                          blur: 6,
                        ),
                      ),
                    applyShape(
                      SizedBox(
                        width: coverSize,
                        height: coverSize,
                        child: HighlightEffect(
                          timestamp: widget.song['highlight'] ?? 0,
                          glowColor: Colors.transparent,
                          child: widget.image != null
                              ? Image(
                                  image: widget.image!,
                                  width: coverSize,
                                  height: coverSize,
                                  fit: BoxFit.cover,
                                )
                              : GetThumb(
                                  uuid: widget.song['uuid'],
                                  size: coverSize,
                                  path: widget.imageThumbPath,
                                  filetype: widget.fileType,
                                  fallbackPath: widget.fallbackThumb,
                                ),
                        ),
                      ),
                      widget.shape,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: -4,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(1.0),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        child: Text(
                          widget.song['title']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: -lightningPanelXOffset,
                bottom: -lightningPanelYOffset,
                child: Material(
                  color: lightingPanelBgColor,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(7, 2, 3, 2),
                    decoration: BoxDecoration(
                      color: lightingPanelBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          formatNumber(spotlightValue),
                          style: TextStyle(
                            fontSize: lightningTextSize,
                            fontWeight: lightningTextWeight,
                            color: lightningTextColor,
                          ),
                        ),
                        const SizedBox(width: 1),
                        GestureDetector(
                          onTap: incrementSpotlight,
                          child: Transform.translate(
                            offset: Offset(0, lightningIconYOffset),
                            child: Icon(
                              Icons.bolt,
                              size: lightningIconSize,
                              color: lightningIconColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
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
