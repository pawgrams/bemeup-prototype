// Datei: utils/timeleft.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

String formatTimeLeft(int endTimestampMs) {
  final now = DateTime.now().millisecondsSinceEpoch;
  double diffSec = max(0, (endTimestampMs - now) / 1000);

  if (diffSec < 60) return '<1min';
  if (diffSec < 3600) return '${diffSec ~/ 60}min';
  if (diffSec < 86400) {
    double hours = diffSec / 3600;
    return hours % 1 == 0
        ? '${hours.toInt()}h'
        : '${hours.toStringAsFixed(1)}h';
  }
  if (diffSec < 31536000) {
    double days = diffSec / 86400;
    int intDays = days.floor();
    return days == intDays
        ? '${intDays} day${intDays == 1 ? '' : 's'}'
        : '${intDays} day${intDays == 1 ? '' : 's'}';
  }
  double years = diffSec / 31536000;
  return years % 1 == 0
      ? '${years.toInt()}y'
      : '${years.toStringAsFixed(1)}y';
}

class TimeLeftText extends StatefulWidget {
  final int timestampMs;
  final TextStyle? style;

  const TimeLeftText({
    super.key,
    required this.timestampMs,
    this.style,
  });

  @override
  State<TimeLeftText> createState() => _TimeLeftTextState();
}

class _TimeLeftTextState extends State<TimeLeftText> {
  late Timer _timer;
  String _timeLeft = '';

  Duration _nextTick() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final leftSec = max(0, (widget.timestampMs - now) / 1000);

    if (leftSec < 60) return const Duration(seconds: 5);
    if (leftSec < 3600) return const Duration(seconds: 30);
    if (leftSec < 86400) return const Duration(minutes: 1);
    if (leftSec < 31536000) return const Duration(hours: 1);
    return const Duration(days: 1);
  }

  void _update() {
    if (!mounted) return;
    setState(() => _timeLeft = formatTimeLeft(widget.timestampMs));
    _timer.cancel();
    _timer = Timer(_nextTick(), _update);
  }

  @override
  void initState() {
    super.initState();
    _timeLeft = formatTimeLeft(widget.timestampMs);
    _timer = Timer(_nextTick(), _update);
  }

  @override
  void didUpdateWidget(TimeLeftText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.timestampMs != widget.timestampMs) {
      _timer.cancel();
      _update();
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(_timeLeft, style: widget.style);
  }
}
