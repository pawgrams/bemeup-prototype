// Datei: pages/start.dart
import 'package:flutter/material.dart';
import 'pages/home/opportunities.dart';
import '../../../widgets/elements/sectioncaption.dart';
import 'pages/home/usershowcase.dart';
import 'package:firebase_database/firebase_database.dart';
import 'pages/home/songshowcase.dart';
import '../../context/dummy_logged_user.dart';
import 'pages/home/musicforyou.dart';
import '../../../widgets/elements/sections.dart';
import 'pages/home/homeSectionsTabs.dart';
import '../../widgets/player.dart';
import 'pages/home/greeting.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with AutomaticKeepAliveClientMixin {
  String? userOfDayId;
  List<Map<String, dynamic>> songsOfDay = [];
  List<Map<String, dynamic>> musicForYouSongs = [];
  bool _loadingUserOfDay = true;
  bool _loadingSongsOfDay = true;
  bool _loadingMusicForYou = true;

  int selectedSection = 0;
  bool _playerInitialized = false;

  List<String> get _sectionKeys => sectionMap.keys.toList();
  List<ProfileSectionsTabs> get _sectionButtonIcons =>
      _sectionKeys.map((k) => sectionIcons[k] ?? ProfileSectionsTabs(icon: Icons.help_outline)).toList();

  @override
  void initState() {
    super.initState();
    _loadUserOfTheDay();
    _loadSongsOfTheDay();
    _loadMusicForYouSongs();
  }

  Future<void> _loadUserOfTheDay() async {
    final snap = await FirebaseDatabase.instance.ref('charts_oftheday/user').get();
    if (!mounted) return;
    setState(() {
      userOfDayId = snap.exists && snap.value != null ? snap.value.toString() : null;
      _loadingUserOfDay = false;
    });
  }

  Future<void> _loadSongsOfTheDay() async {
    final snap = await FirebaseDatabase.instance.ref('charts_oftheday/songs').get();
    if (!mounted) return;
    List<String> songIds = [];
    if (snap.exists && snap.value != null) {
      if (snap.value is List) {
        songIds = List<String>.from(snap.value as List);
      } else {
        final map = Map<String, dynamic>.from(snap.value as Map);
        map.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty && !songIds.contains(value.toString())) {
            songIds.add(value.toString());
          }
        });
      }
    }

    List<Future<DataSnapshot>> futures = songIds.map((id) =>
      FirebaseDatabase.instance.ref('songs/$id').get()
    ).toList();
    final snaps = await Future.wait(futures);

    List<Map<String, dynamic>> songs = [];
    for (int i = 0; i < snaps.length; i++) {
      final songSnap = snaps[i];
      final id = songIds[i];
      if (songSnap.exists && songSnap.value != null) {
        final songData = Map<String, dynamic>.from(songSnap.value as Map);
        songData['uuid'] = id;
        if (!songData.containsKey('highlight')) songData['highlight'] = 0;
        if (!songData.containsKey('spotlight')) songData['spotlight'] = 1;
        songs.add(songData);
      }
    }

    if (!mounted) return;
    setState(() {
      songsOfDay = songs;
      _loadingSongsOfDay = false;
    });

    if (!_playerInitialized && songs.isNotEmpty) {
      _playerInitialized = true;
      PlayerController.instance.play(songs[0]['uuid'], songData: songs[0], shouldPlay: false);
    }
  }

  Future<void> _loadMusicForYouSongs() async {
    final userId = dummyLoggedUser;
    final snap = await FirebaseDatabase.instance.ref('charts_foryou/$userId').get();
    if (!mounted) return;
    List<String> songIds = [];
    if (snap.exists && snap.value != null) {
      if (snap.value is List) {
        songIds = List<String>.from(snap.value as List);
      } else {
        final map = Map<dynamic, dynamic>.from(snap.value as Map);
        map.forEach((key, value) {
          if (value != null && value.toString().isNotEmpty && !songIds.contains(value.toString())) {
            songIds.add(value.toString());
          }
        });
      }
    }

    List<Future<DataSnapshot>> futures = songIds.map((id) =>
      FirebaseDatabase.instance.ref('songs/$id').get()
    ).toList();
    final snaps = await Future.wait(futures);

    List<Map<String, dynamic>> songs = [];
    for (int i = 0; i < snaps.length; i++) {
      final songSnap = snaps[i];
      final id = songIds[i];
      if (songSnap.exists && songSnap.value != null) {
        final songData = Map<String, dynamic>.from(songSnap.value as Map);
        songData['uuid'] = id;
        if (!songData.containsKey('highlight')) songData['highlight'] = 0;
        if (!songData.containsKey('spotlight')) songData['spotlight'] = 1;
        songs.add(songData);
      }
    }
    if (!mounted) return;
    setState(() {
      musicForYouSongs = songs;
      _loadingMusicForYou = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget sectionContent;
    if (_sectionKeys[selectedSection] == 'hot') {
      sectionContent = Column(
        children: [
          GreetingWidget(userId: dummyLoggedUser),
          const SectionCaption(translationKey: 'opportunities', showTooltip: false),
          OpportunitiesList(),

          const SectionCaption(translationKey: 'tracks of the day', showTooltip: false),
          SizedBox(
            height: 110,
            child: _loadingSongsOfDay
                ? Center(child: CircularProgressIndicator())
                : (songsOfDay.isNotEmpty
                    ? SongShowCase(items: songsOfDay)
                    : SizedBox.shrink()),
          ),

          const SectionCaption(translationKey: 'music for you', showTooltip: false),
          SizedBox(
            height: 110,
            child: _loadingMusicForYou
                ? Center(child: CircularProgressIndicator())
                : (musicForYouSongs.isNotEmpty
                    ? MusicForYouPreview(
                        items: musicForYouSongs,
                        imagePath: 'music/cover/',
                        imageThumbPath: 'music/cover/thumb/',
                        fileType: 'jpg',
                        fallback: 'assets/defaults/cover.png',
                        fallbackThumb: 'assets/defaults/cover.png',
                        shape: 'square',
                        onTap: (item) {},
                      )
                    : SizedBox.shrink()),
          ),

          const SectionCaption(translationKey: 'user of the day', showTooltip: false),
          SizedBox(
            height: 110,
            child: _loadingUserOfDay
                ? Center(child: CircularProgressIndicator())
                : (userOfDayId != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
                        child: UserShowcase(userId: userOfDayId!, switchPanels: false),
                      )
                    : SizedBox.shrink()),
          ),

        ],
      );
    } else {
      sectionContent = SizedBox(height: 200, child: Center(child: Text("Kein Inhalt für diese Section", style: TextStyle(fontSize: 15))));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: Sections(
              icons: _sectionButtonIcons,
              labels: _sectionKeys,
              selectedIndex: selectedSection,
              onTap: (i) {
                if (!mounted) return;
                setState(() {
                  selectedSection = i;
                });
              },
            ),
          ),
          sectionContent,
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
