// Datei: widgets/elements/background.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../context/get_device_category.dart';
import '../../context/device_categories.dart';
import '../utils/imagewrapper.dart';

class DeviceBackground extends StatefulWidget {
  final String imageName;
  final bool blank;
  final String? customImagePath;

  const DeviceBackground({
    super.key,
    required this.imageName,
    this.blank = false,
    this.customImagePath,
  });

  @override
  State<DeviceBackground> createState() => _DeviceBackgroundState();
}

class _DeviceBackgroundState extends State<DeviceBackground> {
  late final Future<String?>? _customImageFuture;

  @override
  void initState() {
    super.initState();
    _customImageFuture = (widget.customImagePath != null && widget.customImagePath!.isNotEmpty)
        ? FirebaseStorage.instance.ref(widget.customImagePath!).getDownloadURL()
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.blank) return Container(color: isDark ? Colors.black : Colors.white);

        final yellowSuppress = <double>[
          1, 0, 0, 0, 0,      // R
          0, 0.85, 0, 0, 0,   // G
          0, 0, 0.8, 0, 0,    // B
          0, 0, 0, 1, 0,      // A
        ];
        final turquoiseSuppress = <double>[
          1, 0, 0, 0, 0,      // R
          0, 0.75, 0, 0, 0,   // G
          0, 0, 0.75, 0, 0,   // B
          0, 0, 0, 1, 0,      // A
        ];

    Widget buildFilteredBackground(Widget imageWidget) {
      return Positioned.fill(
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColorFiltered(
              colorFilter: ColorFilter.matrix(isDark ? yellowSuppress : turquoiseSuppress),
              child: ColorFiltered(
                colorFilter: isDark
                    ? ColorFilter.mode(Colors.black.withOpacity(0.6), BlendMode.darken)
                    : ColorFilter.mode(Colors.white.withOpacity(0.3), BlendMode.lighten),
                child: imageWidget,
              ),
            ),
            Container(
              color: isDark
                  ? Colors.black.withOpacity(0.1)
                  : Colors.white.withOpacity(0.35),
            ),
          ],
        ),
      );
    }

    if (_customImageFuture != null) {
      return FutureBuilder<String?>(
        future: _customImageFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return Container(color: isDark ? Colors.black : Colors.white);
          }
          if (snap.hasData && snap.data != null) {
            final size = MediaQuery.of(context).size;
            return buildFilteredBackground(
              ImageWrapper(
                url: snap.data!,
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
              ),
            );
          }
          return Container(color: isDark ? Colors.black : Colors.white);
        },
      );
    }

    return FutureBuilder<UserDeviceType>(
      future: getUserDevice(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final device = snapshot.data!;
        String folder = switch (device) {
          UserDeviceType.desktop => 'desktop',
          UserDeviceType.tablet => 'tablet',
          UserDeviceType.phone => 'mobile',
          _ => 'desktop'
        };
        final path = 'assets/backgrounds/$folder/${widget.imageName}';

        return buildFilteredBackground(
          Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: isDark ? Colors.black : Colors.white),
          ),
        );
      },
    );
  }
}
