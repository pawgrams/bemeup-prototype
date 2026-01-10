// Datei: router.dart
import 'package:flutter/material.dart';
import 'layout.dart';
import 'utils/transoff.dart';
import 'pages/create/create.dart';
import 'pages/playlists/playlists.dart';
import 'pages/wallet/wallet.dart';
import 'pages/user/profile/profile.dart';
import 'pages/events/event/ranking.dart';
import 'pages/events/event/event.dart';
import 'pages/events/events.dart';
import 'pages/events/event/eventdetails.dart';
import 'pages/song/song.dart';
import 'start.dart';
import 'loadonopen.dart';
import '../context/first_launch.dart';
import 'pages/wallet/plans.dart';

final Map<String, WidgetBuilder> menuRoutes = {
  '/': (context) => isFirstLaunch
      ? const LoadOnOpenPage()
      : TransOffWrapper(
          type: 'route',
          child: AppLayout(
            child: StartPage(),
            tooltipCategory: 'start',
            pageTitle: 'start',
          ),
        ),
  '/loadonopen': (context) => const LoadOnOpenPage(),
  '/start': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: StartPage(),
          tooltipCategory: 'start',
          pageTitle: 'start',
        ),
      ),
  '/events': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: Events(),
          tooltipCategory: 'events',
          pageTitle: 'events',
        ),
      ),
  '/create': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: Create(),
          tooltipCategory: 'create',
          pageTitle: 'create',
        ),
      ),
  '/playlists': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: Playlists(),
          tooltipCategory: 'playlists',
          pageTitle: 'playlists',
        ),
      ),
  '/wallet': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: const WalletPage(),
          tooltipCategory: 'wallet',
          pageTitle: 'wallet',
          appBarMiddle: walletHeaderMiddle(context),
        ),
      ),
  '/plans': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: const PlansPage(),
          tooltipCategory: 'plans',
          pageTitle: 'plans',
        ),
      ),
  '/profile': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? profileUserId;
    String? visitorUserId;
    if (args is Map && args.containsKey('userId') && args.containsKey('visitorUserId')) {
      profileUserId = args['userId'];
      visitorUserId = args['visitorUserId'];
    }
    return TransOffWrapper(
      type: 'route',
      child: UserProfile(profileUserId: profileUserId, visitorUserId: visitorUserId),
    );
  },
  '/event': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: Event(event: const {}),
          tooltipCategory: 'event',
          pageTitle: 'event',
        ),
      ),
  '/eventdetails': (context) => TransOffWrapper(
        type: 'route',
        child: AppLayout(
          child: EventDetails(event: const {}, stages: const []),
          tooltipCategory: 'eventdetails',
          pageTitle: 'eventdetails',
        ),
      ),
  '/song': (context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    String? songId;
    String? visitorUserId;
    if (args is Map) {
      songId = args['songId'];
      visitorUserId = args['visitorUserId'];
    }
    return SongPage(
      songId: songId ?? '',
      visitorUserId: visitorUserId ?? '',
    );
  },
  '/ranking': (context) {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args == null || !(args is Map) || !args.containsKey('stage')) {
      return TransOffWrapper(
        type: 'route',
        child: AppLayout(
          pageTitle: 'ranking',
          tooltipCategory: 'ranking',
          child: const Center(
            child: Text('No Stage selected.'),
          ),
        ),
      );
    }
    return TransOffWrapper(
      type: 'route',
      child: AppLayout(
        pageTitle: 'ranking',
        tooltipCategory: 'ranking',
        customImagePath: (args['stage']?['uuid'] != null && args['stage']['uuid'].toString().isNotEmpty)
            ? 'stages/9-16/${args['stage']['uuid']}.jpg'
            : null,
        child: Ranking(
          stage: args['stage'],
          event: args['event'],
        ),
      ),
    );
  },
};
