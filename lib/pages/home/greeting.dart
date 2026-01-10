// Datei: pages\home\greeting.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../widgets/contents/fonts.dart';

final Map<String, dynamic> greetingStyle = {
  'containerHeight': 70.0,
  'containerRadius': 0.0,
  'containerColor': 'base',
  'containerOpacity': 0.3,
  'paddingH': 14.0,
  'paddingV': 2.0,
  'greetingFontSize': 16.0,
  'greetingFontWeight': FontWeight.w700,
  'greetingFont': 'caption',
  'greetingColor': 'primary',
  'nameFontWeight': FontWeight.w700,
  'line2FontSize': 12.0,
  'line2FontWeight': FontWeight.w600,
  'line2Color': 'contrast',
};

Color greetingColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[greetingStyle[key]]!;
}

TextStyle buildGreetingTextStyle(BuildContext context) {
  final fontFn = appFonts[greetingStyle['greetingFont']] ?? textFont;
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final theme = isDark ? darkThemeMap : lightThemeMap;
  return fontFn(greetingStyle['greetingFontSize']).copyWith(
    color: theme[greetingStyle['greetingColor']],
    fontWeight: greetingStyle['greetingFontWeight'],
  );
}

class GreetingWidget extends StatefulWidget {
  final String userId;
  const GreetingWidget({super.key, required this.userId});

  @override
  State<GreetingWidget> createState() => _GreetingWidgetState();
}

class _GreetingWidgetState extends State<GreetingWidget> {
  String greetingWord = '';
  String userName = '';
  String line2 = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadGreeting();
  }

  Future<void> _loadGreeting() async {
    final greetingSnap = await FirebaseDatabase.instance.ref('greeting').get();
    final userSnap = await FirebaseDatabase.instance.ref('users/${widget.userId}/name').get();

    String greeting = '';
    String name = '';
    String l2 = '';

    if (greetingSnap.exists && greetingSnap.value is Map) {
      final Map val = greetingSnap.value as Map;
      greeting = (val['line1'] ?? '').toString();
      l2 = (val['line2'] ?? '').toString();
    }
    if (userSnap.exists && userSnap.value != null) {
      name = userSnap.value.toString();
    }

    if (!mounted) return;
    setState(() {
      greetingWord = greeting;
      userName = name;
      line2 = l2;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: greetingStyle['containerHeight'],
        child: Center(child: CircularProgressIndicator()),
      );
    }
    return Container(
      height: greetingStyle['containerHeight'],
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: greetingStyle['paddingH'],
        vertical: greetingStyle['paddingV'],
      ),
      decoration: BoxDecoration(
        color: greetingColor(context, 'containerColor').withOpacity(greetingStyle['containerOpacity']),
        borderRadius: BorderRadius.circular(greetingStyle['containerRadius']),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  '${greetingWord.isNotEmpty ? greetingWord : ''} ${userName.isNotEmpty ? userName : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: buildGreetingTextStyle(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            line2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: greetingStyle['line2FontSize'],
              fontWeight: greetingStyle['line2FontWeight'],
              color: greetingColor(context, 'line2Color'),
            ),
          ),
        ],
      ),
    );
  }
}
