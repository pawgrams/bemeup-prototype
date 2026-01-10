// Datei: utils/muteconsole.dart
import 'package:flutter/foundation.dart' show kIsWeb, FlutterErrorDetails, FlutterError, debugPrint;
import 'dart:js_util' as js_util;
import 'dart:js' as js;

void muteConsole() {
  if (!kIsWeb) return;
  debugPrint = (String? message, {int? wrapWidth}) {};
  FlutterError.onError = (FlutterErrorDetails details) {};
  try {
    final console = js.context['console'];
    if (console != null) {
      js_util.setProperty(console, 'log', js.allowInterop((dynamic _a, [dynamic _b, dynamic _c, dynamic _d, dynamic _e]) {}));
      js_util.setProperty(console, 'info', js.allowInterop((dynamic _a, [dynamic _b, dynamic _c, dynamic _d, dynamic _e]) {}));
      js_util.setProperty(console, 'warn', js.allowInterop((dynamic _a, [dynamic _b, dynamic _c, dynamic _d, dynamic _e]) {}));
      js_util.setProperty(console, 'error', js.allowInterop((dynamic _a, [dynamic _b, dynamic _c, dynamic _d, dynamic _e]) {}));
    }
    js.context.callMethod('addEventListener', [
      'unhandledrejection',
      js.allowInterop((dynamic e) { try { e?.preventDefault(); } catch (_) {} })
    ]);
    js.context['onerror'] = js.allowInterop((dynamic _m, dynamic _s, dynamic _l, dynamic _c, dynamic _e) { return true; });
  } catch (_) {}
}
