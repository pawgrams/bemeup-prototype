// Datei: widgets\elements\button.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../styles/edges.dart';
import '../../translations/translations.dart';

final Map<String, dynamic> buttonActive = {
    'fontColor':        'base',
    'bgColor':          'primary',
    'fontSize':         16.0,
    'fontWeight':       FontWeight.w900,
    'borderWidth':      0.0,
    'borderColor':      'transparent',
    'borderRadius':     'pill',
    'letterSpacing':    1.8,
};

final Map<String, dynamic> buttonDisabled = {
    'fontColor':        'dark',
    'bgColor':          'placeholder',
    'fontSize':         16.0,
    'opacity':          0.5,
    'borderRadius':     'pill',
    'letterSpacing':    1.8,
};

ButtonStyle buildButtonStyle(Map<String, dynamic> style, bool isDark) {
  final theme = isDark ? darkThemeMap : lightThemeMap;

  Color? bg = theme[style['bgColor']];
  Color? fg = theme[style['fontColor']];
  Color? border = theme[style['borderColor']] ?? Colors.transparent;

  return ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(bg ?? Colors.transparent),
    foregroundColor: WidgetStatePropertyAll(fg ?? Colors.transparent),
    textStyle: WidgetStatePropertyAll(
      TextStyle(
        fontSize: style['fontSize'],
        fontWeight: style['fontWeight'],
        letterSpacing: style['letterSpacing'],
      ),
    ),
    overlayColor: WidgetStatePropertyAll(Colors.transparent),
    elevation: WidgetStatePropertyAll(0),
    side: WidgetStatePropertyAll(BorderSide(
      color: border,
      width: style['borderWidth'] ?? 0.0,
    )),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(
        borderRadius: appEdges(),
      ),
    ),
  );
}

Widget styledButton({
  required BuildContext context,
  required Map<String, dynamic> style,
  required VoidCallback? onPressed,
  String? textKey,
  Widget? child,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final locale = Localizations.localeOf(context).languageCode;

  final Widget resolvedChild = textKey != null
      ? Text(tr(textKey, locale))
      : (child ?? const SizedBox());

  final button = TextButton(
    style: buildButtonStyle(style, isDark),
    onPressed: onPressed,
    child: resolvedChild,
  );

  final buttonWithShadow = Container(
    decoration: BoxDecoration(
      boxShadow: [
        if ((style['opacity'] ?? 1) == 1)
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 22,
            spreadRadius: 2,
            offset: Offset(0, 0),
          ),
      ],
      borderRadius: appEdges(),
    ),
    child: button,
  );

  if (style['opacity'] != null) {
    return Opacity(
      opacity: style['opacity'],
      child: buttonWithShadow,
    );
  }

  return buttonWithShadow;
}


