// Datei: pages/events/event/lineupnow.dart
Map<String, dynamic>? getCurrentLineup(Map stage) {
  final agenda = stage['agenda'];
  if (agenda == null || agenda is! Map) return null;

  final now = DateTime.now().millisecondsSinceEpoch;
  final keys = agenda.keys
      .where((k) => int.tryParse(k.toString()) != null)
      .map((k) => int.parse(k.toString()))
      .toList()
    ..sort();

  for (var i = 0; i < keys.length; i++) {
    final start = keys[i];
    final end = (i + 1 < keys.length)
        ? keys[i + 1]
        : (stage['end'] is int ? stage['end'] : null);

    if (start <= now && (end == null || now < end)) {
      return {
        'start': start,
        'end': end,
      };
    }
  }
  return null;
}
