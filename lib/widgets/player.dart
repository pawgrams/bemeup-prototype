// Datei: widgets/player.dart
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:just_audio/just_audio.dart';
import '../theme/dark.dart';
import '../theme/light.dart';
import 'playertext.dart';
import 'waveform.dart';
import 'minipopup.dart';

final Map<String, dynamic> playerStyle = {
  'containerMarginBottom': 56.0,
  'containerPaddingH': 12.0,
  'containerPaddingV': 8.0,
  'containerRadius': 0.0,
  'containerColor': 'base',
  'containerOpacity': 0.8,
  'containerBoxShadowColor': 'base',
  'containerBoxShadowOpacity': 0.20,
  'containerBoxShadowBlur': 6.0,
  'containerBoxShadowOffset': Offset(0, -2),
  'containerHeight': 86.0,
  'iconColor': 'contrast',
  'iconPlaySize': 30.0,
  'iconExpandSize': 28.0,
  'iconCollapseSize': 28.0,
  'fabSize': 48,
  'fabBottom': 66.0,
  'fabShape': CircleBorder(),
  'fabIcon': Icons.keyboard_arrow_up,
  'fabBackgroundColor': 'base',
  'playPauseIconColor': 'contrast',
  'playPauseBackgroundColor': Colors.transparent,
  'mainArtistLeftOverflowPadding': 12.0,
};

Color playerColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[playerStyle[key]]!;
}

class PlayerController extends ChangeNotifier {
  static final PlayerController instance = PlayerController._internal();
  factory PlayerController() => instance;
  PlayerController._internal();

  String? currentSongUuid;
  Map<String, dynamic>? currentSongData;
  AudioPlayer? player;
  bool expanded = true;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  List<Map<String, String>>? artistObjs;
  bool artistsLoaded = false;
  bool allLoaded = false;

  Future<bool> play(String songUuid, {Map<String, dynamic>? songData, bool shouldPlay = true}) async {
    if (currentSongUuid == songUuid && player != null) {
      if (shouldPlay == false) {
        notifyListeners();
        return true;
      }
      if (player!.playing) {
        player!.pause();
      } else {
        player!.play();
      }
      notifyListeners();
      return true;
    }

    String url;
    try {
      url = await FirebaseStorage.instance.ref('music/mp3/$songUuid.mp3').getDownloadURL();
    } catch (_) {
      showMiniPopup('❌ Audio not available in player. No license, yet.');
      return false;
    }

    await stop();
    currentSongUuid = songUuid;
    currentSongData = songData;
    player = AudioPlayer();
    artistsLoaded = false;
    allLoaded = false;

    player!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        player!.pause();
        player!.seek(Duration.zero);
        notifyListeners();
      } else {
        notifyListeners();
      }
    });
    player!.positionStream.listen((pos) { currentPosition = pos; notifyListeners(); });
    player!.durationStream.listen((dur) { if (dur != null) { totalDuration = dur; notifyListeners(); }});

    try {
      await player!.setUrl(url);
    } catch (_) {
      return false;
    }

    await Future.wait([
      _loadSongData(),
      _loadArtists(),
    ]);
    allLoaded = true;
    notifyListeners();

    if (shouldPlay) {
      await player!.play();
    }
    return true;
  }

  Future<void> stop() async {
    await player?.stop();
    await player?.dispose();
    player = null;
    currentPosition = Duration.zero;
    totalDuration = Duration.zero;
    artistObjs = null;
    artistsLoaded = false;
    allLoaded = false;
    notifyListeners();
  }

  void togglePlayPause() {
    if (player == null) return;
    if (player!.playing) {
      player!.pause();
    } else {
      player!.play();
    }
    notifyListeners();
  }

  void seek(Duration pos) {
    player?.seek(pos);
  }

  void toggleExpand() {
    expanded = !expanded;
    notifyListeners();
  }

  Future<void> _loadSongData() async {
    if (currentSongData != null) return;
    final snap = await FirebaseDatabase.instance.ref('songs/$currentSongUuid').get();
    if (snap.exists && snap.value != null) {
      currentSongData = Map<String, dynamic>.from(snap.value as Map);
    }
  }

  List<String> _safeList(dynamic v) {
    if (v == null) return [];
    if (v is List<String>) return v;
    if (v is List) return v.map((e) => e?.toString() ?? '').toList();
    return [];
  }

  Future<void> _loadArtists() async {
    final song = currentSongData ?? {};
    Set<String> artistUuids = {};
    if (song['user'] != null && song['user'].toString().isNotEmpty) artistUuids.add(song['user'].toString());
    List<String> remixer = _safeList(song['remixer']);
    List<String> featured = _safeList(song['featured']);
    artistUuids.addAll(remixer);
    artistUuids.addAll(featured);

    List<Future<Map<String, String>?>> futures = artistUuids.map((uuid) async {
      if (uuid.isEmpty) return null;
      final userSnap = await FirebaseDatabase.instance.ref('users/$uuid').get();
      if (userSnap.exists && userSnap.value != null) {
        final user = Map<String, dynamic>.from(userSnap.value as Map);
        return {
          'uuid': uuid,
          'name': user['name']?.toString() ?? '',
        };
      }
      return null;
    }).toList();

    final results = await Future.wait(futures);
    Map<String, Map<String, String>> artistMap = {};
    for (var artist in results) {
      if (artist != null && artist['uuid'] != null) artistMap[artist['uuid']!] = artist;
    }

    Set<String> added = {};
    List<Map<String, String>> objs = [];
    if (song['user'] != null && artistMap.containsKey(song['user'].toString())) {
      added.add(song['user'].toString());
      objs.add(artistMap[song['user'].toString()]!);
    }
    for (final uuid in remixer) {
      if (!added.contains(uuid) && artistMap.containsKey(uuid)) {
        added.add(uuid);
        objs.add(artistMap[uuid]!);
      }
    }
    for (final uuid in featured) {
      if (!added.contains(uuid) && artistMap.containsKey(uuid)) {
        added.add(uuid);
        objs.add(artistMap[uuid]!);
      }
    }
    artistObjs = objs;
    artistsLoaded = true;
    notifyListeners();
  }
}

class PlayerWidget extends StatefulWidget {
  final String? visitorUserId;
  const PlayerWidget({super.key, this.visitorUserId});
  @override
  State<PlayerWidget> createState() => _PlayerWidgetState();
}

class _PlayerWidgetState extends State<PlayerWidget> {
  String? waveformSvgUrl;
  String? waveformSvgAsset;
  bool waveformTriedFirebase = false;
  String? lastSongUuid;

  @override
  void initState() {
    super.initState();
    PlayerController.instance.addListener(_onUpdate);
    _loadWaveform();
  }

  @override
  void dispose() {
    PlayerController.instance.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (!mounted) return;
    setState(() {});
    _loadWaveform();
  }

  Future<void> _loadWaveform() async {
    final pc = PlayerController.instance;
    final uuid = pc.currentSongUuid;
    if (uuid == null || uuid == lastSongUuid) return;
    lastSongUuid = uuid;
    waveformSvgUrl = null;
    waveformSvgAsset = null;
    waveformTriedFirebase = false;
    if (!mounted) return;
    setState(() {});
    try {
      String url = await FirebaseStorage.instance.ref('music/waveforms/$uuid.svg').getDownloadURL();
      waveformSvgUrl = url;
      waveformTriedFirebase = true;
      if (!mounted) return;
      setState(() {});
    } catch (_) {
      waveformSvgAsset = 'assets/defaults/waveform.svg';
      if (!mounted) return;
      setState(() {});
    }
  }

  Future<bool> tryPlaySong(String songUuid, {Map<String, dynamic>? songData, bool shouldPlay = true}) async {
    final success = await PlayerController.instance.play(songUuid, songData: songData, shouldPlay: shouldPlay);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('❌ Audio not available in player. No License, yet.'),
          backgroundColor: Colors.black.withOpacity(0.85),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
    return success;
  }

  @override
  Widget build(BuildContext context) {
    final pc = PlayerController.instance;
    List<Widget> stackChildren = [];

    if (pc.currentSongUuid == null) return const SizedBox.shrink();
    if (!pc.allLoaded) {
      stackChildren.add(
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            margin: EdgeInsets.only(
              bottom: playerStyle['containerMarginBottom'],
              left: 0,
              right: 0,
            ),
            height: playerStyle['containerHeight'],
            color: playerColor(context, 'containerColor').withOpacity(playerStyle['containerOpacity']),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
      );
    } else {
      final isPlaying = pc.player?.playing == true;
      final data = pc.currentSongData ?? {};
      final artistObjs = pc.artistObjs ?? [];

      String title = data['title'] ?? '';
      String version = data['version'] ?? '';
      String mainArtistUuid = data['user']?.toString() ?? '';

      Map<String, String>? mainArtist;
      if (artistObjs.isNotEmpty) {
        mainArtist = artistObjs.firstWhere(
          (a) => a['uuid'] == mainArtistUuid,
          orElse: () => artistObjs.isNotEmpty ? artistObjs[0] : {},
        );
      }

      List<Map<String, String>> allOthers = [];
      if (artistObjs.length > 1) {
        allOthers.addAll(artistObjs.skip(1));
      }

      if (!pc.expanded) {
        stackChildren.add(
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: playerStyle['fabBottom'],
              ),
              child: Container(
                width: playerStyle["fabSize"],
                height: playerStyle["fabSize"],
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.9),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: FloatingActionButton(
                  onPressed: () {
                    pc.toggleExpand();
                  },
                  mini: true,
                  backgroundColor: playerColor(context, 'fabBackgroundColor'),
                  child: Icon(playerStyle['fabIcon'], color: playerColor(context, 'iconColor'), size: playerStyle['iconExpandSize']),
                  shape: playerStyle['fabShape'],
                  elevation: 0,
                ),
              ),
            ),
          ),
        );
      } else {
        double playedFraction = pc.totalDuration.inMilliseconds > 0
            ? pc.currentPosition.inMilliseconds / pc.totalDuration.inMilliseconds
            : 0.0;
        if (playedFraction < 0) playedFraction = 0;
        if (playedFraction > 1) playedFraction = 1;

        stackChildren.add(
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.only(
                bottom: playerStyle['containerMarginBottom'],
                left: 0,
                right: 0,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: playerStyle['containerPaddingH'],
                vertical: playerStyle['containerPaddingV'],
              ),
              height: playerStyle['containerHeight'],
              decoration: BoxDecoration(
                color: playerColor(context, 'containerColor').withOpacity(playerStyle['containerOpacity']),
                borderRadius: BorderRadius.circular(playerStyle['containerRadius']),
                boxShadow: [
                  BoxShadow(
                    color: playerColor(context, 'containerBoxShadowColor').withOpacity(playerStyle['containerBoxShadowOpacity']),
                    blurRadius: playerStyle['containerBoxShadowBlur'],
                    offset: playerStyle['containerBoxShadowOffset'],
                  )
                ],
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Center(
                      child: PlayerText(
                        mainArtist: mainArtist,
                        allOthers: allOthers,
                        title: title,
                        version: version,
                        mainArtistUuid: mainArtistUuid,
                        songUuid: pc.currentSongUuid,
                        visitorUserId: widget.visitorUserId,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: playerStyle['playPauseBackgroundColor'],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: playerColor(context, 'playPauseIconColor'),
                            size: playerStyle['iconPlaySize'],
                          ),
                          onPressed: () {
                            pc.togglePlayPause();
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          alignment: Alignment.center,
                          child: Waveform(
                            svgUrl: waveformSvgUrl,
                            svgAsset: waveformSvgAsset,
                            playedFraction: playedFraction,
                            totalDuration: pc.totalDuration,
                            onSeek: (Duration pos) {
                              pc.seek(pos);
                            },
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.keyboard_arrow_down, color: playerColor(context, 'iconColor'), size: playerStyle['iconCollapseSize']),
                        onPressed: () {
                          pc.toggleExpand();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }

    return Stack(children: stackChildren);
  }
}
