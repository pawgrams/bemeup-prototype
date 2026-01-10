// Datei: pages/events/event/spotlight.dart
import 'package:flutter/material.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/getThumb.dart';
import 'package:flutter/foundation.dart';
import '../../../widgets/utils/listpreload.dart';
import 'highlight.dart';
import '../../../widgets/utils/shape.dart';
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
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[panelStyle[key]]!;
}

class Spotlight extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String imagePath;
  final String imageThumbPath;
  final String fileType;
  final String fallback;
  final String fallbackThumb;
  final String shape;
  final void Function(Map<String, dynamic> item)? onTap;

  const Spotlight({
    super.key,
    required this.items,
    required this.imagePath,
    required this.imageThumbPath,
    required this.fileType,
    required this.fallback,
    required this.fallbackThumb,
    this.shape = 'square',
    this.onTap,
  });

  @override
  State<Spotlight> createState() => _SpotlightState();
}

class _SpotlightState extends State<Spotlight> {
  final double coverSize = panelStyle['coverSize'];
  final int itemsPerView = panelStyle['itemsPerView'];
  final PageController controller = PageController(viewportFraction: 1);
  final int animationTimeMs = panelStyle['animationTimeMs'];

  Offset? dragStart;
  int currentPage = 0;
  int totalPages = 0;
  bool _ready = false;
  final Map<String, ImageProvider> _coverMap = {};

  @override
  void initState() {
    super.initState();
    _prepare();
  }

  Future<void> _prepare() async {
    final spotlightData = widget.items
        .where((d) => d['spotlight'] > 0)
        .toList()
      ..sort((a, b) => (a['spotlight'] as int).compareTo(b['spotlight'] as int));

    final futures = <Future>[];

    for (int i = 0; i < spotlightData.length && i < itemsPerView; i++) {
      final dataset = spotlightData[i];
      final isSuggested = dataset['uuid'].toString().startsWith('_');
      final highlight = dataset['highlight'] > DateTime.now().millisecondsSinceEpoch;
      if (highlight) {
        if (isSuggested) {
          _coverMap[dataset['uuid']] = AssetImage(widget.fallback);
        } else {
          final url = await GetThumb.getStaticCThumb(
            dataset['uuid'],
            path: widget.imagePath,
            filetype: widget.fileType,
          );
          if (url != null) {
            final image = NetworkImage(url);
            futures.add(precacheImage(image, context));
            _coverMap[dataset['uuid']] = image;
          }
        }
      }
    }

    await Future.wait(futures);
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
    if (!_ready) return const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()));

    final spotlightData = widget.items
        .where((d) => d['spotlight'] > 0)
        .toList()
      ..sort((a, b) => (a['spotlight'] as int).compareTo(b['spotlight'] as int));

    totalPages = (spotlightData.length / itemsPerView).ceil();
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
    final Color glowColor = panelColor(context, 'highlightColor');
    final String shape = widget.shape;

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
                final data = spotlightData
                    .skip(pageIndex * itemsPerView)
                    .take(itemsPerView)
                    .toList();

                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: data.map((dataset) {
                    final image = _coverMap[dataset['uuid']] ??
                        (dataset['uuid'].toString().startsWith('_') ? AssetImage(widget.fallback) : null);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: itemGap),
                      child: SpotlightItem(
                        dataset: dataset,
                        image: image,
                        shape: shape,
                        imageThumbPath: widget.imageThumbPath,
                        fileType: widget.fileType,
                        fallbackThumb: widget.fallbackThumb,
                        onTap: widget.onTap,
                        coverSize: coverSize,
                        glowColor: glowColor,
                      ),
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

class SpotlightItem extends StatefulWidget {
  final Map<String, dynamic> dataset;
  final ImageProvider? image;
  final String shape;
  final String imageThumbPath;
  final String fileType;
  final String fallbackThumb;
  final void Function(Map<String, dynamic> item)? onTap;
  final double coverSize;
  final Color glowColor;

  const SpotlightItem({
    super.key,
    required this.dataset,
    required this.image,
    required this.shape,
    required this.imageThumbPath,
    required this.fileType,
    required this.fallbackThumb,
    this.onTap,
    required this.coverSize,
    required this.glowColor,
  });

  @override
  State<SpotlightItem> createState() => _SpotlightItemState();
}

class _SpotlightItemState extends State<SpotlightItem> {
  @override
  Widget build(BuildContext context) {
    final bool isHighlighted = widget.dataset['highlight'] > DateTime.now().millisecondsSinceEpoch;
    final Widget imageWidget = widget.image != null
        ? Image(image: widget.image!, width: widget.coverSize, height: widget.coverSize, fit: BoxFit.cover)
        : GetThumb(
            uuid: widget.dataset['uuid'],
            size: widget.coverSize,
            path: widget.imageThumbPath,
            filetype: widget.fileType,
            fallbackPath: widget.fallbackThumb,
          );

    final Widget content = HighlightEffect(
      timestamp: widget.dataset['highlight'],
      glowColor: Colors.transparent,
      child: imageWidget,
    );

    return GestureDetector(
      onTap: widget.onTap != null ? () => widget.onTap!(widget.dataset) : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isHighlighted)
            CustomPaint(
              size: Size(widget.coverSize, widget.coverSize),
              painter: _GlowPainter(
                shape: widget.shape,
                glowColor: widget.glowColor,
                blur: 6,
              ),
            ),
          applyShape(
            SizedBox(width: widget.coverSize, height: widget.coverSize, child: content),
            widget.shape,
          ),
        ],
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
