// Datei: pages/song/showLyrics.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/styles/scrollbar.dart';

final Map<String, dynamic> lyricsStyle = {
  'screenPadH': 16.0,
  'containerPadH': 12.0,
  'containerPadV': 12.0,
  'containerRadius': 12.0,
  'containerOpacity': 0.3,
  'containerBackgroundColor': 'base',
  'bgBehindColor': 'dark',
  'bgBehindOpacity': 0.1,
  'textColor': 'contrast',
  'fontSize': 15.0,
  'lineHeight': 1.2,
};

Color lyricsColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[lyricsStyle[key]]!;
}

class ShowLyrics extends StatefulWidget {
  final String songId;
  const ShowLyrics({super.key, required this.songId});

  @override
  State<ShowLyrics> createState() => _ShowLyricsState();
}

class _ShowLyricsState extends State<ShowLyrics> {
  String? lyrics;
  bool _ready = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadLyrics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadLyrics() async {
    try {
      final ref = FirebaseStorage.instance.ref('music/lyrics/${widget.songId}.txt');
      final url = await ref.getDownloadURL();
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          lyrics = res.body;
          _ready = true;
        });
      } else {
        if (!mounted) return;
        setState(() {
          lyrics = null;
          _ready = true;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        lyrics = null;
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());
    if (lyrics == null || lyrics!.isEmpty) return const Center(child: Text("No lyrics found."));

    return HoverScrollbar(
      controller: _scrollController,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: lyricsStyle['screenPadH']),
        child: Column(
          children: [
            SizedBox(height: lyricsStyle['containerPadV']),
            Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: lyricsColor(context, 'bgBehindColor')
                          .withOpacity(lyricsStyle['bgBehindOpacity']),
                      borderRadius: BorderRadius.circular(lyricsStyle['containerRadius']),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: lyricsStyle['containerPadH'],
                    vertical: lyricsStyle['containerPadV'],
                  ),
                  decoration: BoxDecoration(
                    color: lyricsColor(context, 'containerBackgroundColor')
                        .withOpacity(lyricsStyle['containerOpacity']),
                    borderRadius: BorderRadius.circular(lyricsStyle['containerRadius']),
                  ),
                  child: Text(
                    lyrics!,
                    style: TextStyle(
                      fontSize: lyricsStyle['fontSize'],
                      color: lyricsColor(context, 'textColor'),
                      height: lyricsStyle['lineHeight'],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: lyricsStyle['containerPadV'] + 100),
          ],
        ),
      ),
    );
  }
}
