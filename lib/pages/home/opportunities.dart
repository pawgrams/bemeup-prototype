// Datei: pages\home\opportunities.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../theme/dark.dart';
import '../../../../theme/light.dart';
import 'calltoactionbutton.dart';

final Map<String, dynamic> oppStyle = {
  'containerPadH': 12.0,
  'containerPadV': 6.0,
  'titleFontSize': 12.0,
  'titleFontWeight': FontWeight.w900,
  'fallbackBg': 'assets/defaults/cover.png',
  'vGap': 0.0,
};

Color oppColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.blue;
}

class OpportunitiesList extends StatefulWidget {
  const OpportunitiesList({super.key});
  @override
  State<OpportunitiesList> createState() => _OpportunitiesListState();
}

class _OpportunitiesListState extends State<OpportunitiesList> {
  List<Map<String, dynamic>> opportunities = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunities();
  }

  Future<void> _loadOpportunities() async {
    final snap = await FirebaseDatabase.instance.ref('opportunities').get();
    List<String> latestUuids = [];
    final List<Map<String, dynamic>> data = [];
    if (snap.exists && snap.value != null && snap.value is Map) {
      final Map v = snap.value as Map;
      if (v['-latest'] is List) {
        latestUuids = List<String>.from(v['-latest'].whereType<String>());
      } else if (v['-latest'] is Map) {
        final Map latestMap = v['-latest'];
        latestUuids = latestMap.values.whereType<String>().toList();
      }
      for (final uuid in latestUuids) {
        if (v[uuid] is Map) {
          final map = Map<String, dynamic>.from(v[uuid]);
          map['uuid'] = uuid;
          data.add(map);
        }
      }
    }
    if (!mounted) return;
    setState(() {
      opportunities = data;
      loading = false;
    });
  }

  void _onTap(Map<String, dynamic> opp) {}
  void _onCtaTap(Map<String, dynamic> opp) {}

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (opportunities.isEmpty) return const SizedBox.shrink();
    return Column(
      children: List.generate(opportunities.length * 2 - 1, (i) {
        if (i.isOdd) {
          return SizedBox(height: oppStyle['vGap']);
        }
        final idx = i ~/ 2;
        final opp = opportunities[idx];
        final bgKey = idx.isEven ? 'base' : 'base';
        final titleKey = idx.isEven ? 'primary' : 'primary';
        //final uuid = opp['uuid'] ?? ''; // required later for db call
        final isBlackBg = bgKey == 'base';

        final btnBg = isBlackBg ? oppColor(context, 'primary') : Colors.white;
        final btnText = isBlackBg ? Colors.black : oppColor(context, 'primary');

        return GestureDetector(
          onTap: () => _onTap(opp),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(),
            child: Stack(
              children: [
                Container(
                  color: oppColor(context, bgKey).withOpacity(0.5),
                  padding: EdgeInsets.symmetric(
                    vertical: oppStyle['containerPadV'],
                    horizontal: oppStyle['containerPadH'],
                  ),
                  child: Row(
                    children: [
                      Text(
                        (opp['emoji'] ?? '').toString(),
                        style: TextStyle(
                          fontSize: oppStyle['titleFontSize'] + 2,
                          shadows: [
                            Shadow(
                              color: isBlackBg ? Colors.black.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                              blurRadius: 2,
                              offset: Offset(0, 1.2),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opp['title'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: oppStyle['titleFontSize'],
                            fontWeight: oppStyle['titleFontWeight'],
                            color: oppColor(context, titleKey),
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                      CTAButton(
                        onPressed: () => _onCtaTap(opp),
                        label: opp['cta'] ?? '',
                        bgColor: btnBg.withOpacity(1.0),
                        textColor: btnText,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
