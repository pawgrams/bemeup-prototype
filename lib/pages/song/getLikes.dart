// Datei: pages/song/getLikes.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/getThumb.dart';
import '../../../widgets/contents/fonts.dart';
import '../../../utils/formatBigNum.dart';
import '../../../utils/datetime.dart';
import 'followbuttonlist.dart';

final Map<String, dynamic> likeListStyle = {
  'screenPadH': 16,
  'containerMarginV': 4.0,
  'containerPadH': 12.0,
  'containerPadV': 8.0,
  'containerRadius': 12.0,
  'containerOpacity': 0.3,
  'bgBehindColor': 'base',
  'bgBehindOpacity': 0.2,
  'avatarBorderColor': 'primary',
  'avatarSize': 40.0,
  'avatarBorderWidth': 2.0,
  'nameColor': 'primary',
  'nameFontSize': 13.0,
  'nameFontWeight': FontWeight.bold,
  'followersIconColor': 'primary',
  'followersIconSize': 12.0,
  'followersColor': 'primary',
  'followersFontSize': 10.0,
  'followersWeight': FontWeight.normal,
  'timestampColor': 'contrast',
  'timestampFontSize': 10.0,
  'timestampOpacity': 0.5,
};

Color likeColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[likeListStyle[key]] ?? themeMap['contrast']!;
}

class _NoScrollbarScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class GetLikesList extends StatefulWidget {
  final String songId;
  const GetLikesList({super.key, required this.songId});

  @override
  State<GetLikesList> createState() => _GetLikesListState();
}

class _GetLikesListState extends State<GetLikesList> {
  List<Map<String, dynamic>> users = [];
  Map<String, dynamic> likeTimestamps = {};
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    final snap = await FirebaseDatabase.instance.ref('songlikes/${widget.songId}').get();
    if (!snap.exists || snap.value == null) {
      if (!mounted) return;
      setState(() => _ready = true);
      return;
    }

    final Map<String, dynamic> map = Map<String, dynamic>.from(snap.value as Map);
    likeTimestamps = map;
    final userIds = map.keys.toList();
    List<Map<String, dynamic>> fetched = [];

    for (final uid in userIds) {
      final userSnap = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (!userSnap.exists || userSnap.value == null) continue;

      final u = Map<String, dynamic>.from(userSnap.value as Map);
      u['uuid'] = uid;
      fetched.add(u);
    }
    if (!mounted) return;
    setState(() {
      users = fetched;
      _ready = true;
    });
  }

  void _visitUserProfile(String userId) {
    Navigator.pushNamed(context, '/profile', arguments: {
      'userId': userId,
      'visitorUserId': userId,
    });
  }

  String formatDateTimeLocal(int ms) => formatDateTime(ms, context);

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());
    if (users.isEmpty) return const Center(child: Text('No likes yet.'));

    return ScrollConfiguration(
      behavior: _NoScrollbarScrollBehavior(),
      child: ListView.builder(
        itemCount: users.length + 1,
        padding: EdgeInsets.zero,
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          if (index == users.length) return const SizedBox(height: 100);
          final u = users[index];
          final uuid = u['uuid'];
          final timestamp = int.tryParse(likeTimestamps[uuid].toString()) ?? 0;
          final dateStr = formatDateTimeLocal(timestamp);

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: likeListStyle['containerMarginV'],
              horizontal: likeListStyle['screenPadH'],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: likeColor(context, 'bgBehindColor')
                          .withOpacity(likeListStyle['bgBehindOpacity']),
                      borderRadius: BorderRadius.circular(likeListStyle['containerRadius']),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: likeListStyle['containerPadH'],
                    vertical: likeListStyle['containerPadV'],
                  ),
                  decoration: BoxDecoration(
                    color: likeColor(context, 'bgBehindColor')
                        .withOpacity(likeListStyle['containerOpacity']),
                    borderRadius: BorderRadius.circular(likeListStyle['containerRadius']),
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => _visitUserProfile(uuid),
                        child: Container(
                          width: likeListStyle['avatarSize'],
                          height: likeListStyle['avatarSize'],
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: likeColor(context, 'avatarBorderColor'),
                              width: likeListStyle['avatarBorderWidth'],
                            ),
                          ),
                          child: ClipOval(
                            child: GetThumb(
                              uuid: uuid,
                              size: likeListStyle['avatarSize'],
                              path: 'users/avatars/',
                              filetype: 'jpg',
                              fallbackPath: 'assets/defaults/cover.png',
                              shape: 'sphere',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _visitUserProfile(uuid),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      u['name'] ?? '',
                                      style: appFonts['caption']!(likeListStyle['nameFontSize']).copyWith(
                                        fontWeight: likeListStyle['nameFontWeight'],
                                        color: likeColor(context, 'nameColor'),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  FollowButtonList(onPressed: () {}),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.person,
                                    size: likeListStyle['followersIconSize'],
                                    color: likeColor(context, 'followersIconColor'),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    formatNumber(u['followers'] ?? 0),
                                    style: TextStyle(
                                      fontSize: likeListStyle['followersFontSize'],
                                      fontWeight: likeListStyle['followersWeight'],
                                      color: likeColor(context, 'followersColor'),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: likeListStyle['timestampFontSize'],
                                      color: likeColor(context, 'timestampColor')
                                          .withOpacity(likeListStyle['timestampOpacity']),
                                      height: 1.2,
                                    ),
                                  ),
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
        },
      ),
    );
  }
}
