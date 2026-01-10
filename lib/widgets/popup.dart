// Datei: widgets/popup.dart
import 'package:flutter/material.dart';
import '../theme/dark.dart';
import '../theme/light.dart';
import '../widgets/styles/glow_element.dart';
import '../widgets/styles/shadow_element.dart';

final Map<String, dynamic> popupStyle = {
  'borderRadius': 14.0,
  'borderWidth': 1.0,
  'padding': 12.0,
  'defaultWidth': 300.0,
  'defaultHeight': 500.0,
  'minWidth': 300.0,
  'minHeight': 160.0,
  'maxWidthPad': 32.0,
  'maxHeightPad': 32.0,
  'shadowBlur': 28.0,
  'shadowOpacity': 0.17,
  'glowBlur': 44.0,
  'yOffset': 44.0,
  'pageOverlayOpacity': 0.6,
  'borderColorKey': 'primary',
  'bgColorKey': 'base',
  'closeBtnSize': 24.0,
  'closeBtnOffset': -10.0,
  'closeBtnColor': 'contrast',
  'closeBtnIconSize': 18.0,
};

class PopupController extends ChangeNotifier {
  Widget? _child;
  bool _visible = false;
  double? _yOffset;
  bool _useBack = false;
  Widget? _backWidget;
  bool get visible => _visible;
  Widget? get child => _child;
  double? get yOffset => _yOffset;
  bool get useBack => _useBack;
  Widget? get backWidget => _backWidget;

  void show(Widget child, {double? yOffset, bool useBack = false, Widget? backWidget}) {
    _child = child;
    _visible = true;
    _yOffset = yOffset;
    _useBack = useBack && backWidget != null;
    _backWidget = backWidget;
    notifyListeners();
  }

  void hide() {
    _visible = false;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 300), () {
      _child = null;
      _yOffset = null;
      _useBack = false;
      _backWidget = null;
      notifyListeners();
    });
  }
}

final PopupController popupController = PopupController();

class PopupOverlay extends StatefulWidget {
  const PopupOverlay({super.key});

  @override
  State<PopupOverlay> createState() => _PopupOverlayState();
}

class _PopupOverlayState extends State<PopupOverlay> {

  @override
  void initState() {
    super.initState();
    popupController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!popupController.visible || popupController.child == null) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? darkThemeMap : lightThemeMap;
    final double closeBtnSize = popupStyle['closeBtnSize'];
    final double closeBtnOffset = popupStyle['closeBtnOffset'];
    final double closeBtnIconSize = popupStyle['closeBtnIconSize'];
    final double yOffset = popupController.yOffset ?? popupStyle['yOffset'];
    final double minWidth = popupStyle['minWidth'] as double;
    final double minHeight = popupStyle['minHeight'] as double;
    final double maxWidthPad = popupStyle['maxWidthPad'] as double;
    final double maxHeightPad = popupStyle['maxHeightPad'] as double;

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => popupController.hide(),
            child: Container(
              color: Colors.black.withOpacity(popupStyle['pageOverlayOpacity']),
            ),
          ),
        ),
        Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxWidth = (constraints.maxWidth - maxWidthPad).clamp(minWidth, double.infinity);
              final double maxHeight = (constraints.maxHeight - maxHeightPad).clamp(minHeight, double.infinity);
              return Transform.translate(
                offset: Offset(0, yOffset),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ShadowElement(
                      blur: popupStyle['shadowBlur'],
                      opacity: popupStyle['shadowOpacity'],
                      child: Container(
                        constraints: BoxConstraints(
                          minWidth: popupStyle['minWidth'],
                          minHeight: popupStyle['minHeight'],
                          maxWidth: maxWidth,
                          maxHeight: maxHeight,
                        ),
                        width: popupStyle['defaultWidth'],
                        padding: EdgeInsets.all(popupStyle['padding']),
                        decoration: BoxDecoration(
                          color: theme[popupStyle['bgColorKey']],
                          borderRadius: BorderRadius.circular(popupStyle['borderRadius']),
                          border: Border.all(
                            color: theme[popupStyle['borderColorKey']]!,
                            width: popupStyle['borderWidth'],
                          ),
                          boxShadow: buildGlow(
                            isFocused: true,
                            color: theme[popupStyle['borderColorKey']]!,
                          ),
                        ),
                        child: popupController.child,
                      ),
                    ),
                    Positioned(
                      top: -closeBtnOffset,
                      right: -closeBtnOffset,
                      child: SizedBox(
                        width: closeBtnSize,
                        height: closeBtnSize,
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(Icons.close, size: closeBtnIconSize),
                            color: theme[popupStyle['closeBtnColor']],
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            padding: EdgeInsets.zero,
                            onPressed: () => popupController.hide(),
                          ),
                        ),
                      ),
                    ),
                    if (popupController.useBack && popupController.backWidget != null)
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Transform.translate(
                          offset: Offset(-closeBtnOffset, -closeBtnOffset),
                          child: SizedBox(
                            width: closeBtnSize,
                            height: closeBtnSize,
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back, size: closeBtnIconSize),
                                color: theme[popupStyle['closeBtnColor']],
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  final bw = popupController.backWidget!;
                                  final yo = popupController.yOffset;
                                  popupController.show(bw, yOffset: yo, useBack: false);
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

void showPopup({Widget? child, double? yOffset, bool useBack = false, Widget? backWidget}) {
  final double defaultWidth = popupStyle["defaultWidth"];
  final double defaultHeight = popupStyle["defaultHeight"];
  popupController.show(child ?? SizedBox(width: defaultWidth, height: defaultHeight), yOffset: yOffset, useBack: useBack, backWidget: backWidget);
}

void hidePopup() {
  popupController.hide();
}
