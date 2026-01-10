// Datei: widgets/waveform.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/dark.dart';
import '../theme/light.dart';

final Map<String, dynamic> waveformStyle = {
  'waveformBarWidth': 3.0,
  'waveformBarHeight': 26.0,
  'waveformBarSpacing': 1.0,
  'waveformPlayedColor': 'primary',
  'waveformUnplayedColor': 'placeholder',
  'waveformBarRadius': 2.0,
  'waveformBarHeightEmpty': 32.0,
};

Color playerColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[waveformStyle[key]]!;
}

class Waveform extends StatelessWidget {
  final String? svgUrl;
  final String? svgAsset;
  final double playedFraction;
  final Duration totalDuration;
  final Function(Duration) onSeek;

  const Waveform({
    super.key,
    required this.svgUrl,
    required this.svgAsset,
    required this.playedFraction,
    required this.totalDuration,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double waveformWidth = constraints.maxWidth;
        double waveformHeight = 32;
        return SizedBox(
          width: waveformWidth,
          height: waveformHeight,
          child: Stack(
            children: [
              if (svgUrl != null || svgAsset != null)
                Positioned.fill(
                  child: _SvgWithColor(
                    url: svgUrl,
                    asset: svgAsset,
                    color: playerColor(context, 'waveformUnplayedColor'),
                    width: waveformWidth,
                    height: waveformHeight,
                  ),
                ),
              if (svgUrl != null || svgAsset != null)
                Positioned.fill(
                  child: ClipRect(
                    clipper: _WaveformClipper(playedFraction),
                    child: _SvgWithColor(
                      url: svgUrl,
                      asset: svgAsset,
                      color: playerColor(context, 'waveformPlayedColor'),
                      width: waveformWidth,
                      height: waveformHeight,
                    ),
                  ),
                ),
              if (svgUrl != null || svgAsset != null)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: (d) {
                      final box = context.findRenderObject() as RenderBox;
                      final localPos = box.globalToLocal(d.globalPosition);
                      double tapX = localPos.dx.clamp(0, waveformWidth);
                      double percent = tapX / waveformWidth;
                      Duration newPos = Duration(
                          milliseconds: (totalDuration.inMilliseconds * percent).toInt());
                      onSeek(newPos);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _WaveformClipper extends CustomClipper<Rect> {
  final double fraction;
  _WaveformClipper(this.fraction);
  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, size.width * fraction, size.height);
  }
  @override
  bool shouldReclip(_WaveformClipper oldClipper) => oldClipper.fraction != fraction;
}

class _SvgWithColor extends StatelessWidget {
  final String? url;
  final String? asset;
  final Color color;
  final double width;
  final double height;
  const _SvgWithColor({this.url, this.asset, required this.color, required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    if (url != null) {
      return SvgPicture.network(
        url!,
        width: width,
        height: height,
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        allowDrawingOutsideViewBox: true,
      );
    }
    if (asset != null) {
      return SvgPicture.asset(
        asset!,
        width: width,
        height: height,
        fit: BoxFit.fill,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        allowDrawingOutsideViewBox: true,
      );
    }
    return SizedBox(width: width, height: height);
  }
}
