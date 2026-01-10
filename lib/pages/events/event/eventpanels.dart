// Datei: pages/events/event/eventpanels.dart
import 'package:flutter/material.dart';
import '../../../../theme/dark.dart';
import '../../../../theme/light.dart';
import '../../../widgets/contents/fonts.dart';
import 'eventdetails.dart';
import '../../../widgets/styles/scrollbar.dart';

final Map<String, dynamic> eventPanelStyle = {
  'panelMargin': 10.0,
  'panelBorderRadius': 18.0,
  'panelColor': 'light',
  'panelOpacity': 0.3,
  'panelFontSize': 14.0,
  'panelFontWeight': FontWeight.bold,
  'panelLetterSpacing': 1.2,
  'panelFont': 'caption',
  'panelFontColor': 'contrast',
};

Color eventPanelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  if (key == 'panelColor') {
    return themeMap[eventPanelStyle[key]]!.withOpacity(eventPanelStyle['panelOpacity']);
  }
  return themeMap[eventPanelStyle[key]]!;
}

class EventPanels extends StatefulWidget {
  final Map<String, dynamic> event;
  final List<Map<String, dynamic>> stages;

  const EventPanels({super.key, required this.event, required this.stages});

  @override
  State<EventPanels> createState() => _EventPanelsState();
}

class _EventPanelsState extends State<EventPanels> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPanelTap(BuildContext context, String panel) {
    if (panel == "details") {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EventDetails(event: widget.event, stages: widget.stages),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget buildPanel(String text, String panelKey) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      final themeMap = isDark ? darkThemeMap : lightThemeMap;
      final String fontKey = eventPanelStyle['panelFont'];
      final double fontSize = eventPanelStyle['panelFontSize'];
      final fontStyle = appFonts[fontKey]!(fontSize).copyWith(
        color: themeMap[eventPanelStyle['panelFontColor']],
        fontWeight: eventPanelStyle['panelFontWeight'],
        letterSpacing: eventPanelStyle['panelLetterSpacing'],
      );

      return AspectRatio(
        aspectRatio: 1,
        child: GestureDetector(
          onTap: () => _onPanelTap(context, panelKey),
          child: Container(
            margin: EdgeInsets.all(eventPanelStyle['panelMargin']),
            decoration: BoxDecoration(
              color: eventPanelColor(context, 'panelColor'),
              borderRadius: BorderRadius.circular(eventPanelStyle['panelBorderRadius']),
            ),
            child: Center(
              child: Text(
                text.toUpperCase(),
                style: fontStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      );
    }

    return HoverScrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: buildPanel("Details", "details")),
                Expanded(child: buildPanel("Tickets", "tickets")),
              ],
            ),
            Row(
              children: [
                Expanded(child: buildPanel("Check In", "checkin")),
                Expanded(child: buildPanel("Credits", "credits")),
              ],
            ),
            Row(
              children: [
                Expanded(child: buildPanel("Media", "media")),
                Expanded(child: buildPanel("Placeholder", "placeholder")),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
