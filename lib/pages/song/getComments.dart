// Datei: pages/song/getCommentsList.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/getThumb.dart';
import '../../../widgets/contents/fonts.dart';
import '../../../utils/formatBigNum.dart';
import '../../../utils/datetime.dart';
import 'commentlikebutton.dart';
import 'replybutton.dart';

final Map<String, dynamic> commentListStyle = {
  'pinIconColor': 'primary',
  'pinIconSize': 16.0,
  'screenPadH': 16,
  'containerBackgroundColor': 'base',
  'containerMarginV': 7.0,
  'containerPadH': 12.0,
  'containerPadV': 8.0,
  'containerRadius': 12.0,
  'containerOpacity': 0.3,
  'bgBehindColor': 'dark',
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
  'commentColor': 'contrast',
  'commentFontSize': 14.0,
  'commentLineHeight': 1.2,
  'maxCommentLines': 2,
  'timestampColor': 'contrast',
  'timestampFontSize': 10.0,
  'timestampOpacity': 0.5,
  'gapH': 10.0,
  'gapV': 2.0,
};

Color commentColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[commentListStyle[key]]!;
}

class CommentCache {
  static final Map<String, List<Map<String, dynamic>>> _cache = {};
  static List<Map<String, dynamic>>? get(String key) => _cache[key];
  static void set(String key, List<Map<String, dynamic>> value) => _cache[key] = value;
}

class _NoScrollbarScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class GetCommentsList extends StatefulWidget {
  final String songId;
  const GetCommentsList({super.key, required this.songId});

  @override
  State<GetCommentsList> createState() => _GetCommentsListState();
}

class _GetCommentsListState extends State<GetCommentsList> {
  List<Map<String, dynamic>> comments = [];
  final Map<String, bool> expanded = {};
  final Map<String, bool> expandable = {};
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final cached = CommentCache.get(widget.songId);
    if (cached != null) {
      comments = cached;
      for (var c in cached) {
        expanded[c['uuid']] = false;
      }
      _ready = true;
    } else {
      _loadComments();
    }
  }

  void _visitUserProfile(String userId) {
    Navigator.pushNamed(context, '/profile', arguments: {
      'userId': userId,
      'visitorUserId': userId,
    });
  }

  Future<void> _loadComments() async {
    final snap = await FirebaseDatabase.instance.ref('songcomments/${widget.songId}').get();
    if (!snap.exists || snap.value == null) {
      if (!mounted) return;
      setState(() => _ready = true);
      return;
    }


    final Map<String, dynamic> map = Map<String, dynamic>.from(snap.value as Map);
    final List<String> commentIds = List<String>.from(map.keys);
    List<Map<String, dynamic>> fetched = [];

    for (final cid in commentIds) {
      final commentSnap = await FirebaseDatabase.instance.ref('comments/$cid').get();
      if (!commentSnap.exists || commentSnap.value == null) continue;

      final c = Map<String, dynamic>.from(commentSnap.value as Map);
      c['uuid'] = cid;

      final userSnap = await FirebaseDatabase.instance.ref('users/${c['user']}').get();
      if (!userSnap.exists || userSnap.value == null) continue;

      c['userData'] = Map<String, dynamic>.from(userSnap.value as Map);
      fetched.add(c);
    }

    fetched.sort((a, b) {
      final ap = a['pinned'] == true ? 1 : 0;
      final bp = b['pinned'] == true ? 1 : 0;
      if (ap != bp) return bp - ap;
      return (b['timestamp'] ?? 0).compareTo(a['timestamp'] ?? 0);
    });

    CommentCache.set(widget.songId, fetched);

    if (!mounted) return;
    setState(() {
      comments = fetched;
      for (var c in fetched) {
        expanded[c['uuid']] = false;
      }
      _ready = true;
    });

  }

  String formatDateTimeLocal(int ms) => formatDateTime(ms, context);

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());
    if (comments.isEmpty) return const Center(child: Text('No comments.'));

    return ScrollConfiguration(
      behavior: _NoScrollbarScrollBehavior(),
      child: ListView.builder(
        itemCount: comments.length + 1,
        padding: EdgeInsets.zero,
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          if (index == comments.length) return const SizedBox(height: 100);
          final c = comments[index];
          final u = c['userData'];
          final uuid = c['uuid'];
          final isDeleted = c['deleted'] == true;
          final text = isDeleted ? "deleted" : c['text'] ?? "";
          final dateStr = formatDateTimeLocal(c['timestamp'] ?? 0);
          final edited = c['edited'] ?? 0;
          final editedStr = edited > 0 ? ' (${formatDateTimeLocal(edited)})' : '';
          final timestampText = "$dateStr$editedStr";

          final textStyle = TextStyle(
            fontSize: commentListStyle['commentFontSize'],
            height: commentListStyle['commentLineHeight'],
          );

          final tp = TextPainter(
            text: TextSpan(text: text, style: textStyle),
            maxLines: commentListStyle['maxCommentLines'],
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: MediaQuery.of(context).size.width - 100);

          final isExpandable = tp.didExceedMaxLines;
          final isExpanded = expanded[uuid] ?? false;

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: commentListStyle['containerMarginV'],
              horizontal: commentListStyle['screenPadH'],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: commentColor(context, 'bgBehindColor')
                          .withOpacity(commentListStyle['bgBehindOpacity']),
                      borderRadius: BorderRadius.circular(commentListStyle['containerRadius']),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: commentListStyle['containerPadH'],
                    vertical: commentListStyle['containerPadV'],
                  ),
                  decoration: BoxDecoration(
                    color: commentColor(context, 'containerBackgroundColor')
                        .withOpacity(commentListStyle['containerOpacity']),
                    borderRadius: BorderRadius.circular(commentListStyle['containerRadius']),
                  ),
                  child: Stack(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => _visitUserProfile(c['user']),
                            child: Container(
                              width: commentListStyle['avatarSize'],
                              height: commentListStyle['avatarSize'],
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: commentColor(context, 'avatarBorderColor'),
                                  width: commentListStyle['avatarBorderWidth'],
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: ClipOval(
                                child: GetThumb(
                                  uuid: c['user'],
                                  size: commentListStyle['avatarSize'],
                                  path: 'users/avatars/',
                                  filetype: 'jpg',
                                  fallbackPath: 'assets/defaults/cover.png',
                                  shape: 'sphere',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: commentListStyle['gapH']),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () => _visitUserProfile(c['user']),
                                              child: Text(
                                                "${u['name'] ?? ''}",
                                                style: appFonts['caption']!(commentListStyle['nameFontSize']).copyWith(
                                                  fontWeight: commentListStyle['nameFontWeight'],
                                                  color: commentColor(context, 'nameColor'),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.person,
                                              size: commentListStyle['followersIconSize'],
                                              color: commentColor(context, 'followersIconColor')),
                                          const SizedBox(width: 2),
                                          Text(
                                            formatNumber(u['followers'] ?? 0),
                                            style: TextStyle(
                                              fontSize: commentListStyle['followersFontSize'],
                                              fontWeight: commentListStyle['followersWeight'],
                                              color: commentColor(context, 'followersColor'),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: commentListStyle['gapV']),
                                GestureDetector(
                                  onTap: () {
                                    if (isExpandable) {
                                      if (!mounted) return;
                                      setState(() => expanded[uuid] = !isExpanded);
                                    }
                                  },
                                  child: Text(
                                    text,
                                    style: TextStyle(
                                      fontSize: commentListStyle['commentFontSize'],
                                      color: commentColor(context, 'commentColor'),
                                      height: commentListStyle['commentLineHeight'],
                                    ),
                                    overflow:
                                        isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                                    maxLines: isExpanded ? null : commentListStyle['maxCommentLines'],
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  timestampText,
                                  style: TextStyle(
                                    fontSize: commentListStyle['timestampFontSize'],
                                    color: commentColor(context, 'timestampColor')
                                        .withOpacity(commentListStyle['timestampOpacity']),
                                    height: commentListStyle['commentLineHeight'],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                        top: -2,
                        right: -4,
                        child: CommentLikeButton(
                          likes: c['likes'] ?? 0,
                          onPressed: () {},
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        right: -4,
                        child: ReplyButton(
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ),
                if (c['pinned'] == true)
                  Positioned(
                    top: -6,
                    left: -6,
                    child: Transform.rotate(
                      angle: -0.785398,
                      child: Icon(
                        Icons.push_pin,
                        size: commentListStyle['pinIconSize'],
                        color: commentColor(context, 'pinIconColor'),
                      ),
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
