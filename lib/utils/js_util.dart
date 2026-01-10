// Datei: utils\js_util.dart
import 'dart:js_util' as js_util;

Future<String> getBrowserTimezone() async {
  final intl = js_util.getProperty(js_util.globalThis, 'Intl');
  final dtf = js_util.callMethod(intl, 'DateTimeFormat', []);
  final options = js_util.callMethod(dtf, 'resolvedOptions', []);
  return js_util.getProperty(options, 'timeZone');
}
