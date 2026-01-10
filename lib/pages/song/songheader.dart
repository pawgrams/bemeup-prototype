// Datei: pages/song/songheader.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/getThumb.dart';
import '../../widgets/contents/fonts.dart';
import '../../utils/formatBigNum.dart';
import 'package:firebase_database/firebase_database.dart';
import 'editbutton.dart';
import 'likebutton.dart';
import 'artistoverflow.dart';
import '../../utils/timeleft.dart';
import '../../widgets/player.dart';

final Map<String, dynamic> songHeaderStyle = {
  'containerHeight': 120.0,
  'containerOpacity': 0.4,
  'containerColor': 'dark',
  'backgroundContainerColor': Colors.black,
  'backgroundContainerOpcaity': 0.4,
  'coverSize': 100.0,
  'coverOffsetX': 16.0,
  'itemGap': 16.0,
  'coverBorderColor': 'primary',
  'coverBorderWidth': 0.0,
  'coverAlignY': 0.0,
  'contentPaddingH': 14.0,
  'contentPaddingTop': 17.0,
  'contentOffsetX': 0.0,
  'titleFontSize': 14.0,
  'titleFontWeight': FontWeight.bold,
  'titleLetterSpacing': 1.0,
  'titleFontColor': 'light',
  'statsFontSize': 11.0,
  'statsFontWeight': FontWeight.w400,
  'statsFontColor': 'primary',
  'statsIconSize': 16.0,
  'statsIconColor': 'primary',
  'descFontSize': 12.0,
  'descFontColor': 'light',
  'infoGapH': 6.0,
  'infoGapV': 3.0,
  'textShadowOpacity': 0.7,
  'editButtonSize': 34.0,
  'editButtonIconSize': 17.0,
  'titleYOffset': 4.0,
  'coverGlowColor': Colors.white,
  'coverGlowOpacity': 0.3,
  'coverGlowBlur': 6.0,
};

Color songHeaderColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black;
  if (key == "grey") return Colors.grey;
  return Colors.blue;
}

class SongHeader extends StatefulWidget {
  final String songId;
  final Map<String, dynamic> songData;
  final String visitorUserId;

  const SongHeader({
    super.key,
    required this.songId,
    required this.songData,
    required this.visitorUserId,
  });

  @override
  State<SongHeader> createState() => _SongHeaderState();
}

class _SongHeaderState extends State<SongHeader> {
  List<Map<String, String>> artistObjs = [];
  bool _ready = false;
  bool _isOwnSong = false;

  @override
  void initState() {
    super.initState();
    _resetAndLoadArtists();
    _checkIsOwnSong();
  }

  @override
  void didUpdateWidget(SongHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.songId != widget.songId || oldWidget.songData != widget.songData) {
      _resetAndLoadArtists();
      _checkIsOwnSong();
    }
  }

  void _resetAndLoadArtists() {
    if (!mounted) return;
    setState(() {
      artistObjs = [];
      _ready = false;
    });
    _loadArtists();
  }

  List<String> _safeList(dynamic v) {
    if (v == null) return [];
    if (v is List<String>) return v;
    if (v is List) return v.map((e) => e?.toString() ?? '').toList();
    return [];
  }

  Future<void> _loadArtists() async {
    final song = widget.songData;
    Set<String> artistUuids = {};
    if (song['user'] != null && song['user'].toString().isNotEmpty) artistUuids.add(song['user'].toString());
    List<String> remixer = _safeList(song['remixer']);
    List<String> featured = _safeList(song['featured']);
    artistUuids.addAll(remixer);
    artistUuids.addAll(featured);

    Map<String, Map<String, String>> artistMap = {};
    for (final uuid in artistUuids) {
      if (uuid.isEmpty) continue;
      final userSnap = await FirebaseDatabase.instance.ref('users/$uuid').get();
      if (userSnap.exists && userSnap.value != null) {
        final user = Map<String, dynamic>.from(userSnap.value as Map);
        artistMap[uuid] = {
          'uuid': uuid,
          'name': user['name']?.toString() ?? '',
        };
      }
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

    if (!mounted) return;
    setState(() {
      artistObjs = objs;
      _ready = true;
    });
  }

  Future<void> _checkIsOwnSong() async {
    final userSongsSnap = await FirebaseDatabase.instance
        .ref('usersongs/${widget.visitorUserId}')
        .get();
    bool isOwn = false;
    if (userSongsSnap.exists && userSongsSnap.value != null) {
      final Map userSongs = Map<String, dynamic>.from(userSongsSnap.value as Map);
      final mainArtist = widget.songData['user'];
      isOwn = userSongs.containsKey(widget.songId) &&
          mainArtist != null &&
          widget.visitorUserId == mainArtist.toString();
    }
    if (!mounted) return;
    setState(() {
      _isOwnSong = isOwn;
    });
  }

  void _visitUserProfile(String userId) {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'userId': userId,
        'visitorUserId': widget.visitorUserId,
      },
    );
  }

  void _playSong() {
    PlayerController.instance.play(widget.songId, songData: widget.songData);
  }

  @override
  Widget build(BuildContext context) {
    final songData = widget.songData;
    final String title = songData['title'] ?? 'Song';
    final String version = songData['version'] ?? '';
    final String genre = songData['genre'] ?? '';
    final int plays = songData['plays'] ?? 0;
    final int eventplays = songData['eventplays'] ?? 0;
    final int likes = songData['likes'] ?? 0;
    final int highlight = songData['highlight'] ?? 0;
    final primaryColor = songHeaderColor(context, 'primary');
    final now = DateTime.now().millisecondsSinceEpoch;

    return SizedBox(
      height: songHeaderStyle['containerHeight'],
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: songHeaderStyle['containerHeight'],
            color: songHeaderStyle["backgroundContainerColor"].withOpacity(songHeaderStyle["backgroundContainerOpcaity"]),
          ),
          Container(
            width: double.infinity,
            height: songHeaderStyle['containerHeight'],
            color: songHeaderColor(context, songHeaderStyle['containerColor']).withOpacity(songHeaderStyle['containerOpacity']),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: songHeaderStyle['coverSize'] + songHeaderStyle['coverOffsetX'],
                  alignment: Alignment.center,
                  child: Align(
                    alignment: Alignment(0, songHeaderStyle['coverAlignY']),
                    child: Padding(
                      padding: EdgeInsets.only(left: songHeaderStyle['coverOffsetX']),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            size: Size(songHeaderStyle['coverSize'], songHeaderStyle['coverSize']),
                            painter: _GlowPainter(
                              glowColor: songHeaderStyle['coverGlowColor'].withOpacity(songHeaderStyle['coverGlowOpacity']),
                              blur: songHeaderStyle['coverGlowBlur'],
                            ),
                          ),
                          Container(
                            width: songHeaderStyle['coverSize'],
                            height: songHeaderStyle['coverSize'],
                            decoration: BoxDecoration(
                              shape: BoxShape.rectangle,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: GetThumb(
                                uuid: widget.songId,
                                size: songHeaderStyle['coverSize'],
                                path: 'music/cover/thumb/',
                                filetype: 'jpg',
                                fallbackPath: 'assets/defaults/cover.png',
                                shape: 'square',
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.center,
                              child: IconButton(
                                icon: Icon(Icons.play_arrow, color: Colors.white.withOpacity(0.65), size: 54),
                                onPressed: _playSong,
                                splashRadius: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: songHeaderStyle['itemGap']),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: songHeaderStyle['contentPaddingTop'],
                      right: songHeaderStyle['contentPaddingH'],
                      left: songHeaderStyle['contentOffsetX'],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Transform.translate(
                          offset: Offset(0, songHeaderStyle['titleYOffset']),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        title,
                                        style: appFonts['caption']!(songHeaderStyle['titleFontSize']).copyWith(
                                          fontWeight: songHeaderStyle['titleFontWeight'],
                                          letterSpacing: songHeaderStyle['titleLetterSpacing'],
                                          color: songHeaderColor(context, songHeaderStyle['titleFontColor']),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_isOwnSong)
                                EditButton(onPressed: () {/* TODO: Edit Song */})
                              else
                                LikeButton(onPressed: () {/* TODO: Like Song */}),
                            ],
                          ),
                        ),
                        if (_ready && artistObjs.isNotEmpty) ...[
                          SizedBox(height: songHeaderStyle['infoGapV']),
                          LayoutBuilder(
                            builder: (ctx, constraints) {
                              return Row(
                                children: [
                                  ArtistOverflowLine(
                                    artists: artistObjs,
                                    onArtistTap: _visitUserProfile,
                                    style: appFonts['text']!(songHeaderStyle['descFontSize']).copyWith(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.none,
                                    ),
                                    availableWidth: constraints.maxWidth - 38,
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                        if ((_ready && artistObjs.isNotEmpty) || (genre.isNotEmpty || version.isNotEmpty))
                          SizedBox(height: songHeaderStyle['infoGapV']),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (genre.isNotEmpty) ...[
                              Text(
                                genre,
                                style: appFonts['text']!(songHeaderStyle['descFontSize']).copyWith(
                                  color: songHeaderColor(context, songHeaderStyle['descFontColor']),
                                ),
                              ),
                            ],
                            if (genre.isNotEmpty && version.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: Center(
                                  child: Text(
                                    '',
                                    textAlign: TextAlign.center,
                                    style: appFonts['text']!(songHeaderStyle['descFontSize']).copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: songHeaderStyle['descFontSize'] + 4,
                                      height: 1.1,
                                      color: songHeaderColor(context, songHeaderStyle['descFontColor']),
                                    ),
                                  ),
                                ),
                              ),
                            if (version.isNotEmpty) ...[
                              Text(
                                '($version)',
                                style: appFonts['text']!(songHeaderStyle['descFontSize']).copyWith(
                                  color: songHeaderColor(context, songHeaderStyle['descFontColor']),
                                ),
                              ),
                            ]
                          ],
                        ),
                        SizedBox(height: songHeaderStyle['infoGapV']),
                        Row(
                          children: [
                            Transform.translate(
                                offset: Offset(0, -0.3),
                                child: Icon(
                                  Icons.favorite, 
                                  size: songHeaderStyle['statsIconSize'] - 3, 
                                  color: songHeaderColor(context, songHeaderStyle['statsIconColor'])
                                ),
                              ),
                            SizedBox(width: 4),
                            Text(formatNumber(likes), style: appFonts['text']!(songHeaderStyle['statsFontSize']).copyWith(
                              fontWeight: songHeaderStyle['statsFontWeight'],
                              color: songHeaderColor(context, songHeaderStyle['statsFontColor']),
                            )),
                            SizedBox(width: 8),
                            Transform.translate(
                                offset: Offset(0, -0.2),
                                child: Icon(
                                  Icons.event, 
                                  size: songHeaderStyle['statsIconSize'] - 3.5, 
                                  color: songHeaderColor(context, songHeaderStyle['statsIconColor'])
                                ),
                              ),
                            SizedBox(width: 3),
                            Text(formatNumber(eventplays), style: appFonts['text']!(songHeaderStyle['statsFontSize']).copyWith(
                              fontWeight: songHeaderStyle['statsFontWeight'],
                              color: songHeaderColor(context, songHeaderStyle['statsFontColor']),
                            )),  
                            SizedBox(width: 4),
                            Icon(Icons.play_arrow, size: songHeaderStyle['statsIconSize'], color: songHeaderColor(context, songHeaderStyle['statsIconColor'])),
                            SizedBox(width: 0),
                            Text(formatNumber(plays), style: appFonts['text']!(songHeaderStyle['statsFontSize']).copyWith(
                              fontWeight: songHeaderStyle['statsFontWeight'],
                              color: songHeaderColor(context, songHeaderStyle['statsFontColor']),
                            )),
                            if (highlight > 0 && (highlight - now) > 0) ...[
                              SizedBox(width: 8),
                              Transform.translate(
                                offset: Offset(0, -0.2),
                                child: Icon(
                                  Icons.local_fire_department,
                                  size: songHeaderStyle['statsIconSize'] - 2.5,
                                  color: songHeaderColor(context, songHeaderStyle['statsIconColor']),
                                ),
                              ),
                              SizedBox(width: 2),
                              TimeLeftText(
                                timestampMs: highlight,
                                style: appFonts['text']!(songHeaderStyle['statsFontSize']).copyWith(
                                  fontWeight: songHeaderStyle['statsFontWeight'],
                                  color: songHeaderColor(context, songHeaderStyle['statsFontColor']),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowPainter extends CustomPainter {
  final Color glowColor;
  final double blur;

  _GlowPainter({
    required this.glowColor,
    required this.blur,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(8));
    final paint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
