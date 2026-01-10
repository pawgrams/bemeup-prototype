// Datei: context\get_orientation.dart
import 'package:flutter/widgets.dart';

enum Orientation {
    portait,
    landscape,
}

class ScreenCategory {

    static Orientation getOrientation(BuildContext context) {
    
        final size = MediaQuery.of(context).size;
        final width = size.width;
        final height = size.height;
        final isPortrait = height >= width;

        return isPortrait
            ? Orientation.portait
            : Orientation.landscape;
    }

}
