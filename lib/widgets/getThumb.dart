// Datei: frontend\lib\widgets\getThumb.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'utils/shape.dart';
import 'utils/imagewrapper.dart';

class GetThumb extends StatefulWidget {
  final String uuid;
  final double size;
  final String path;
  final String filetype;
  final String fallbackPath;
  final String shape;

  const GetThumb({
    super.key,
    required this.uuid,
    required this.size,
    required this.path,
    required this.filetype,
    required this.fallbackPath,
    this.shape = 'square',
  });

  static Future<String?> getStaticCThumb(String uuid, {required String path, String filetype = 'jpg'}) async {
    if (uuid.startsWith('_')) return null;
    try {
      return await FirebaseStorage.instance.ref('$path$uuid.$filetype').getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  @override
  State<GetThumb> createState() => _GetThumbState();
}

class _GetThumbState extends State<GetThumb> {
  Future<String?>? _future;

  @override
  void initState() {
    super.initState();
    _future = _getThumbUrl(widget.uuid);
  }

  Future<String?> _getThumbUrl(String uuid) async {
    try {
      return await FirebaseStorage.instance.ref('${widget.path}$uuid.${widget.filetype}').getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: FutureBuilder<String?>(
        future: _future,
        builder: (context, snapshot) {
          Widget image;
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData && snapshot.data != null) {
            image = ImageWrapper(
              url: snapshot.data!,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.cover,
              fallbackPath: widget.fallbackPath,
            );
          } else {
            image = Image.asset(widget.fallbackPath, fit: BoxFit.cover, width: widget.size, height: widget.size);
          }
          return applyShape(image, widget.shape);
        },
      ),
    );
  }
}
