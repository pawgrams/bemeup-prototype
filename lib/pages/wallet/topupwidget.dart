// Datei: pages/wallet/topupwidget.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/contents/fonts.dart';
import '../../widgets/popup.dart';
import 'paymethods.dart';

final Map<String, dynamic> topupStyle = {
  'usePercentHeightodMediaQuery': 0.55,
  'baseCredits': 100.0,
  'basePrice': 2.95,
  'outerMarginH': 14.0,
  'outerMarginV': 12.0,
  'widgetWidthDelta': 40.0,
  'boxPadV': 8.0,
  'boxPadH': 12.0,
  'boxRadius': 16.0,
  'boxGap': 10.0,
  'topHeadingTopPad': 14.0,
  'topHeadingFontSize': 16.0,
  'topHeadingFontWeight': FontWeight.w700,
  'topHeadingLetterSpacing': 1.2,
  'topHeadingColorKey': 'primary',
  'topHeadingBottomGap': 26.0,
  'listBottomPadding': 0.0,
  'headingFontSize': 14.0,
  'headingFontWeight': FontWeight.w700,
  'headingLetterSpacing': 1.2,
  'headingColorKey': 'contrast',
  'headingToPanelGap': 6.0,
  'headingOffsetX': 5.0,
  'creditsFontSize': 14.0,
  'creditsFontWeight': FontWeight.w400,
  'creditsColorKey': 'base',
  'creditsTextColorKey': 'primary',
  'priceFontSize': 16.0,
  'priceFontWeight': FontWeight.w900,
  'priceColor': Colors.black,
  'savingsFontWeight': FontWeight.w500,
  'savingsTextColorKey': 'secondary',
  'savingsPillBg': Colors.black,
  'savingsPillPadH': 10.0,
  'savingsPillPadV': 4.0,
  'savingsFontSizeDelta': -2.0,
  'savingsOffsetX': 16.0,
  'savingsOffsetY': 16.0,
  'panelBgColor': 'primary',
  'panelOpacityStart': 0.5,
  'panelOpacityStep': 0.12,
  'panelHeight': 50.0,
};

Color _themeColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

class TopUpWidget extends StatelessWidget {
  const TopUpWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('topup');
    final media = MediaQuery.of(context);
    final maxH = media.size.height * (topupStyle["usePercentHeightodMediaQuery"] as num).toDouble();
    final outerH = (topupStyle['outerMarginH'] as num).toDouble();
    final widthDelta = (topupStyle['widgetWidthDelta'] as num).toDouble();
    final desiredContentWidth =
        (media.size.width - 2 * outerH + widthDelta).clamp(0.0, media.size.width);

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: outerH,
            vertical: (topupStyle['outerMarginV'] as num).toDouble(),
          ),
          child: SizedBox(
            width: desiredContentWidth,
            child: StreamBuilder<DatabaseEvent>(
              stream: ref.onValue,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snap.hasData || snap.data?.snapshot.value == null) {
                  return const Center(child: Text('No top-up packages found'));
                }

                final dynamic raw = snap.data!.snapshot.value;
                final dynamic v = jsonDecode(jsonEncode(raw));

                double baseCredits = (topupStyle["baseCredits"] as num).toDouble();
                double basePriceUsd = (topupStyle["basePrice"] as num).toDouble();

                if (v is Map && v['9'] is Map) {
                  final m = Map<String, dynamic>.from(v['9'] as Map);
                  final bc = (m['credits'] is num)
                      ? (m['credits'] as num).toDouble()
                      : double.tryParse('${m['credits']}');
                  final bp = (m['price'] is num)
                      ? (m['price'] as num).toDouble()
                      : double.tryParse('${m['price']}');
                  if (bc != null && bc > 0) baseCredits = bc;
                  if (bp != null && bp > 0) basePriceUsd = bp;
                } else if (v is List && v.length > 9 && v[9] is Map) {
                  final m = Map<String, dynamic>.from(v[9] as Map);
                  final bc = (m['credits'] is num)
                      ? (m['credits'] as num).toDouble()
                      : double.tryParse('${m['credits']}');
                  final bp = (m['price'] is num)
                      ? (m['price'] as num).toDouble()
                      : double.tryParse('${m['price']}');
                  if (bc != null && bc > 0) baseCredits = bc;
                  if (bp != null && bp > 0) basePriceUsd = bp;
                }
                final double basePpc = basePriceUsd / baseCredits;

                final List<Map<String, dynamic>> rawList = [];
                if (v is List) {
                  for (final e in v) {
                    if (e is Map) rawList.add(Map<String, dynamic>.from(e));
                  }
                } else if (v is Map) {
                  v.forEach((_, value) {
                    if (value is Map) rawList.add(Map<String, dynamic>.from(value));
                  });
                }

                rawList.sort((a, b) {
                  final ac = (a['credits'] ?? 0) is num ? (a['credits'] as num).toInt() : 0;
                  final bc = (b['credits'] ?? 0) is num ? (b['credits'] as num).toInt() : 0;
                  return ac.compareTo(bc);
                });

                final List<_Pkg> enriched = [];
                for (final pkg in rawList) {
                  final credits = ((pkg['credits'] ?? 0) as num).toInt();
                  final priceUsd = (pkg['price'] is num)
                      ? (pkg['price'] as num).toDouble()
                      : double.tryParse('${pkg['price']}') ?? 0.0;
                  final nameRaw = (pkg['name'] ?? '').toString();

                  final name = nameRaw
                      .split(' ')
                      .map((w) => w.isNotEmpty ? (w[0].toUpperCase() + w.substring(1)) : w)
                      .join(' ');

                  final bool isBaseline =
                      (credits.toDouble() == baseCredits) &&
                      ((priceUsd - basePriceUsd).abs() < 0.01);

                  double? savingsPct;
                  if (!isBaseline) {
                    final expected = credits * basePpc;
                    if (expected > 0) {
                      final s = (1 - (priceUsd / expected)) * 100.0;
                      if (s > 0) savingsPct = s;
                    }
                  }

                  enriched.add(_Pkg(
                    name: name,
                    credits: credits,
                    priceUsd: priceUsd,
                    savingsPercent: savingsPct,
                  ));
                }

                final start = (topupStyle['panelOpacityStart'] as num).toDouble();
                final step = (topupStyle['panelOpacityStep'] as num).toDouble();

                final List<int> orderBySavings = List<int>.generate(enriched.length, (i) => i)
                  ..sort((i, j) {
                    final si = enriched[i].savingsPercent ?? 0.0;
                    final sj = enriched[j].savingsPercent ?? 0.0;
                    return si.compareTo(sj);
                  });

                final Map<int, int> rankByIndex = {};
                for (int rank = 0; rank < orderBySavings.length; rank++) {
                  rankByIndex[orderBySavings[rank]] = rank;
                }

                final List<double> opacityByIndex = List<double>.generate(enriched.length, (i) {
                  final rank = rankByIndex[i] ?? 0;
                  final op = start + step * rank;
                  return op.clamp(0.0, 1.0);
                });

                final topHeadingTopPad = (payStyle["topHeadingTopPad"] as num).toDouble();
                final topHeadingColor = _themeColor(context, topupStyle['topHeadingColorKey']);
                final topHeadingFs = (topupStyle['topHeadingFontSize'] as num).toDouble();
                final topHeadingFw = (topupStyle['topHeadingFontWeight'] as FontWeight);
                final topHeadingLs = (topupStyle['topHeadingLetterSpacing'] as num).toDouble();
                final topHeadingBottomGap =
                    (topupStyle['topHeadingBottomGap'] as num).toDouble();

                final headingColor = _themeColor(context, topupStyle['headingColorKey']);
                final headingFs = (topupStyle['headingFontSize'] as num).toDouble();
                final headingFw = (topupStyle['headingFontWeight'] as FontWeight);
                final headingLs = (topupStyle['headingLetterSpacing'] as num).toDouble();
                final headingGap = (topupStyle['headingToPanelGap'] as num).toDouble();
                final headingOffsetX = (topupStyle['headingOffsetX'] as num).toDouble();

                final listBottomPadding =
                    (topupStyle['listBottomPadding'] as num).toDouble();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: topHeadingTopPad),
                    Center(
                      child: Text(
                        'Choose a Package',
                        textAlign: TextAlign.center,
                        style: appFonts['caption']!(topHeadingFs).copyWith(
                          fontWeight: topHeadingFw,
                          letterSpacing: topHeadingLs,
                          color: topHeadingColor,
                        ),
                      ),
                    ),
                    SizedBox(height: topHeadingBottomGap),
                    ScrollConfiguration(
                      behavior: const _NoGlowScrollBehavior(),
                      child: ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.only(bottom: listBottomPadding),
                        physics: const ClampingScrollPhysics(),
                        itemCount: enriched.length,
                        separatorBuilder: (_, __) =>
                            SizedBox(height: (topupStyle['boxGap'] as num).toDouble()),
                        itemBuilder: (context, i) {
                          final pkg = enriched[i];
                          final opacity = opacityByIndex[i];

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Transform.translate(
                                offset: Offset(headingOffsetX, 0),
                                child: Text(
                                  pkg.name.isNotEmpty ? pkg.name : 'Top-Up',
                                  style: appFonts['caption']!(headingFs).copyWith(
                                    fontWeight: headingFw,
                                    letterSpacing: headingLs,
                                    color: headingColor,
                                  ),
                                ),
                              ),
                              SizedBox(height: headingGap),
                              _TopupPanel(
                                credits: pkg.credits,
                                priceUsd: pkg.priceUsd,
                                savingsPercent: pkg.savingsPercent,
                                radius: (topupStyle['boxRadius'] as num).toDouble(),
                                panelOpacity: opacity,
                                onTap: () {
                                  popupController.show(
                                    PayMethodsWidget(
                                      selectedCredits: pkg.credits,
                                      selectedPriceUsd: pkg.priceUsd,
                                    ),
                                    yOffset: 0,
                                    useBack: true,
                                    backWidget: const TopUpWidget(),
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _TopupPanel extends StatelessWidget {
  final int credits;
  final double priceUsd;
  final double? savingsPercent;
  final double radius;
  final double panelOpacity;
  final VoidCallback? onTap;

  const _TopupPanel({
    required this.credits,
    required this.priceUsd,
    required this.savingsPercent,
    required this.radius,
    required this.panelOpacity,
    this.onTap,
  });

    @override
  Widget build(BuildContext context) {
    final padV = (topupStyle['boxPadV'] as num).toDouble();
    final padH = (topupStyle['boxPadH'] as num).toDouble();

    final panelBase = _themeColor(context, topupStyle['panelBgColor']);
    final panelBgColor = panelBase.withOpacity(panelOpacity);

    final creditsChipBg = _themeColor(context, topupStyle['creditsColorKey']);
    final creditsChipFg = _themeColor(context, topupStyle['creditsTextColorKey']);

    final priceColor = topupStyle['priceColor'] as Color;

    final savingsTextColor = _themeColor(context, topupStyle['savingsTextColorKey']);
    final savingsPadH = (topupStyle['savingsPillPadH'] as num).toDouble();
    final savingsPadV = (topupStyle['savingsPillPadV'] as num).toDouble();
    final savingsDelta = (topupStyle['savingsFontSizeDelta'] as num).toDouble();
    final offsetX = (topupStyle['savingsOffsetX'] as num).toDouble();
    final offsetY = (topupStyle['savingsOffsetY'] as num).toDouble();

    final creditsFs = (topupStyle['creditsFontSize'] as num).toDouble();
    final priceFs = (topupStyle['priceFontSize'] as num).toDouble();
    final savingsFs = (priceFs + savingsDelta).clamp(1.0, 10000.0);

    final double panelH = (topupStyle['panelHeight'] as num).toDouble();
    final bool useFixedHeight = panelH > 0;

    final panel = Material(
      color: panelBgColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
          child: Column(
            mainAxisAlignment:
                useFixedHeight ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: ShapeDecoration(
                      color: creditsChipBg,
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      '+$credits Credits',
                      style: TextStyle(
                        fontSize: creditsFs,
                        fontWeight: (topupStyle['creditsFontWeight'] as FontWeight),
                        color: creditsChipFg,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${priceUsd.toStringAsFixed(2)} USD',
                    style: TextStyle(
                      fontSize: priceFs,
                      fontWeight: (topupStyle['priceFontWeight'] as FontWeight),
                      color: priceColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final pill = (savingsPercent != null)
        ? Positioned(
            right: -offsetX,
            bottom: -offsetY,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: savingsPadH, vertical: savingsPadV),
              decoration: const ShapeDecoration(
                shape: StadiumBorder(),
                color: Colors.black,
              ),
              child: Text(
                'You save ${savingsPercent!.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: savingsFs,
                  fontWeight: (topupStyle['savingsFontWeight'] as FontWeight),
                  color: savingsTextColor,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    final core = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: panel),
        if (savingsPercent != null) pill,
      ],
    );

    return useFixedHeight ? SizedBox(height: panelH, child: core) : core;
  }
}

class _Pkg {
  final String name;
  final int credits;
  final double priceUsd;
  final double? savingsPercent;
  _Pkg({
    required this.name,
    required this.credits,
    required this.priceUsd,
    required this.savingsPercent,
  });
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}
