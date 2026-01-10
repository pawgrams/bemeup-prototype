// Datei: widgets\minipopup.dart
import 'package:flutter/material.dart';
import '../theme/dark.dart';
import '../theme/light.dart';

final Map<String, dynamic> minipopupStyle = {
  'containerRadius': 8.0,
  'containerColor': 'contrast',
  'containerOpacity': 1.0,
  'textColor': 'base',
  'fontSize': 12.0,
  'fontWeight': FontWeight.w600,
  'paddingV': 8.0,
  'paddingH': 16.0,
  'marginTop': 12.0,
  'marginLR': 8.0,
  'fadeIn': 0.5,
  'duration': 3,
  'fadeOut': 1,
};

Color minipopupColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[minipopupStyle[key]]!;
}

class MiniPopupController extends ChangeNotifier {
  String? _text;
  bool _visible = false;
  bool _animating = false;

  String? get text => _text;
  bool get visible => _visible;

  void show(String text) async {
    if (_animating) return;
    _animating = true;
    final int duration = minipopupStyle["duration"];
    final int fadeOut = minipopupStyle["fadeOut"];

    _text = text;
    _visible = false;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 10));
    _visible = true;
    notifyListeners();

    await Future.delayed(Duration(seconds: duration));
    _visible = false;
    notifyListeners();
    await Future.delayed(Duration(seconds: fadeOut));
    if (!_visible) _text = null;
    notifyListeners();
    _animating = false;
  }
}

final MiniPopupController miniPopupController = MiniPopupController();

class MiniPopupOverlay extends StatefulWidget {
  @override
  State<MiniPopupOverlay> createState() => _MiniPopupOverlayState();
}

class _MiniPopupOverlayState extends State<MiniPopupOverlay> {
  @override
  void initState() {
    super.initState();
    miniPopupController.addListener(_onChanged);
  }

  @override
  void dispose() {
    miniPopupController.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (miniPopupController.text == null) return const SizedBox.shrink();
    double fadeIn = minipopupStyle['fadeIn'];
    double fadeOut = minipopupStyle['fadeOut'].toDouble();
    return Positioned(
      top: MediaQuery.of(context).padding.top + minipopupStyle['marginTop'],
      left: minipopupStyle['marginLR'],
      right: minipopupStyle['marginLR'],
      child: AnimatedOpacity(
        opacity: miniPopupController.visible ? 1.0 : 0.0,
        duration: Duration(
          milliseconds: miniPopupController.visible
              ? (fadeIn * 1000).round()
              : (fadeOut * 1000).round(),
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: minipopupStyle['paddingV'],
              horizontal: minipopupStyle['paddingH'],
            ),
            decoration: BoxDecoration(
              color: minipopupColor(context, 'containerColor').withOpacity(minipopupStyle['containerOpacity']),
              borderRadius: BorderRadius.circular(minipopupStyle['containerRadius']),
            ),
            child: Text(
              miniPopupController.text ?? "",
              style: TextStyle(
                color: minipopupColor(context, 'textColor'),
                fontSize: minipopupStyle['fontSize'],
                fontWeight: minipopupStyle['fontWeight'],
              ),
              textAlign: TextAlign.left,
            ),
          ),
        ),
      ),
    );
  }
}

void showMiniPopup(String text) async {
  miniPopupController.show(text);
}
