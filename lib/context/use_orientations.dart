// Datei: context\use_orientations.dart
import 'package:flutter/services.dart';
import 'get_device_category.dart';
import 'device_categories.dart';
import 'package:flutter/widgets.dart';

Future<List<DeviceOrientation>> getAllowedOrientations(BuildContext context) async {

    final device = await getUserDevice(context);

    switch (device) {

      case UserDeviceType.phone:
          return [DeviceOrientation.portraitUp];

      case UserDeviceType.tablet:
      case UserDeviceType.desktop:
          return [
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ];

      default:
          return [
            DeviceOrientation.portraitUp,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ];
          
    }


}
