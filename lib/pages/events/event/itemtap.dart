// Datei: pages\events\event\itemtap.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'itemtap_audio.dart';
import '../../../context/actiontypes.dart';
import '../../../utils/checkBalance.dart';
import 'package:bemeow/context/dummy_logged_user.dart';
import '../../../widgets/minipopup.dart';

final Map<String, dynamic> itemTapStyle = {
  'durationMs': 3700,
  'moveY': -600.0,
  'curveIntensity': 0.8,
  'waveAmplitude': 12.0,
  'waveFrequency': 2.0,
  'waveDamping': 0.8,
  'amplitudeGrowth': 2.0,
  'speedDamping': 0.85,
  'fadeStart': 0.3,
  'fadeEnd': 1.0,
  'scaleStart': 1.1,
  'scaleEnd': 2.0,
  'startXOffsetFallback': -66.0,
};

final Map<IconData, double> itemTapOffsets = {
  Icons.rocket_launch: -55.0,
  Icons.bolt: -62.0,
  Icons.local_fire_department: -58.0,
};

void _cacheUserAction(String type, String stageId, String songId, dynamic action) async {
  action['stage'] = stageId;
  action['song'] = songId;
  action['timestamp'] = DateTime.now().millisecondsSinceEpoch;
  action['user'] = dummyLoggedUser;
  userBalancesProvider.subtractFromCredits(amount: action["credits"]);
  userActions.add(action);
}

class ItemTapEffect extends StatefulWidget {
  final IconData icon;
  final double iconSize;
  final Color color;
  final Offset startOffset;
  final OverlayEntry entry;

  const ItemTapEffect({
    super.key,
    required this.icon,
    required this.iconSize,
    required this.color,
    required this.startOffset,
    required this.entry,
  });

  @override
  State<ItemTapEffect> createState() => _ItemTapEffectState();
}

class _ItemTapEffectState extends State<ItemTapEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: Duration(milliseconds: itemTapStyle['durationMs']),
    vsync: this,
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.entry.remove();
    })..forward();

  late final double _randomPhase = (Random().nextDouble() * (pi / 2)) - (pi / 4);

  late final Animation<double> _animY = Tween<double>(
    begin: 0,
    end: itemTapStyle['moveY'],
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: _CustomCurve(itemTapStyle['curveIntensity']),
  ));

  late final Animation<double> _animOpacity = Tween<double>(
    begin: 1.0,
    end: 0.0,
  ).animate(CurvedAnimation(
    parent: _controller,
    curve: Interval(itemTapStyle['fadeStart'], itemTapStyle['fadeEnd'], curve: Curves.easeOut),
  ));

  late final Animation<double> _animScale = Tween<double>(
    begin: itemTapStyle['scaleStart'],
    end: itemTapStyle['scaleEnd'],
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  Widget build(BuildContext context) {
    final double startXOffset = itemTapOffsets[widget.icon] ?? itemTapStyle['startXOffsetFallback'];
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final t = _controller.value;
        final waveX = _computeWaveX(t);
        return Positioned(
          left: widget.startOffset.dx + startXOffset + waveX,
          top: widget.startOffset.dy + _animY.value,
          child: Opacity(
            opacity: _animOpacity.value,
            child: Transform.scale(
              scale: _animScale.value,
              child: Icon(widget.icon, color: widget.color, size: widget.iconSize),
            ),
          ),
        );
      },
    );
  }

  double _computeWaveX(double t) {
    final f0 = itemTapStyle['waveFrequency'];
    final amp0 = itemTapStyle['waveAmplitude'];
    final damp = itemTapStyle['waveDamping'];
    final growth = itemTapStyle['amplitudeGrowth'];
    final sd = itemTapStyle['speedDamping'];
    final progFreq = f0 * pow(sd, t * f0 * 2);
    final amp = amp0 * pow(damp, (f0 * t * 2)) * pow(growth, t * f0 * 2);
    return sin(2 * pi * progFreq * t + _randomPhase) * amp;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _CustomCurve extends Curve {
  final double intensity;
  const _CustomCurve(this.intensity);
  @override
  double transform(double t) => pow(t, intensity).toDouble();
}

void showItemTapEffect({
  required BuildContext context,
  required IconData icon,
  required double iconSize,
  required Color color,
  required Offset globalOffset,
  required String type,
  required String stageId,
  required String songId,
  required VoidCallback? onSuccess,
}) async {
  final action = Map<String, dynamic>.from(getActionTypes()[type]);
  if (!hasEnoughCredits(action["credits"])) {
    showMiniPopup('❌ Insufficient credit balance.');
    return;
  }
  _cacheUserAction(type, stageId, songId, action);
  if (onSuccess != null) onSuccess(); 
  playTapSound();
  final overlay = Overlay.of(context);
  final box = overlay.context.findRenderObject() as RenderBox?;
  if (box == null) return;
  final rel = box.globalToLocal(globalOffset) - Offset(iconSize / 2, iconSize / 2);
  late OverlayEntry entry;
  entry = OverlayEntry(builder: (_) => ItemTapEffect(
    icon: icon,
    iconSize: iconSize,
    color: color,
    startOffset: rel,
    entry: entry,
  ));
  overlay.insert(entry);
}
