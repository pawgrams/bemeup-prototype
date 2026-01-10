// Datei: pages/events/events.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'eventslist.dart';
import '../../../widgets/elements/sectioncaption.dart';
import 'event/spotlight.dart';
import 'event/event.dart';
import '../../../widgets/sectionhead.dart';

class Events extends StatefulWidget {
  const Events({super.key});

  @override
  State<Events> createState() => _EventsState();
}

class _EventsState extends State<Events> with AutomaticKeepAliveClientMixin {
  List<Map<String, dynamic>> _events = [];
  bool _ready = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final statiSnap = await FirebaseDatabase.instance.ref('eventstati/upcoming').get();
    if (!statiSnap.exists) return;
    final eventIds = (statiSnap.value as Map).keys;
    final result = <Map<String, dynamic>>[];

    for (final id in eventIds) {
      final snap = await FirebaseDatabase.instance.ref('events/$id').get();
      if (snap.exists) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        data['uuid'] = id;
        result.add(data);
      }
    }
    if (_disposed || !mounted) return;
      setState(() {
        _events = result;
        _ready = true;
      });
  }

  void _openEvent(BuildContext context, Map<String, dynamic> event) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => Event(event: event),
        transitionDuration: const Duration(milliseconds: 120),
        reverseTransitionDuration: const Duration(milliseconds: 90),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_ready) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [

        SectionHead(
          line1Texts: ['Filter'],
          line1Styles: ['line1Large'],
          line2Texts: ['Placeholder'],
          line2Styles: ['line2Large'],
        ),

        const SectionCaption(translationKey: 'spotlight'),
        Spotlight(
          items: _events,
          imagePath: 'events/thumb/',
          imageThumbPath: 'events/thumb/',
          fileType: 'jpg',
          fallback: 'assets/defaults/cover.png',
          fallbackThumb: 'assets/defaults/cover_thumb.png',
          shape: 'sphere',
          onTap: (event) => _openEvent(context, event),
        ),
        const SectionCaption(translationKey: 'events'),
        SizedBox(
          height: 458,
          child: EventsList(
            events: _events,
            shape: 'sphere',
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
