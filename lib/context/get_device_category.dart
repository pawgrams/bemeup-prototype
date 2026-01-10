// Datei: context\get_device_category.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/widgets.dart';
import 'get_screen_category.dart';
import 'device_categories.dart';


Future<UserDeviceType> getUserDevice(BuildContext context) async {

    if (kIsWeb) return ScreenCategory.getUserScreenType(context);

    final deviceInfo = DeviceInfoPlugin();

    try {

        if (defaultTargetPlatform == TargetPlatform.android) {
            final android = await deviceInfo.androidInfo;
            final isTablet = android.systemFeatures.contains('android.hardware.screen.landscape') &&
                            !android.systemFeatures.contains('android.hardware.telephony');

          return isTablet ? UserDeviceType.tablet : UserDeviceType.phone;
        }

        if (defaultTargetPlatform == TargetPlatform.iOS) {
            final ios = await deviceInfo.iosInfo;
            final model = ios.model.toLowerCase();

            if (model.contains('ipad')) return UserDeviceType.tablet;
            if (model.contains('iphone')) return UserDeviceType.phone;
        }

        if ([
            TargetPlatform.macOS,
            TargetPlatform.windows,
            TargetPlatform.linux,
        ].contains(defaultTargetPlatform)) {
            return UserDeviceType.desktop;
        }


    } catch (_) {}

    return ScreenCategory.getUserScreenType(context);

}
