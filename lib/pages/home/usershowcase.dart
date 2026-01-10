// Datei: pages/home/usershowcase.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../../widgets/getThumb.dart';

final Map<String, dynamic> showcaseStyle = {
  'panelRadius': 18.0,
  'avatarSize': 94.0,
  'avatarBorderWidth': 3.0,
  'backgroundOpacity': 0.3,
  'gap': 0.0,
  'bioFontSize': 12.0,
  'bioColor': 'light',
  'nameFontSize': 14.0,
  'nameFontWeight': FontWeight.bold,
  'nameColor': 'primary',
  'followersFontSize': 11.0,
  'followersFontWeight': FontWeight.w500,
  'followersColor': 'primary',
  'followersIconSize': 14.0,
  'followersIconColor': 'primary',
  'followersIconGap': 5.0,
  'panelBgOpacity': 0.3,
  'panelBgColor': 'base',
  'outerPadding': 10.0,
  'panelPaddingH': 14.0,
  'panelPaddingV': 10.0,
  'panelPaddingTop': 14.0,
  'panelPaddingBottom': 14.0,
  'avatarBorderColor': 'primary',
  'avatarPanelInnerPadLeft': 16.0,
  'avatarPanelInnerPadRight': 12.0,
};

Color showcaseColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[showcaseStyle[key]] ?? Colors.black;
}

class UserShowcase extends StatefulWidget {
  final String userId;
  final bool switchPanels;
  const UserShowcase({super.key, required this.userId, this.switchPanels = false});
  @override
  State<UserShowcase> createState() => _UserShowcaseState();
}

class _UserShowcaseState extends State<UserShowcase> {
  Map<String, dynamic>? userData;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final snap = await FirebaseDatabase.instance.ref('users/${widget.userId}').get();
    if (!mounted) return;
    setState(() {
      userData = snap.exists && snap.value != null ? Map<String, dynamic>.from(snap.value as Map) : {};
      loading = false;
    });
  }

  void _gotoProfile() {
    Navigator.pushNamed(
      context,
      '/profile',
      arguments: {
        'userId': widget.userId,
        'visitorUserId': null,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading)
      return SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));

    final String name = userData?['name'] ?? 'User';
    final String bio = userData?['bio'] ?? '-';
    final int followers = userData?['followers'] ?? 0;

    final double avatarSize = showcaseStyle['avatarSize'];
    final double radius = showcaseStyle['panelRadius'];
    final double gap = showcaseStyle['gap'];
    final double panelPadH = showcaseStyle['panelPaddingH'];
    final double panelPadTop = showcaseStyle['panelPaddingTop'];
    final double panelPadBottom = showcaseStyle['panelPaddingBottom'];
    final double borderWidth = showcaseStyle['avatarBorderWidth'];
    final double panelBgOpacity = showcaseStyle['panelBgOpacity'];
    final double outerPad = showcaseStyle['outerPadding'];
    final double avatarPanelInnerPadLeft = showcaseStyle['avatarPanelInnerPadLeft'];
    final double avatarPanelInnerPadRight = showcaseStyle['avatarPanelInnerPadRight'];
    final double followersIconSize = showcaseStyle['followersIconSize'];
    final Color followersIconColor = showcaseColor(context, 'followersIconColor');
    final double followersIconGap = showcaseStyle['followersIconGap'];

    final Color panelBg = showcaseColor(context, 'panelBgColor').withOpacity(panelBgOpacity);
    final Color nameColor = showcaseColor(context, 'nameColor');
    final Color followersColor = showcaseColor(context, 'followersColor');
    final Color bioColor = showcaseColor(context, 'bioColor');
    final Color avatarBorderColor = showcaseColor(context, 'avatarBorderColor');

    return LayoutBuilder(
      builder: (ctx, cons) {
        final double avatarPanelSide = avatarSize + showcaseStyle['panelPaddingV'] * 2;
        final double availableWidth = cons.maxWidth - gap - outerPad * 2;
        final double infoPanelWidth = availableWidth - avatarPanelSide;

        final infoPanel = Padding(
          padding: EdgeInsets.all(outerPad),
          child: Container(
            width: infoPanelWidth,
            decoration: BoxDecoration(
              color: panelBg,
              borderRadius: BorderRadius.circular(radius),
            ),
            padding: EdgeInsets.only(
              left: panelPadH,
              right: panelPadH,
              top: panelPadTop,
              bottom: panelPadBottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _gotoProfile,
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: showcaseStyle['nameFontSize'],
                      fontWeight: showcaseStyle['nameFontWeight'],
                      color: nameColor,
                    ),
                  ),
                ),
                SizedBox(height: 2),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      size: followersIconSize,
                      color: followersIconColor,
                    ),
                    SizedBox(width: followersIconGap),
                    Text(
                      '$followers Follower',
                      style: TextStyle(
                        fontSize: showcaseStyle['followersFontSize'],
                        fontWeight: showcaseStyle['followersFontWeight'],
                        color: followersColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3),
                Text(
                  bio,
                  style: TextStyle(
                    fontSize: showcaseStyle['bioFontSize'],
                    color: bioColor,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );

        Widget avatarInner = GestureDetector(
          onTap: _gotoProfile,
          child: Container(
            width: avatarSize,
            height: avatarSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: avatarBorderColor,
                width: borderWidth,
              ),
            ),
            child: ClipOval(
              child: GetThumb(
                uuid: widget.userId,
                size: avatarSize,
                path: 'users/avatars/',
                filetype: 'jpg',
                fallbackPath: 'assets/defaults/cover.png',
                shape: 'sphere',
              ),
            ),
          ),
        );

        Widget avatarPanel = Container(
          width: avatarPanelSide,
          height: avatarPanelSide,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(radius),
          ),
          alignment: Alignment.center,
          child: Padding(
            padding: widget.switchPanels
                ? EdgeInsets.only(left: avatarPanelInnerPadLeft)
                : EdgeInsets.only(right: avatarPanelInnerPadRight),
            child: avatarInner,
          ),
        );

        final rowChildren = widget.switchPanels
            ? [avatarPanel, SizedBox(width: gap), infoPanel]
            : [infoPanel, SizedBox(width: gap), avatarPanel];

        return Container(
          width: double.infinity,
          height: avatarPanelSide + outerPad * 2,
          color: showcaseColor(context, 'light').withOpacity(showcaseStyle["backgroundOpacity"]),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: rowChildren,
          ),
        );
      },
    );
  }
}
