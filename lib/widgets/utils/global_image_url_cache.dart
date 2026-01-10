// Datei: widgets/utils/global_image_url_cache.dart
class GlobalImageUrlCache {
  static final Map<String, String> _urlCache = {};
  static String? get(String key) => _urlCache[key];
  static void set(String key, String value) => _urlCache[key] = value;
}
