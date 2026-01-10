// Datei: pages/home/musicforyou.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/getThumb.dart';
import '../../widgets/utils/listpreload.dart';
import '../../widgets/utils/shape.dart';
import 'dart:ui';

final Map<String, dynamic> panelStyle = {
  'coverSize': 65.0,
  'itemsPerView': 3,
  'height': 85.0,
  'opacity': 0.3,
  'color': 'base',
  'cacheExtent': 40, 
  'itemGap': 9.0,
  'animationTimeMs': 180,
  'arrowSize': 18,
  'arrowColor': 'contrast',
  'arrowPadH': 2.0,
  'arrowOffsetLeft': 8.0,
  'arrowOffsetRight': 3.0,
  'arrowOpacity': 0.5,
  'highlightColor': 'yellow',
  'mainMarginH': 0.0,
  'mainPaddingH': 4.0,
  'boxGapWidth': 13.0,
  'moreFontColor': 'primary',
  'moreTextGapRight': 24.0,
  'moreFontSize': 10.0,
  'moreFontWeight': FontWeight.bold,
  'moreLetterSpacing': 1.1,
  'titleGapHeight': 2.0,
  'titleFontSize': 11.0,
  'titleFontWeight': FontWeight.w600,
  'contentPaddingV': 2.0,
  'clipWidth': 250.0,
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[panelStyle[key]]!;
}

class MusicForYouPreview extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final String imagePath;
  final String imageThumbPath;
  final String fileType;
  final String fallback;
  final String fallbackThumb;
  final String shape;
  final void Function(Map<String, dynamic> item)? onTap;

  const MusicForYouPreview({
    super.key,
    required this.items,
    this.imagePath = 'music/cover/',
    this.imageThumbPath = 'music/cover/thumb/',
    this.fileType = 'jpg',
    this.fallback = 'assets/defaults/cover.png',
    this.fallbackThumb = 'assets/defaults/cover.png',
    this.shape = 'square',
    this.onTap,
  });

  @override
  State<MusicForYouPreview> createState() => _MusicForYouPanelState();
}

class _MusicForYouPanelState extends State<MusicForYouPreview> {
  final double coverSize = panelStyle['coverSize'];
  final int itemsPerView = panelStyle['itemsPerView'];
  final PageController controller = PageController(viewportFraction: 1);
  final int animationTimeMs = panelStyle['animationTimeMs'];
  Offset? dragStart;
  int totalPages = 0;

  void _gotoSong(String songId) {
    Navigator.pushNamed(
      context,
      '/song',
      arguments: {'songId': songId, 'visitorUserId': null},
    );
  }

  @override
  Widget build(BuildContext context) {
    final double height = panelStyle['height'];
    final double opacity = panelStyle['opacity'];
    final double itemGap = panelStyle['itemGap'];
    final Color bg = panelColor(context, 'color').withOpacity(opacity);
    final Color arrowColor = panelColor(context, 'arrowColor');
    final double arrowPadH = panelStyle['arrowPadH'];
    final double arrowOffsetLeft = panelStyle['arrowOffsetLeft'];
    final double arrowOffsetRight = panelStyle['arrowOffsetRight'];
    final double arrowOpacity = panelStyle['arrowOpacity'];
    final Color glowColor = panelColor(context, 'highlightColor');
    final Color moreFontColor = panelColor(context, 'moreFontColor');
    final String shape = widget.shape;
    final bool showArrows = widget.items.length > itemsPerView;
    final double contentPaddingV = panelStyle['contentPaddingV'];
    final double clipWidth = panelStyle['clipWidth'];

    totalPages = (widget.items.length / itemsPerView).ceil();

    return Container(
      height: height,
      width: double.infinity,
      color: bg,
      margin: EdgeInsets.symmetric(horizontal: panelStyle['mainMarginH']),
      padding: EdgeInsets.symmetric(
        horizontal: panelStyle['mainPaddingH'],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: contentPaddingV),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ClipRect(
                    child: SizedBox(
                      width: clipWidth,
                      child: Listener(
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
                          cacheExtent: panelStyle['cacheExtent'],
                          itemBuilder: (context, pageIndex) {
                            final data = widget.items
                                .skip(pageIndex * itemsPerView)
                                .take(itemsPerView)
                                .toList();

                            return Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: data.map((dataset) {
                                final isHighlighted = dataset['highlight'] != null && dataset['highlight'] > DateTime.now().millisecondsSinceEpoch;
                                final Widget imageWidget = GestureDetector(
                                  onTap: () => _gotoSong(dataset['uuid']),
                                  child: GetThumb(
                                    uuid: dataset['uuid'],
                                    size: coverSize,
                                    path: widget.imageThumbPath,
                                    filetype: widget.fileType,
                                    fallbackPath: widget.fallbackThumb,
                                    shape: widget.shape,
                                  ),
                                );
                                final Widget content = SizedBox(
                                  width: coverSize,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          if (isHighlighted)
                                            CustomPaint(
                                              size: Size(coverSize, coverSize),
                                              painter: _GlowPainter(
                                                shape: shape,
                                                glowColor: glowColor,
                                                blur: 6,
                                              ),
                                            ),
                                          applyShape(
                                            SizedBox(
                                              width: coverSize,
                                              height: coverSize,
                                              child: imageWidget,
                                            ),
                                            shape,
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: panelStyle['titleGapHeight']),
                                      GestureDetector(
                                        onTap: () => _gotoSong(dataset['uuid']),
                                        child: Text(
                                          dataset['title'] ?? '-',
                                          style: TextStyle(
                                            fontSize: panelStyle['titleFontSize'],
                                            fontWeight: panelStyle['titleFontWeight'],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          maxLines: 1,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: itemGap),
                                  child: content,
                                );
                              }).toList(),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  if (showArrows)
                    Positioned(
                      left: arrowOffsetLeft,
                      child: Opacity(
                        opacity: arrowOpacity,
                        child: IconButton(
                          padding: EdgeInsets.symmetric(horizontal: arrowPadH),
                          icon: Icon(Icons.arrow_back_ios, color: arrowColor, size: panelStyle["arrowSize"]),
                          splashColor: Colors.transparent,
                          onPressed: () {
                            if (controller.page! > 0) controller.previousPage(
                              duration: Duration(milliseconds: animationTimeMs),
                              curve: Curves.easeOut,
                            );
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
                          icon: Icon(Icons.arrow_forward_ios, color: arrowColor, size: panelStyle["arrowSize"]),
                          splashColor: Colors.transparent,
                          onPressed: () {
                            if (controller.page! < totalPages - 1) controller.nextPage(
                              duration: Duration(milliseconds: animationTimeMs),
                              curve: Curves.easeOut,
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(width: panelStyle['boxGapWidth']),
          Container(
            height: height,
            alignment: Alignment.center,
            child: Text(
              'MORE',
              style: TextStyle(
                color: moreFontColor,
                fontWeight: panelStyle['moreFontWeight'],
                fontSize: panelStyle['moreFontSize'],
                letterSpacing: panelStyle['moreLetterSpacing'],
              ),
            ),
          ),
          SizedBox(width: panelStyle['moreTextGapRight']),
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
