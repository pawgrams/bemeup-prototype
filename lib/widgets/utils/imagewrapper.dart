// Datei: widgets\utils\imagewrapper.dart
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageWrapper extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final BoxFit fit;
  final String? fallbackPath;

  const ImageWrapper({
    super.key,
    required this.url,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.fallbackPath,
  });

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      errorWidget: (context, url, error) {
        if (fallbackPath != null) {
          return Image.asset(fallbackPath!, width: width, height: height, fit: fit);
        }
        return const SizedBox.shrink();
      },
      placeholder: (context, url) => Container(
        width: width,
        height: height,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      cacheKey: url,
    );
  }
}
