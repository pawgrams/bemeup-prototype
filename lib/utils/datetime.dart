// Datei: utils\datetime.dart
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../context/timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

tz.TZDateTime _toLocalTz(int timestamp, BuildContext context) {
  final tzName = Provider.of<TimezoneProvider>(context, listen: false).timezone;
  tzdata.initializeTimeZones();
  final location = tz.getLocation(tzName ?? 'UTC');
  return tz.TZDateTime.fromMillisecondsSinceEpoch(location, timestamp);
}

String formatDateTime(int timestamp, BuildContext context) {
  final date = _toLocalTz(timestamp, context);
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat('dd MMM yyyy – HH:mm', locale).format(date);
}

String formatDateRange(int startTs, int endTs, BuildContext context) {
  final start = _toLocalTz(startTs, context);
  final end = _toLocalTz(endTs, context);
  final locale = Localizations.localeOf(context).languageCode;

  if (start.year == end.year &&
      start.month == end.month &&
      start.day == end.day) {
    return DateFormat('d MMM yyyy', locale).format(start);
  } else if (start.year == end.year && start.month == end.month) {
    return '${start.day}-${end.day} ${DateFormat('MMM yyyy', locale).format(end)}';
  } else if (start.year == end.year) {
    return '${start.day} ${DateFormat('MMM', locale).format(start)} - ${end.day} ${DateFormat('MMM yyyy', locale).format(end)}';
  } else {
    return '${start.day} ${DateFormat('MMM yy', locale).format(start)} - ${end.day} ${DateFormat('MMM yy', locale).format(end)}';
  }
}

String formatTimeOnly(int timestamp, BuildContext context) {
  final date = _toLocalTz(timestamp, context);
  final locale = Localizations.localeOf(context).languageCode;
  return DateFormat('HH:mm', locale).format(date);
}

String convertMidnightEndTM(String timestamp, BuildContext context) {
  return timestamp == '00:00' ? '23:59' : '00:00';
}


int convertMidnightEndDT(int timestamp, BuildContext context) {
  final original = _toLocalTz(timestamp, context);
  if (original.hour == 0 && original.minute == 0 && original.second == 0) {
    final prevDay = original.subtract(const Duration(days: 1));
    final corrected = tz.TZDateTime(
      prevDay.location,
      prevDay.year,
      prevDay.month,
      prevDay.day,
      23,
      59,
    );
    return corrected.millisecondsSinceEpoch;
  }
  return timestamp;
}



String shortTimeZone(String tzName) {
  tzdata.initializeTimeZones();
  final location = tz.getLocation(tzName);
  final now = tz.TZDateTime.now(location);
  return now.timeZoneName;
}
