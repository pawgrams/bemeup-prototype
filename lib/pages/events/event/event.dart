// Datei: pages/events/event/event.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'spotlight.dart';
import '../../../widgets/elements/sectioncaption.dart';
import '../../../widgets/sectionhead.dart';
import '../../../layout.dart';
import '../../../utils/datetime.dart';
import 'eventpanels.dart';

class Event extends StatefulWidget {
  final Map<String, dynamic> event;
  const Event({super.key, required this.event});

  @override
  State<Event> createState() => _EventState();
}

class _EventState extends State<Event> with AutomaticKeepAliveClientMixin {
  bool _ready = false;
  List<Map<String, dynamic>> _stageData = [];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadStages();
  }

Future<void> _loadStages() async {
  final rawStages = widget.event['stages'];
  final ids = rawStages is List
      ? List<String>.from(rawStages)
      : (rawStages as Map).values.map((e) => e.toString()).toList();

  final snap = await FirebaseDatabase.instance.ref('stages').get();
  if (snap.exists && snap.value != null) {
    final stagesMap = Map<String, dynamic>.from(snap.value as Map);
    final result = <Map<String, dynamic>>[];
    for (final id in ids) {
      if (stagesMap.containsKey(id)) {
        final data = Map<String, dynamic>.from(stagesMap[id]);
        data['uuid'] = id;
        result.add(data);
      }
    }
    if (!mounted) return;
      setState(() {
        _stageData = result;
        _ready = true;
      });
  }
}

void _openRanking(Map<String, dynamic> stage) {
  Navigator.pushNamed(
    context,
    '/ranking',
    arguments: {
      'stage': stage,
      'event': widget.event,
    },
  );
}

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (!_ready) {
      return const AppLayout(
        pageTitle: 'event',
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final stagesList = _stageData.map((stage) => {
      ...stage,
      'highlight': 0,
      'spotlight': 1,
    }).toList();

    final String? eventUuid = widget.event['uuid']?.toString();
    final String? customImagePath =
        (eventUuid != null && eventUuid.isNotEmpty)
            ? '/events/9-16/$eventUuid.jpg'
            : null;

    return AppLayout(
      key: const PageStorageKey('event_page'),
      pageTitle: 'event',
      customImagePath: customImagePath,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHead(
              line1Texts: [widget.event['name'], widget.event["country"].toUpperCase()],
              line1Styles: ['line1Large', 'line1Small'],
              line2Texts: [
                formatDateRange(widget.event['start'], widget.event['end'], context),
                '@',
                widget.event['venue'] + ', ' + widget.event["city"]
              ],
              line2Styles: ['line2Large', 'line2At', 'line2Small'],
            ),
            const SectionCaption(translationKey: 'stages'),
            Spotlight(
              items: stagesList,
              imagePath: 'stages/thumb/',
              imageThumbPath: 'stages/thumb/',
              fileType: 'jpg',
              fallback: 'assets/defaults/cover.png',
              fallbackThumb: 'assets/defaults/cover_thumb.png',
              shape: 'sphere',
              onTap: (item) => _openRanking(item),
            ),
            const SectionCaption(translationKey: 'menu'),
            const SizedBox(height: 6),
            SizedBox(
              height: 458,
              child: EventPanels(event: widget.event, stages: _stageData),
            ),
          ],
        ),
      ),
    );
  }
}
