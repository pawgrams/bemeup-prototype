// Datei: widgets/playertext.dart
import 'package:flutter/material.dart';
import '../pages/song/artistoverflow.dart';
import '../theme/dark.dart';
import '../theme/light.dart';

final Map<String, dynamic> playerTextStyle = {
  'artistFontSize': 11.0,
  'artistFontWeight': FontWeight.w400,
  'artistFontColor': 'contrast',
  'artistOverflow': TextOverflow.ellipsis,
  'featFontSize': 11.0,
  'featFontColor': 'contrast',
  'featFontWeight': FontWeight.w200,
  'artistFontMaxLines': 1,
  'titleFontWeight': FontWeight.w400,
  'titleFontColor': 'contrast',
  'versionFontColor': 'contrast',
  'versionFontWeight': FontWeight.w400,
  'mainArtistLeftOverflowPadding': 12.0,
  'textItemGap': 2,
};

Color playerTextColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[playerTextStyle[key]]!;
}

class PlayerText extends StatelessWidget {
  final Map<String, String>? mainArtist;
  final List<Map<String, String>> allOthers;
  final String title;
  final String version;
  final String? mainArtistUuid;
  final String? songUuid;
  final String? visitorUserId;

  const PlayerText({
    super.key,
    required this.mainArtist,
    required this.allOthers,
    required this.title,
    required this.version,
    required this.mainArtistUuid,
    required this.songUuid,
    required this.visitorUserId,
  });

  void _visitUserProfile(BuildContext context, String userId) {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'userId': userId,
        'visitorUserId': visitorUserId,
      },
    );
  }

  void _visitSongPage(BuildContext context, String songId) {
    Navigator.pushNamed(
      context,
      '/song',
      arguments: {
        'songId': songId,
        'visitorUserId': visitorUserId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final artistStyle = TextStyle(
      color: playerTextColor(context, 'artistFontColor'),
      fontWeight: playerTextStyle['artistFontWeight'],
      fontSize: playerTextStyle['artistFontSize'],
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none,
    );
    final titleStyle = TextStyle(
      color: playerTextColor(context, 'titleFontColor'),
      fontWeight: playerTextStyle['titleFontWeight'],
      fontSize: playerTextStyle['artistFontSize'],
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none,
    );
    final versionStyle = TextStyle(
      color: playerTextColor(context, 'versionFontColor'),
      fontWeight: playerTextStyle['versionFontWeight'],
      fontSize: playerTextStyle['artistFontSize'],
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none,
    );
    final featStyle = TextStyle(
      color: playerTextColor(context, 'featFontColor').withOpacity(0.8),
      fontWeight: playerTextStyle['featFontWeight'],
      fontSize: playerTextStyle['featFontSize'],
      overflow: TextOverflow.ellipsis,
      decoration: TextDecoration.none,
    );
    final leftPad = (allOthers.isNotEmpty) ? playerTextStyle['mainArtistLeftOverflowPadding'] : 0.0;

    return LayoutBuilder(
      builder: (ctx, constraints) {
        double artistWidth = 0;
        double dashWidth = 0;
        double titleWidth = 0;
        double versionWidth = 0;
        double featWidth = 0;

        final tpArtist = TextPainter(
          text: TextSpan(text: mainArtist?['name'] ?? '', style: artistStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        artistWidth = tpArtist.width + playerTextStyle["textItemGap"] + 2;

        final tpDash = TextPainter(
          text: TextSpan(text: (mainArtist?['name'] ?? '').isNotEmpty && title.isNotEmpty ? ' - ' : '', style: artistStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        dashWidth = tpDash.width;

        final tpTitle = TextPainter(
          text: TextSpan(text: title, style: titleStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        titleWidth = tpTitle.width + playerTextStyle["textItemGap"] + 2;

        final tpVersion = TextPainter(
          text: TextSpan(text: version.isNotEmpty ? '($version)' : '', style: versionStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        versionWidth = tpVersion.width + playerTextStyle["textItemGap"] + 2;

        final tpFeat = TextPainter(
          text: TextSpan(text: allOthers.isNotEmpty ? ' feat. ' : '', style: artistStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
        )..layout();
        featWidth = tpFeat.width;

        double restWidth = constraints.maxWidth - artistWidth - dashWidth - titleWidth - versionWidth - featWidth - (playerTextStyle["textItemGap"]  + 2) * 3;
        if (restWidth < 0) restWidth = 0;

        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if ((mainArtist?['name'] ?? '').isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: leftPad, right: 0),
                child: GestureDetector(
                  onTap: () => _visitUserProfile(context, mainArtist?['uuid'] ?? ''),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: playerTextStyle["textItemGap"]),
                    child: Text(
                      mainArtist?['name'] ?? '',
                      style: artistStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            if ((mainArtist?['name'] ?? '').isNotEmpty && title.isNotEmpty)
              Text(' - ', style: artistStyle),
            if (title.isNotEmpty)
              GestureDetector(
                onTap: () => _visitSongPage(context, songUuid ?? ''),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: playerTextStyle["textItemGap"]),
                  child: Text(
                    title,
                    style: titleStyle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            if (version.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: playerTextStyle["textItemGap"]),
                child: Text(
                  '($version)',
                  style: versionStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (allOthers.isNotEmpty)
              Text(' ft. ', style: featStyle),
            if (allOthers.isNotEmpty)
              ArtistOverflowLine(
                artists: allOthers,
                onArtistTap: (id) => _visitUserProfile(context, id),
                style: featStyle,
                availableWidth: restWidth,
              ),
          ],
        );
      },
    );
  }
}
