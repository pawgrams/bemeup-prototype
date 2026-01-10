// Datei: pages\events\event\ranking.dart
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'songlist.dart';
import 'spotlight_voting.dart';
import '../../../widgets/elements/sectioncaption.dart';
import '../../../widgets/sectionhead.dart';
import 'lineupnow.dart';
import 'dart:async';

class Ranking extends StatefulWidget {
  final Map<String, dynamic> stage;
  final Map<String, dynamic> event;
  const Ranking({super.key, required this.stage, required this.event});

  @override
  State<Ranking> createState() => _RankingState();
}

class _RankingState extends State<Ranking> {
  List<Map<String, dynamic>> _ranking = [];
  bool _ready = false;
  final Map<String, int> _spotlightMap = {};
  final Map<String, int> _pendingSpotlightIncrements = {};
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    final stageId = widget.stage['uuid'];
    final snap = await FirebaseDatabase.instance.ref('voting/$stageId').get();
    final List<Map<String, dynamic>> data = [];
    if (snap.exists && snap.value != null) {
      final v = snap.value;
      if (v is List) {
        for (final e in v) {
          if (e is Map) data.add(Map<String, dynamic>.from(e));
        }
      } else if (v is Map) {
        v.forEach((_, value) {
          if (value is Map) data.add(Map<String, dynamic>.from(value));
        });
      }
    }
    for (final song in data) {
      _spotlightMap[song['uuid']] = song['spotlight'] ?? 0;
    }
    if (!mounted) return;
    setState(() {
      _ranking = data;
      _ready = true;
    });
  }

  void _openSong(Map<String, dynamic> song) {
    Navigator.pushNamed(
      context,
      '/song',
      arguments: {
        'songId': song['uuid'],
      },
    );
  }

  void _onStatChanged(String songId, String statKey) {
    if (statKey == 'spotlight') {
      _pendingSpotlightIncrements[songId] = (_pendingSpotlightIncrements[songId] ?? 0) + 1;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _pendingSpotlightIncrements.forEach((id, increment) {
            _spotlightMap[id] = (_spotlightMap[id] ?? 0) + increment;
          });
          _pendingSpotlightIncrements.clear();
        });
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return const Center(child: CircularProgressIndicator());

    final lineup = getCurrentLineup(widget.stage);
    final int? lineupstart = lineup?['start'];
    String lineupname = 'Soon';

    if (lineupstart != null &&
        widget.stage['agenda'] is Map &&
        widget.stage['agenda'][lineupstart.toString()] is Map &&
        (widget.stage['agenda'][lineupstart.toString()]['name'] ?? '').toString().isNotEmpty) {
      lineupname = widget.stage['agenda'][lineupstart.toString()]['name'];
    }
    final String stagename = (widget.stage['name'] ?? '').toString().isNotEmpty
        ? ' ' + widget.stage['name'] + ' Stage'
        : ' This Stage';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHead(
          line1Texts: [lineupname, '@', stagename],
          line1Styles: ['line1Large', 'line1At', 'line1Large'],
          line2Texts: [widget.event["name"]],
          line2Styles: ['line2Large'],
        ),
        const SectionCaption(translationKey: 'spotlight'),
        SpotlightVoting(
          items: _ranking,
          imagePath: 'music/cover/',
          imageThumbPath: 'music/cover/thumb/',
          fileType: 'jpg',
          fallback: 'assets/defaults/cover.png',
          fallbackThumb: 'assets/defaults/cover_thumb.png',
          shape: 'square',
          onTap: _openSong,
          spotlightMap: _spotlightMap,
        ),
        const SectionCaption(translationKey: 'voting'),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: SongList(
              stageId: widget.stage['uuid'],
              songs: _ranking,
              shape: 'square',
              onStatChanged: _onStatChanged,
            ),
          ),
        ),
      ],
    );
  }
}
