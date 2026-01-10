// Datei: pages/events/event/eventdetails.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../layout.dart';
import '../../../widgets/elements/fieldtitles.dart';
import '../../../widgets/elements/textfield.dart';
import '../../../widgets/elements/accordion.dart';
import '../../../utils/datetime.dart';
import 'package:provider/provider.dart';
import '../../../context/timezone.dart';

class EventDetails extends StatefulWidget {
  final Map<String, dynamic> event;
  final List<Map<String, dynamic>> stages;
  
  const EventDetails({super.key, required this.event, required this.stages});

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  void launchUrlIfPossible(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {

    super.build(context);
    final tzName = Provider.of<TimezoneProvider>(context, listen: false).timezone ?? 'UTC';
    final tzAbbr = shortTimeZone(tzName);
    final int _start = convertMidnightEndDT(widget.event['start'] ?? 0, context);
    final int _end = convertMidnightEndDT(widget.event['end'] ?? 0, context);
    final stageSections = widget.stages.map((stage) {
    final Map<String, dynamic> flatMap = {};

      if (stage['start'] != null) flatMap['start'] = formatDateTime(stage['start'], context);
      if (stage['end'] != null) flatMap['end'] = formatDateTime(stage['end'], context);
      if (stage['description'] != null) flatMap['description'] = stage['description'];
      if (stage['genres'] != null) flatMap['genres'] = stage['genres'];

      flatMap['agenda'] = '';

      final agenda = (stage['agenda'] as Map?) ?? {};
      final sortedKeys = agenda.keys.toList()
        ..sort((a, b) => int.parse(a.toString()).compareTo(int.parse(b.toString())));

      for (final key in sortedKeys) {
        final ts = int.tryParse(key.toString());
        final label = ts != null ? formatTimeOnly(ts, context) : key.toString();
        final val = agenda[key];

        if (val is Map && val['name'] != null) {
          flatMap[label] = val['name'];
        }
      }

      return AccordionSection(
        title: stage['name'] ?? 'Stage',
        content: flatMap,
      );
    }).toList();

    return AppLayout(
      pageTitle: 'eventdetails',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'eventname',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            styledTextField(
              context: context,
              text: widget.event['name'] ?? '',
            ),
            SizedBox(height: 12),
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'start',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            styledTextField(
              context: context,
              text: formatDateTime(_start, context) + ' ($tzAbbr)',
            ),
            SizedBox(height: 12),
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'end',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            styledTextField(
              context: context,
              text: formatDateTime(_end, context) + ' ($tzAbbr)',
            ),
            SizedBox(height: 12),
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'venue',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            styledTextField(
              context: context,
              text: widget.event['venue'] ?? '',
            ),
            SizedBox(height: 12),
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'address',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            styledTextField(
              context: context,
              text: widget.event['address'] ?? '',
            ),
            SizedBox(height: 12),
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'tickets',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            GestureDetector(
              onTap: () {
                final url = widget.event['tickets'];
                if (url != null) launchUrlIfPossible(url);
              },
              child: AbsorbPointer(
                child: styledTextField(
                  context: context,
                  text: widget.event['tickets'] ?? '',
                ),
              ),
            ),
            SizedBox(height: 12),
            styledFieldTitleWithTooltip(
              context: context,
              textKey: 'eventdescription',
              spaceBelow: 0,
              useTextShadow: false,
            ),
            styledTextField(
              context: context,
              text: widget.event['description'] ?? '',
            ),
            SizedBox(height: 12),
            if (widget.stages.isNotEmpty) ...[
              SizedBox(height: 12),
              styledFieldTitleWithTooltip(
                context: context,
                textKey: 'stages',
                useTextShadow: false,
              ),
              Accordion(
                sections: stageSections,
                useTextShadow: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
