// Datei: pages/user/profile/getSonglist.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../../theme/dark.dart';
import '../../../../theme/light.dart';
import '../../../widgets/getThumb.dart';
import '../../../pages/events/event/highlightfilter.dart';
import 'dart:ui';
import 'package:bemeow/widgets/utils/shape.dart';
import '../../song/artistoverflow.dart';
import '../../../widgets/player.dart';

final Map<String, dynamic> songListStyle = {
  'containerColor': 'light',
  'containerMarginV': 7.0,
  'screenPadH': 8,
  'containerPadH': 12.0,
  'containerPadV': 3.0,
  'containerHeight': 66.0,
  'containerRadius': 12.0,
  'containerOpacity': 0.2,
  'thumbSize': 52.0,
  'thumbRadius': 8.0,
  'titleFontSize': 13.0,
  'titleFontWeight': FontWeight.bold,
  'titleColor': 'contrast',
  'versionFontSize': 10.0,
  'versionColor': 'contrast',
  'likesFontSize': 13.0,
  'likesColor': 'contrast',
  'heartSize': 12.0,
  'heartColor': 'contrast',
  'artistFontSize': 11.0,
  'artistColor': 'contrast',
  'artistFontWeight': FontWeight.bold,
  'artistPrimaryColor': 'primary',
  'genreFontSize': 11.0,
  'genreColor': 'yellow',
  'genrePadLeft': 2.0,
  'cacheExtent': 1200,
  'containerBgHighlightLayer': 'base',
  'highlightShadowColor': Colors.yellow,
  'highlightShadowOpacity': 1.0,
  'highlightShadowBlurRadius': 6.0,
  'highlightShadowSpreadRadius': 1.0,
  'itemsToWaitFor': 8,
};

Color songListColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[songListStyle[key]]!;
}

List<String> _safeList(dynamic v) {
  if (v == null) return [];
  if (v is List<String>) return v;
  if (v is List) return v.map((e) => e?.toString() ?? '').toList();
  return [];
}

class GetSonglist extends StatefulWidget {
  final String visitorUserId;
  final String profileUserId;

  const GetSonglist({
    super.key,
    required this.profileUserId,
    required this.visitorUserId,
  });

  @override
  State<GetSonglist> createState() => _GetSonglistState();
}

class _GetSonglistState extends State<GetSonglist> {
  List<Map<String, dynamic>> songs = [];
  bool _ready = false;
  final Map<String, ImageProvider> _coverMap = {};
  Map<String, Map<String, String>> artistObjs = {};
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadSongs() async {
    final userSongsSnap = await FirebaseDatabase.instance
        .ref('usersongs/${widget.profileUserId}')
        .get();
    if (!userSongsSnap.exists || userSongsSnap.value == null) {
      if (!mounted) return;
      setState(() { _ready = true; });
      return;
    }
    final Map userSongs = Map<String, dynamic>.from(userSongsSnap.value as Map);
    final songIds = userSongs.keys.toList();
    List<Map<String, dynamic>> fetchedSongs = [];
    Set<String> artistUuids = {};

    for (final id in songIds) {
      final songSnap = await FirebaseDatabase.instance.ref('songs/$id').get();
      if (songSnap.exists && songSnap.value != null) {
        final song = Map<String, dynamic>.from(songSnap.value as Map);
        song['uuid'] = id;
        song['featured'] = _safeList(song['featured']);
        song['remixer'] = _safeList(song['remixer']);

        if (song['user'] != null && song['user'].toString().isNotEmpty) artistUuids.add(song['user']);
        artistUuids.addAll(song['featured']);
        artistUuids.addAll(song['remixer']);
        fetchedSongs.add(song);
      }
    }

    Map<String, Map<String, String>> artistMap = {};
    for (final uuid in artistUuids) {
      final userSnap = await FirebaseDatabase.instance.ref('users/$uuid').get();
      if (userSnap.exists && userSnap.value != null) {
        final user = Map<String, dynamic>.from(userSnap.value as Map);
        artistMap[uuid] = {
          'uuid': uuid,
          'name': user['name']?.toString() ?? '',
        };
      }
    }

    for (final song in fetchedSongs) {
      Set<String> addedUuids = {};
      List<Map<String, String>> artistList = [];

      if (song['user'] != null && artistMap.containsKey(song['user'])) {
        addedUuids.add(song['user']);
        artistList.add({'uuid': song['user'], 'name': artistMap[song['user']]?['name'] ?? ''});
      }
      for (final uuid in song['remixer']) {
        if (!addedUuids.contains(uuid) && artistMap.containsKey(uuid)) {
          addedUuids.add(uuid);
          artistList.add({'uuid': uuid, 'name': artistMap[uuid]?['name'] ?? ''});
        }
      }
      for (final uuid in song['featured']) {
        if (!addedUuids.contains(uuid) && artistMap.containsKey(uuid)) {
          addedUuids.add(uuid);
          artistList.add({'uuid': uuid, 'name': artistMap[uuid]?['name'] ?? ''});
        }
      }

      song['artist_objs'] = artistList;
      song.remove('featured');
      song.remove('remixer');
    }
    if (!mounted) return;
    setState(() {
      songs = fetchedSongs;
      artistObjs = artistMap;
      _ready = true;
    });
    _prepareCovers();
  }

  Future<void> _prepareCovers() async {
    final futures = <Future>[];
    for (int i = 0; i < songs.length && i < songListStyle['itemsToWaitFor']; i++) {
      final song = songs[i];
      final url = await GetThumb.getStaticCThumb(song['uuid'] ?? '', path: 'music/cover/');
      if (url != null) {
        final image = NetworkImage(url);
        futures.add(precacheImage(image, context));
        _coverMap[song['uuid'] ?? ''] = image;
      }
    }
    await Future.wait(futures);
    if (!mounted) return;
    setState(() {});
  }

  void _visitUserProfile(String userId) {
    if (userId == widget.profileUserId) return;
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'userId': userId,
        'visitorUserId': widget.visitorUserId,
      },
    );
  }

  void _visitSongPage(String songId) {
    Navigator.pushNamed(
      context,
      '/song',
      arguments: {
        'songId': songId,
        'visitorUserId': widget.visitorUserId,
      },
    );
  }

  void _playSong(Map<String, dynamic> song) {
    PlayerController.instance.play(song['uuid'], songData: song);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());
    if (songs.isEmpty) return const Center(child: Text('No songs found.'));

    final double totalItemHeight = songListStyle['containerHeight'] + 2 * songListStyle['containerMarginV'];
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color thumbShadowColor = isDark ? Colors.white : Colors.black;
    final String shape = 'square';
    final double thumbSize = songListStyle['thumbSize'];

    return ScrollConfiguration(
      behavior: _NoScrollbarScrollBehavior(),
      child: ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        itemCount: songs.length + 1,
        padding: EdgeInsets.zero,
        cacheExtent: songListStyle['cacheExtent'],
        itemBuilder: (context, idx) {
          if (idx == songs.length) return const SizedBox(height: 100);
          final song = songs[idx];
          final highlight = (song['highlight'] ?? 0) is int && (song['highlight'] ?? 0) > DateTime.now().millisecondsSinceEpoch;
          final primaryColor = songListColor(context, 'artistPrimaryColor');
          final artistObjsList = (song['artist_objs'] as List? ?? []);

          final Widget thumb = GestureDetector(
            onTap: () => _playSong(song),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(thumbSize, thumbSize),
                  painter: _GlowPainter(
                    shape: shape,
                    glowColor: thumbShadowColor.withOpacity(0.3),
                    blur: 6,
                  ),
                ),
                applyShape(
                  GetThumb(
                    uuid: song['uuid'] ?? '',
                    size: thumbSize,
                    path: 'music/cover/thumb/',
                    filetype: 'jpg',
                    fallbackPath: 'assets/defaults/cover_thumb.png',
                  ),
                  shape,
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Center(
                      child: Icon(Icons.play_arrow, color: Colors.white.withOpacity(0.7), size: 40),
                    ),
                  ),
                ),
              ],
            ),
          );


          final content = Container(
            padding: EdgeInsets.symmetric(
              horizontal: songListStyle['containerPadH'],
              vertical: songListStyle['containerPadV'],
            ),
            height: songListStyle['containerHeight'],
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: thumbSize, height: thumbSize, child: thumb),
                const SizedBox(width: 10),
                Expanded(
                  child: Center(
                    child: SizedBox(
                      height: thumbSize,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 6,
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: GestureDetector(
                                        onTap: () => _visitSongPage(song['uuid']),
                                        child: Text(
                                          "${song['title'] ?? ''}",
                                          style: TextStyle(
                                            fontSize: songListStyle['titleFontSize'],
                                            fontWeight: songListStyle['titleFontWeight'],
                                            color: songListColor(context, 'titleColor'),
                                            decoration: TextDecoration.none,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "(${song['version'] ?? ''})",
                                      style: TextStyle(
                                        fontSize: songListStyle['versionFontSize'],
                                        color: songListColor(context, 'versionColor'),
                                        decoration: TextDecoration.none,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${song['likes'] ?? 0}",
                                      style: TextStyle(
                                        fontSize: songListStyle['likesFontSize'],
                                        color: songListColor(context, 'likesColor'),
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Icon(
                                      Icons.favorite,
                                      size: songListStyle['heartSize'],
                                      color: songListColor(context, 'heartColor'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          LayoutBuilder(
                            builder: (context, box) {
                              final genre = song['genre'] ?? '';
                              double genreWidth = 0;
                              if (genre.toString().isNotEmpty) {
                                final tp = TextPainter(
                                  text: TextSpan(
                                    text: genre,
                                    style: TextStyle(
                                      fontSize: songListStyle['genreFontSize'],
                                      color: songListColor(context, 'genreColor'),
                                    ),
                                  ),
                                  maxLines: 1,
                                  textDirection: TextDirection.ltr,
                                )..layout();
                                genreWidth = tp.width + 10;
                              }
                              final double availableArtistWidth = box.maxWidth - genreWidth - 16;
                              return Row(
                                children: [
                                  SizedBox(
                                    width: availableArtistWidth > 0 ? availableArtistWidth : 0,
                                    height: 20,
                                    child: ArtistOverflowLine(
                                      artists: artistObjsList.cast<Map<String, String>>(),
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: songListStyle['artistFontSize'],
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                      onArtistTap: (uuid) => _visitUserProfile(uuid),
                                      availableWidth: availableArtistWidth > 0 ? availableArtistWidth : 0,
                                    ),
                                  ),
                                  if ((song['genre'] ?? '').toString().isNotEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(left: songListStyle['genrePadLeft']),
                                      child: SizedBox(
                                        width: genreWidth,
                                        child: Text(
                                          "$genre",
                                          style: TextStyle(
                                            fontSize: songListStyle['genreFontSize'],
                                            color: songListColor(context, 'genreColor'),
                                            decoration: TextDecoration.none,
                                          ),
                                          textAlign: TextAlign.end,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );

          if (!highlight) {
            return SizedBox(
              height: totalItemHeight,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: songListStyle['containerMarginV'], horizontal: songListStyle['screenPadH']),
                child: Container(
                  height: songListStyle['containerHeight'],
                  decoration: BoxDecoration(
                    color: songListColor(context, 'containerColor').withOpacity(songListStyle['containerOpacity']),
                    borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                  ),
                  child: content,
                ),
              ),
            );
          }

          final image = _coverMap[song['uuid'] ?? ''];

          return SizedBox(
            height: totalItemHeight,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: songListStyle['containerMarginV'], horizontal: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                        boxShadow: [
                          BoxShadow(
                            color: songListStyle['highlightShadowColor'].withOpacity(songListStyle['highlightShadowOpacity']),
                            blurRadius: songListStyle['highlightShadowBlurRadius'],
                            spreadRadius: songListStyle['highlightShadowSpreadRadius'],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(songListStyle['containerRadius']),
                      child: HighlightFilter(backgroundImage: image ?? const AssetImage('assets/defaults/cover.png')),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: songListStyle['containerHeight'],
                      child: content,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoScrollbarScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class _GlowPainter extends CustomPainter {
  final String shape;
  final Color glowColor;
  final double blur;

  _GlowPainter({required this.shape, required this.glowColor, required this.blur});

  @override
  void paint(Canvas canvas, Size size) {
    final path = getShapePath(shape, size);
    final paint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
