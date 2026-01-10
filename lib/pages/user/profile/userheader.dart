// Datei: pages\user\profile\userheader.dart
import 'package:flutter/material.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/getThumb.dart';
import '../../../widgets/contents/fonts.dart';
import '../../../utils/formatBigNum.dart';
import 'editbutton.dart';
import 'prefsbutton.dart';
import 'followbutton.dart';

final Map<String, dynamic> panelStyle = {
  'containerHeight': 120.0,
  'containerOpacity': 0.4,
  'containerColor': 'dark',
  'backgroundContainerColor': Colors.black,
  'backgroundContainerOpcaity': 0.4,
  'avatarSize': 100.0,
  'avatarOffsetX': 16.0,
  'itemGap': 16.0,
  'avatarBorderColor': 'primary',
  'avatarBorderWidth': 3.0,
  'avatarAlignY': 0.0,
  'verifiedBadgeBottom': 8.0,
  'verifiedBadgeRight': 8.0,
  'verifiedBadgeBorderColor': 'primary',
  'verifiedBadgeBorderWidth': 2.0,
  'verifiedBadgeBg': 'primary',
  'verifiedBadgePadding': 2.0,
  'verifiedIconSize': 22.0,
  'contentPaddingH': 14.0,
  'contentPaddingTop': 17.0,
  'contentOffsetX': 0.0,
  'nameFontSize': 14.0,
  'nameFontWeight': FontWeight.bold,
  'nameLetterSpacing': 1.2,
  'nameFontColor': 'light',
  'nameTextShadowColor': Colors.black,
  'nameTextShadowBlur': 8.0,
  'nameTextShadowOffsetX': 1.0,
  'nameTextShadowOffsetY': 1.0,
  'followersFontSize': 11.0,
  'followersFontWeight': FontWeight.w700,
  'followersFontColor': 'primary',
  'followersTextShadowColor': Colors.black,
  'followersTextShadowBlur': 8.0,
  'followersTextShadowOffsetX': 1.0,
  'followersTextShadowOffsetY': 1.0,
  'followersIconSize': 16.0,
  'followersIconColor': 'primary',
  'bioFontSize': 12.0,
  'bioFontColor': 'light',
  'bioTextShadowColor': Colors.black,
  'bioTextShadowBlur': 8.0,
  'bioTextShadowOffsetX': 0.0,
  'bioTextShadowOffsetY': 0.0,
  'infoGapH': 4.0,
  'infoGapV': 3.0,
  'textShadowOpacity': 0.7,
  'nameYOffset': 4.0,
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black;
  if (key == "grey") return Colors.grey;
  return Colors.blue;
}

class UserHeader extends StatelessWidget {
  final String userUuid;
  final Map<String, dynamic> userData;
  final bool isSelfProfile;

  const UserHeader({
    super.key,
    required this.userUuid,
    required this.userData,
    this.isSelfProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool verified = (userData['verified'] == 1);
    final String name = userData['name'] ?? 'Artist';
    final String bio = userData['bio'] ?? '-';
    final int followers = userData['followers'] ?? 0;
    final double avatarSize = panelStyle['avatarSize'];

    return SizedBox(
      height: panelStyle['containerHeight'],
      width: double.infinity,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: panelStyle['containerHeight'],
            color: panelStyle["backgroundContainerColor"].withOpacity(panelStyle["backgroundContainerOpcaity"]),
          ),
          Container(
            width: double.infinity,
            height: panelStyle['containerHeight'],
            color: panelColor(context, panelStyle['containerColor']).withOpacity(panelStyle['containerOpacity']),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: avatarSize + panelStyle['avatarOffsetX'],
                  alignment: Alignment.center,
                  child: Align(
                    alignment: Alignment(0, panelStyle['avatarAlignY']),
                    child: Padding(
                      padding: EdgeInsets.only(left: panelStyle['avatarOffsetX']),
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: avatarSize,
                            height: avatarSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: panelColor(context, panelStyle['avatarBorderColor']),
                                width: panelStyle['avatarBorderWidth'],
                              ),
                            ),
                            child: ClipOval(
                              child: GetThumb(
                                uuid: userUuid,
                                size: avatarSize,
                                path: 'users/avatars/',
                                filetype: 'jpg',
                                fallbackPath: 'assets/defaults/cover.png',
                                shape: 'sphere',
                              ),
                            ),
                          ),
                          if (verified)
                            Positioned(
                              bottom: panelStyle['verifiedBadgeBottom'],
                              right: panelStyle['verifiedBadgeRight'],
                              child: Container(
                                decoration: BoxDecoration(
                                  color: panelColor(context, panelStyle['verifiedBadgeBg']),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: panelColor(context, panelStyle['verifiedBadgeBorderColor']),
                                    width: panelStyle['verifiedBadgeBorderWidth'],
                                  ),
                                ),
                                padding: EdgeInsets.all(panelStyle['verifiedBadgePadding']),
                                child: Icon(
                                  Icons.verified,
                                  size: panelStyle['verifiedIconSize'],
                                  color: panelColor(context, panelStyle['verifiedBadgeBorderColor']),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: panelStyle['itemGap']),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: panelStyle['contentPaddingTop'],
                      right: panelStyle['contentPaddingH'],
                      left: panelStyle['contentOffsetX'],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Transform.translate(
                          offset: Offset(0, panelStyle['nameYOffset']),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  style: appFonts['caption']!(panelStyle['nameFontSize']).copyWith(
                                    fontWeight: panelStyle['nameFontWeight'],
                                    letterSpacing: panelStyle['nameLetterSpacing'],
                                    color: panelColor(context, panelStyle['nameFontColor']),
                                    overflow: TextOverflow.ellipsis,
                                    shadows: [
                                      Shadow(
                                        color: panelStyle['nameTextShadowColor'].withOpacity(panelStyle["textShadowOpacity"]),
                                        blurRadius: panelStyle['nameTextShadowBlur'],
                                        offset: Offset(
                                          panelStyle['nameTextShadowOffsetX'],
                                          panelStyle['nameTextShadowOffsetY'],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (isSelfProfile) ...[
                                EditButton(onPressed: () {/* TODO: Edit-Funktion */}),
                                SizedBox(width: 6),
                                PrefsButton(onPressed: () {/* TODO: Prefs-Funktion */}),
                              ] else
                                FollowButton(onPressed: () {/* TODO: Follow-Funktion */}),
                            ],
                          ),
                        ),
                        SizedBox(height: panelStyle['infoGapV']),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: panelStyle['followersIconSize'],
                              color: panelColor(context, panelStyle['followersIconColor']),
                            ),
                            SizedBox(width: panelStyle['infoGapH']),
                            GestureDetector(
                              onTap: () {/* TODO: Followerliste anzeigen */},
                              child: Text(
                                formatNumber(followers) + ' Followers',
                                style: appFonts['text']!(panelStyle['followersFontSize']).copyWith(
                                  fontWeight: panelStyle['followersFontWeight'],
                                  color: panelColor(context, panelStyle['followersFontColor']),
                                  shadows: [
                                    Shadow(
                                      color: panelStyle['followersTextShadowColor'].withOpacity(panelStyle["textShadowOpacity"]),
                                      blurRadius: panelStyle['followersTextShadowBlur'],
                                      offset: Offset(
                                        panelStyle['followersTextShadowOffsetX'],
                                        panelStyle['followersTextShadowOffsetY'],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: panelStyle['infoGapV']),
                        Text(
                          bio,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: appFonts['text']!(panelStyle['bioFontSize']).copyWith(
                            color: panelColor(context, panelStyle['bioFontColor']),
                            shadows: [
                              Shadow(
                                color: panelStyle['bioTextShadowColor'].withOpacity(panelStyle["textShadowOpacity"]),
                                blurRadius: panelStyle['bioTextShadowBlur'],
                                offset: Offset(
                                  panelStyle['bioTextShadowOffsetX'],
                                  panelStyle['bioTextShadowOffsetY'],
                                ),
                              ),
                            ],
                          ),
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
