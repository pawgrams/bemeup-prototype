// Datei: pages/song/song.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'songheader.dart';
import '../../widgets/elements/sections.dart';
import '../../widgets/elements/sectioncaption.dart';
import '../../widgets/elements/tabs.dart';
import '../../layout.dart';
import 'songSectionsTabs.dart' as songContent;
import 'getComments.dart';
import 'getLikes.dart';
import 'showLyrics.dart';

class SongPage extends StatefulWidget {
  final String songId;
  final String visitorUserId;

  const SongPage({
    super.key,
    required this.songId,
    required this.visitorUserId,
  });

  @override
  State<SongPage> createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  Map<String, dynamic>? songData;
  bool _ready = false;
  int selectedSection = 0;
  int selectedTab = 0;

  List<String> get _sectionKeys => songContent.sectionMap.keys.toList();
  List<songContent.SongSectionsTabs> get _sectionTabs =>
      _sectionKeys.map((k) => songContent.sectionIcons[k] ?? songContent.SongSectionsTabs(icon: Icons.help_outline)).toList();

  List<String> get _tabKeys => songContent.sectionMap[_sectionKeys[selectedSection]] ?? [];
  List<songContent.SongSectionsTabs> get _tabTabs =>
      _tabKeys.map((k) => songContent.itemIcons[k] ?? songContent.SongSectionsTabs(icon: Icons.help_outline)).toList();

  String get _activeTabKey =>
      _tabKeys.isNotEmpty && selectedTab < _tabKeys.length ? _tabKeys[selectedTab] : '';

  @override
  void initState() {
    super.initState();
    _loadSong();
  }

  @override
  void didUpdateWidget(SongPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId) {
      if (!mounted) return;
      setState(() {
        songData = null;
        _ready = false;
      });
      _loadSong();
    }
  }

  Future<void> _loadSong() async {
    if (!mounted) return;
    setState(() {
      songData = null;
      _ready = false;
    });
    final snap = await FirebaseDatabase.instance.ref('songs/${widget.songId}').get();
    if (!mounted) return;
    setState(() {
      songData = snap.exists && snap.value != null
          ? Map<String, dynamic>.from(snap.value as Map)
          : {};
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || songData == null) return const Center(child: CircularProgressIndicator());

    final String customImagePath = 'music/cover/${widget.songId}.jpg';

    Widget tabContent;
    if (_sectionKeys[selectedSection] == 'info' && _activeTabKey == 'comments') {
      tabContent = GetCommentsList(songId: widget.songId);
    } else if (_sectionKeys[selectedSection] == 'info' && _activeTabKey == 'likes') {
      tabContent = GetLikesList(songId: widget.songId);
    } else if (_sectionKeys[selectedSection] == 'info' && _activeTabKey == 'lyrics') {
      tabContent = ShowLyrics(songId: widget.songId);
    } else {
      tabContent = const Center(child: Text('Song content here'));
    }

    int? _getAmount() {
      if (_activeTabKey == 'comments' && songData!["comments"] is int) return songData!["comments"];
      if (_activeTabKey == 'likes' && songData!["likes"] is int) return songData!["likes"];
      return null;
    }

    return AppLayout(
      pageTitle: 'song',
      customImagePath: customImagePath,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                child: Sections(
                  icons: _sectionTabs,
                  labels: _sectionKeys,
                  selectedIndex: selectedSection,
                  onTap: (i) {
                    if (!mounted) return;
                    setState(() {
                      selectedSection = i;
                      selectedTab = 0;
                    });
                  },
                ),
              ),
              SectionCaption(
                translationKey: _sectionKeys[selectedSection],
              ),
              SongHeader(
                key: ValueKey(widget.songId),
                songId: widget.songId,
                songData: songData ?? {},
                visitorUserId: widget.visitorUserId,
              ),
              SizedBox(
                width: double.infinity,
                child: Tabs(
                  icons: _tabTabs,
                  selectedIndex: selectedTab,
                  onTap: (i) {
                    if (!mounted) return;
                    setState(() => selectedTab = i);
                  },
                ),
              ),

              SectionCaption(
                translationKey: _activeTabKey,
                amount: _getAmount(),
              ),
              SizedBox(
                width: double.infinity,
                height: 440,
                child: tabContent,
              ),
            ],
          );
        },
      ),
    );
  }
}
