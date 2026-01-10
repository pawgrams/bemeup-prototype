// Datei: pages\user\profile\profile.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'userheader.dart';
import '../../../widgets/elements/sections.dart';
import '../../../widgets/elements/sectioncaption.dart';
import '../../../widgets/elements/tabs.dart';
import '../../../layout.dart';
import 'profileSectionsTabs.dart';
import 'getSonglist.dart';
import 'getSonglikes.dart';
import '../../../context/dummy_logged_user.dart';

class UserProfile extends StatefulWidget {
  final String? profileUserId;
  final String? visitorUserId;

  const UserProfile({super.key, this.profileUserId, this.visitorUserId});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final String visitorUserId = dummyLoggedUser;
  String profileUserId = dummyLoggedUser;
  bool get isSelfProfile => visitorUserId == profileUserId;
  Map<String, dynamic>? userData;
  bool _ready = false;
  int selectedSection = 0;
  int selectedTab = 0;

  List<String> get _sectionKeys => sectionMap.keys.toList();
  List<ProfileSectionsTabs> get _sectionButtonIcons =>
      _sectionKeys.map((k) => sectionIcons[k] ?? ProfileSectionsTabs(icon: Icons.help_outline)).toList();

  List<String> get _tabKeys =>
      (sectionMap[_sectionKeys[selectedSection]] as List<String>);
  List<ProfileSectionsTabs> get _tabIcons =>
      _tabKeys.map((k) => itemIcons[k] ?? ProfileSectionsTabs(icon: Icons.help_outline)).toList();

  String get _activeTabKey =>
      _tabKeys.isNotEmpty && selectedTab < _tabKeys.length
          ? _tabKeys[selectedTab]
          : '';

  @override
  void initState() {
    super.initState();
    if (widget.profileUserId != null && widget.profileUserId!.isNotEmpty) {
      profileUserId = widget.profileUserId!;
    }
    _loadUser();
  }

  Future<void> _loadUser() async {
    final snap = await FirebaseDatabase.instance.ref('users/$profileUserId').get();
    
    if (!snap.exists || snap.value == null) {
      profileUserId = "00f9268e-705c-403e-ba6a-4b917f30b4f3";
      final fallbackSnap = await FirebaseDatabase.instance.ref('users/$profileUserId').get();
      if (!mounted) return;
      setState(() {
        userData = fallbackSnap.exists && fallbackSnap.value != null
            ? Map<String, dynamic>.from(fallbackSnap.value as Map)
            : {};
        _ready = true;
      });
    } else {
      if (!mounted) return;
      setState(() {
        userData = Map<String, dynamic>.from(snap.value as Map);
        _ready = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());

    final String? customImagePath =
        (profileUserId.isNotEmpty)
            ? '/users/backgrounds/9-16/$profileUserId.jpg'
            : null;

    final bool showSonglist = _sectionKeys[selectedSection] == 'music'
        && _tabKeys[selectedTab] == 'songs';
    final bool showSonglikes = _sectionKeys[selectedSection] == 'music'
        && _tabKeys[selectedTab] == 'likes';

    return AppLayout(
      pageTitle: 'profile',
      customImagePath: customImagePath,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                      selectedTab = 0;
                    });
                  },
                ),

              ),
              const SectionCaption(translationKey: 'info'),
              UserHeader(
                userUuid: profileUserId,
                userData: userData ?? {},
                isSelfProfile: isSelfProfile,
              ),
              SizedBox(
                width: double.infinity,
                child: Tabs(
                  icons: _tabIcons,
                  selectedIndex: selectedTab,
                  onTap: (i) {
                    if (!mounted) return;
                    setState(() => selectedTab = i);
                  },
                ),
              ),
              SectionCaption(
                translationKey: _activeTabKey,
              ),
              showSonglist
                  ? SizedBox(
                      height: 440,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                        child: GetSonglist(
                          profileUserId: profileUserId,
                          visitorUserId: visitorUserId,
                        ),
                      ),
                    )
                  : showSonglikes
                      ? SizedBox(
                          height: 440,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                            child: GetSonglikes(
                              profileUserId: profileUserId,
                              visitorUserId: visitorUserId,
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 440,
                          child: Center(child: Text('Placeholder')),
                        ),
            ],
          );
        },
      ),
    );
  }
}
