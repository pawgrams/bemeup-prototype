// Datei: context\get_screen_category.dart
import 'package:flutter/widgets.dart';
import 'device_categories.dart';

class ScreenCategory {

    static UserDeviceType getUserScreenType(BuildContext context) {

        final size = MediaQuery.of(context).size;
        final shortestSide = size.shortestSide;

        if (shortestSide >= 1024) return UserDeviceType.desktop;
        if (shortestSide >= 600) return UserDeviceType.tablet;
        return UserDeviceType.phone;

    }
}