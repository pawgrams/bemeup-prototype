// Datei: pages/wallet/plans.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/contents/fonts.dart';
import '../../translations/translations.dart';
import '../../widgets/elements/tooltip.dart';
import '../../widgets/popup.dart';

final Map<String, dynamic> plansStyle = {
  'outerMarginH': 14.0,
  'outerMarginV': 12.0,
  'headerFs': 14.0,
  'headerFw': FontWeight.w700,
  'headerLs': 1.1,
  'headerColorKey': 'primary',
  'headerTopRowDelta': -2.0,
  'featFs': 12.0,
  'featFw': FontWeight.w600,
  'featColorKey': 'contrast',
  'cellFs': 12.0,
  'cellFw': FontWeight.w400,
  'cellColorKey': 'contrast',
  'rowFsDelta': -1.0,
  'stripeOpacity': 0.06,
  'tableBgKey': 'base',
  'chipPadH': 10.0,
  'chipPadV': 6.0,
  'chipRadius': 14.0,
  'chipBgKey': 'base',
  'chipFgKey': 'primary',
  'planColMinWidth': 70.0,
  'featColMinWidth': 100.0,
  'featColMaxWidth': 100.0,
  'columnSpacing': 8.0,
  'dividerHeight': 12.0,
  'bottomExtraSpace': 100.0,
};

Color _c(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

String _cap(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));

class PlansPage extends StatefulWidget {
  const PlansPage({super.key});

  @override
  State<PlansPage> createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  late Future<Map<String, Map<String, dynamic>>> _plansFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      hidePopup();
    });
    _plansFuture = _loadPlans();
  }

  Future<Map<String, Map<String, dynamic>>> _loadPlans() async {
    final snap = await FirebaseDatabase.instance.ref('plans').get();
    final raw = snap.value;
    final json = jsonDecode(jsonEncode(raw));
    final Map<String, Map<String, dynamic>> out = {};
    if (json is Map) {
      json.forEach((k, v) {
        if (k == 'lion') return;
        if (v is Map) out[k.toString()] = Map<String, dynamic>.from(v);
      });
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final bg = _c(context, plansStyle['tableBgKey']);

    final headFsBase = (plansStyle['headerFs'] as num).toDouble();
    final headFsTop = (headFsBase + (plansStyle['headerTopRowDelta'] as num).toDouble()).clamp(1.0, 1000.0);
    final headFw = (plansStyle['headerFw'] as FontWeight);
    final headLs = (plansStyle['headerLs'] as num).toDouble();

    final featFsBase = (plansStyle['featFs'] as num).toDouble();
    final cellFsBase = (plansStyle['cellFs'] as num).toDouble();
    final rowDelta = (plansStyle['rowFsDelta'] as num).toDouble();
    final featFs = (featFsBase + rowDelta).clamp(1.0, 1000.0);
    final cellFs = (cellFsBase + rowDelta).clamp(1.0, 1000.0);

    final headColor = _c(context, plansStyle['headerColorKey']);
    final featFw = (plansStyle['featFw'] as FontWeight);
    final featColor = _c(context, plansStyle['featColorKey']);
    final cellFw = (plansStyle['cellFw'] as FontWeight);
    final cellColor = _c(context, plansStyle['cellColorKey']);

    final stripe = bg.withOpacity((plansStyle['stripeOpacity'] as num).toDouble());
    final chipPadH = (plansStyle['chipPadH'] as num).toDouble();
    final chipPadV = (plansStyle['chipPadV'] as num).toDouble();
    final chipR = (plansStyle['chipRadius'] as num).toDouble();
    final chipBg = _c(context, plansStyle['chipBgKey']);
    final chipFg = _c(context, plansStyle['chipFgKey']);

    final planMin = (plansStyle['planColMinWidth'] as num).toDouble();
    final featMin = (plansStyle['featColMinWidth'] as num).toDouble();
    final featMax = (plansStyle['featColMaxWidth'] as num).toDouble();
    final columnSpacing = (plansStyle['columnSpacing'] as num).toDouble();

    final divH = (plansStyle['dividerHeight'] as num).toDouble();
    final bottomExtra = (plansStyle['bottomExtraSpace'] as num).toDouble();

    Widget planChip(String key) {
      final label = _cap(key);
      return Container(
        padding: EdgeInsets.symmetric(horizontal: chipPadH, vertical: chipPadV),
        decoration: BoxDecoration(
          color: chipBg,
          borderRadius: BorderRadius.circular(chipR),
        ),
        child: Text(
          label,
          style: appFonts['caption']!(headFsTop).copyWith(
            color: chipFg,
            fontWeight: headFw,
            letterSpacing: headLs,
          ),
        ),
      );
    }

    String _tFeat(String key) => tr('ft_$key', locale);
    String _tFeatTooltip(String key) => tr('tt_ft_$key', locale);

    String _formatValue(dynamic v, {bool isPrice = false}) {
      if (v == null) return '—';
      if (isPrice) {
        final d = (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0.0;
        if (d <= 0.0) return 'Free';
        return '${d.toStringAsFixed(2)} USD';
      }
      if (v is bool) return v ? 'Yes' : 'No';
      if (v is int) return '$v';
      if (v is double) {
        if (v == v.roundToDouble()) return v.toInt().toString();
        return v.toString();
      }
      final s = v.toString().trim();
      if (s.isEmpty || s == '???') return '—';
      return s;
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: (plansStyle['outerMarginH'] as num).toDouble(),
        vertical: (plansStyle['outerMarginV'] as num).toDouble(),
      ),
      child: FutureBuilder<Map<String, Map<String, dynamic>>>(
        future: _plansFuture,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('No plans found'));
          }

          final order = ['kitten', 'cat', 'tiger'];
          final plansMap = snap.data!;
          final planKeys = order.where((k) => plansMap.containsKey(k)).toList();

          final List<String> featureOrderPref = [
            'month',
            'year',
            'credits',
            'tokens',
            'freeHighlights',
            'nfts',
            'pinTracks',
            'pinLikes',
            'pinComments',
            'releases',
            'remix',
            'royalties',
            'stage',
            'takedown',
          ];

          final Set<String> allKeys = {};
          for (final k in planKeys) {
            allKeys.addAll(plansMap[k]!.keys.map((e) => e.toString()));
          }

          final features = <String>[];
          for (final k in featureOrderPref) {
            if (allKeys.contains(k)) features.add(k);
          }
          final rest = allKeys.difference(features.toSet()).toList()..sort();
          features.addAll(rest);

          final columns = <DataColumn>[
            DataColumn(
              label: ConstrainedBox(
                constraints: BoxConstraints(minWidth: featMin, maxWidth: featMax),
                child: Text(
                  _tFeat('feature'),
                  softWrap: true,
                  style: TextStyle(
                    fontSize: headFsTop,
                    fontWeight: headFw,
                    color: headColor,
                    height: 1.15,
                  ),
                ),
              ),
            ),
            ...planKeys.map(
              (k) => DataColumn(
                label: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: planMin, maxWidth: planMin),
                  child: planChip(k),
                ),
              ),
            ),
          ];

          final rows = <DataRow>[];
          for (int idx = 0; idx < features.length; idx++) {
            final f = features[idx];
            final isPriceRow = (f == 'month' || f == 'year');
            final leftCell = DataCell(
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: featMin, maxWidth: featMax),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    infoTooltip(
                      context: context,
                      text: _tFeatTooltip(f),
                      spacing: 0,
                      size: 11,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _tFeat(f),
                        softWrap: true,
                        style: TextStyle(
                          fontSize: featFs,
                          fontWeight: featFw,
                          color: featColor,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );

            final planCells = planKeys.map((k) {
              final raw = plansMap[k]?[f];
              return DataCell(
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: planMin, maxWidth: planMin),
                  child: Center(
                    child: Text(
                      _formatValue(raw, isPrice: isPriceRow),
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: cellFs,
                        fontWeight: cellFw,
                        color: cellColor,
                        height: 1.2,
                      ),
                    ),
                  ),
                ),
              );
            }).toList();

            rows.add(
              DataRow(
                color: MaterialStateProperty.resolveWith<Color?>(
                  (states) => idx.isOdd ? stripe : Colors.transparent,
                ),
                cells: [leftCell, ...planCells],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DataTable(
                columns: columns,
                rows: rows,
                dataRowMinHeight: 36,
                dataRowMaxHeight: 52,
                headingRowHeight: 44,
                dividerThickness: 0.6,
                columnSpacing: columnSpacing,
                showBottomBorder: false,
              ),
              SizedBox(height: divH),
              SizedBox(height: bottomExtra),
            ],
          );
        },
      ),
    );
  }
}
