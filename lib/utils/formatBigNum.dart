// Datei: utils\formatBigNum.dart
String formatNumber(int n) {
  if (n >= 1000000) {
    return "${(n / 1000000).toStringAsFixed(1)}Mio";
  }
  if (n >= 1000) {
    return "${(n / 1000).toStringAsFixed(1)}K";
  }
  return n.toString();
}
