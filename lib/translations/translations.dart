// Datei: translations\translations.dart
import 'en.dart';
import 'de.dart';

final Map<String, Map<String, String>> translations = {
    'en': en,
    'de': de,
};



String tr(String key, String locale) {
  final lang = locale.split('-').first;
  return translations[lang]?[key] ?? translations['en']?[key] ?? key;
}

void validateTranslations() {
  assert(() {
    final allLocales = translations.keys.toList();
    final baseLocale = allLocales.first;
    final baseMap = translations[baseLocale]!;

    for (final locale in allLocales) {
      final currentMap = translations[locale]!;

      for (final key in baseMap.keys) {
        if (!currentMap.containsKey(key)) {
          throw Exception("\x1B[31m❌ Missing key '$key' in locale \"$locale\"\x1B[0m");
        }
        if ((currentMap[key] ?? '').trim().isEmpty) {
          throw Exception("\x1B[31m❌ Empty value for key '$key' in locale \"$locale\"\x1B[0m");
        }
      }

      for (final key in currentMap.keys) {
        if (!baseMap.containsKey(key)) {
          throw Exception("\x1B[31m❌ Extra key '$key' in locale \"$locale\" (not in $baseLocale)\x1B[0m");
        }
      }
    }

    return true;
  }());
}
