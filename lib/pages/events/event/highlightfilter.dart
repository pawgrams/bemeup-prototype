// Datei: pages\events\event\highlightfilter.dart
import 'package:flutter/material.dart';

class HighlightFilter extends StatelessWidget {
  final ImageProvider backgroundImage;

  const HighlightFilter({super.key, required this.backgroundImage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final contrastReduce = <double>[
      0.5, 0,    0,    0, 20,
      0,    0.5, 0,    0, 20,
      0,    0,    0.5, 0, 20,
      0,    0,    0,    1, 0,
    ];

    final yellowSuppress = <double>[
      1, 0, 0, 0, 0,
      0, 0.85, 0, 0, 0,
      0, 0, 0.8, 0, 0,
      0, 0, 0, 1, 0,
    ];

    final turquoiseSuppress = <double>[
      1, 0, 0, 0, 0,
      0, 0.75, 0, 0, 0,
      0, 0, 0.75, 0, 0,
      0, 0, 0, 1, 0,
    ];

    final desaturate = <double>[
      0.75, 0.2, 0.2, 0, 0,
      0.2, 0.75, 0.2, 0, 0,
      0.2, 0.2, 0.75, 0, 0,
      0, 0, 0, 1, 0,
    ];

    final blendColor = isDark ? Colors.white : Colors.white;
    final blendOpacity = isDark ? 0.6 : 0.4;
    final blendMode = BlendMode.overlay;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.matrix(contrastReduce),
            child: ColorFiltered(
              colorFilter: ColorFilter.matrix(
                isDark ? yellowSuppress : turquoiseSuppress,
              ),
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(desaturate),
                child: Image(
                  image: backgroundImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            color: isDark
                ? Colors.black.withOpacity(0.6)
                : Colors.white.withOpacity(0.4),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  blendColor.withOpacity(blendOpacity),
                  blendColor.withOpacity(blendOpacity),
                ],
              ),
              backgroundBlendMode: blendMode,
            ),
          ),
        ],
      ),
    );
  }
}
