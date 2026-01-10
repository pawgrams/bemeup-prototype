// Datei: pages/wallet/upgrade.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/contents/fonts.dart';
import '../../translations/translations.dart';
import 'package:bemeow/context/dummy_logged_user.dart';

final Map<String, dynamic> upgradeStyle = {
  'usePercentHeightodMediaQuery': 0.55,
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
  'topHeadingBottomGap': 14.0,
  'tabsHeight': 36.0,
  'tabFs': 13.0,
  'tabsToFirstItemGap': 20.0,
  'listBottomPadding': 0.0,
  'headingFontSize': 14.0,
  'headingFontWeight': FontWeight.w700,
  'headingLetterSpacing': 1.2,
  'headingColorKey': 'contrast',
  'headingToPanelGap': 6.0,
  'headingOffsetX': 5.0,
  'pillFontSize': 12.0,
  'pillFontWeight': FontWeight.w500,
  'pillBgKey': 'base',
  'pillFgKey': 'primary',
  'pillPadH': 12.0,
  'pillPadV': 5.0,
  'priceFontSize': 16.0,
  'priceFontWeight': FontWeight.w900,
  'priceColor': Colors.black,
  'panelBgColor': 'primary',
  'panelOpacityStart': 0.5,
  'panelOpacityStep': 0.12,
  'panelHeight': 50.0,
  'pillBadgeOffsetX': 12.0,
  'pillBadgeOffsetY': 16.0,
  'compareBtnFs': 14.0,
  'compareBtnPadH': 16.0,
  'compareBtnPadV': 10.0,
  'compareBtnRadius': 18.0,
  'compareBtnTextColorKey': 'primary',
  'compareBtnBgKey': 'base',
  'compareBtnBgOpacity': 1.0,
};

Color _c(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

String _cap(String s) => s.isEmpty ? s : (s[0].toUpperCase() + s.substring(1));

class UpgradeWidget extends StatefulWidget {
  const UpgradeWidget({super.key});
  @override
  State<UpgradeWidget> createState() => _UpgradeWidgetState();
}

class _UpgradeWidgetState extends State<UpgradeWidget> with TickerProviderStateMixin {
  late Future<_UserSub?> _userSubFuture;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _userSubFuture = _fetchUserSub();
  }

  Future<_UserSub?> _fetchUserSub() async {
    final uid = dummyLoggedUser;
    if (uid.isEmpty) return null;
    final planSnap = await FirebaseDatabase.instance.ref('users/$uid/plan').get();
    final intervalSnap = await FirebaseDatabase.instance.ref('users/$uid/interval').get();
    return _UserSub(plan: planSnap.value?.toString(), interval: intervalSnap.value?.toString());
  }

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('plans');
    final media = MediaQuery.of(context);
    final maxH = media.size.height * (upgradeStyle["usePercentHeightodMediaQuery"] as num).toDouble();
    final outerH = (upgradeStyle['outerMarginH'] as num).toDouble();
    final widthDelta = (upgradeStyle['widgetWidthDelta'] as num).toDouble();
    final desiredContentWidth = (media.size.width - 2 * outerH + widthDelta).clamp(0.0, media.size.width);

    return FutureBuilder<_UserSub?>(
      future: _userSubFuture,
      builder: (context, userSubSnap) {
        final userSub = userSubSnap.data;
        return Material(
          color: Colors.transparent,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxH),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: outerH,
                vertical: (upgradeStyle['outerMarginV'] as num).toDouble(),
              ),
              child: SizedBox(
                width: desiredContentWidth,
                child: StreamBuilder<DatabaseEvent>(
                  stream: ref.onValue,
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting && !snap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snap.hasData || snap.data?.snapshot.value == null) {
                      return const Center(child: Text('No plans found'));
                    }

                    final dynamic raw = snap.data!.snapshot.value;
                    final dynamic v = jsonDecode(jsonEncode(raw));

                    final List<_Plan> plans = [];
                    if (v is Map) {
                      v.forEach((k, value) {
                        if (k == 'lion') return;
                        if (value is Map) plans.add(_Plan(key: k.toString(), data: Map<String, dynamic>.from(value)));
                      });
                    } else if (v is List) {
                      for (var i = 0; i < v.length; i++) {
                        final e = v[i];
                        if (e is Map) {
                          final key = '$i';
                          if (key != 'lion') plans.add(_Plan(key: key, data: Map<String, dynamic>.from(e)));
                        }
                      }
                    }

                    final order = ['kitten', 'cat', 'tiger'];
                    plans.sort((a, b) {
                      final ia = order.indexOf(a.key);
                      final ib = order.indexOf(b.key);
                      final ra = ia < 0 ? 1 << 20 : ia;
                      final rb = ib < 0 ? 1 << 20 : ib;
                      if (ra != rb) return ra.compareTo(rb);
                      return a.key.compareTo(b.key);
                    });

                    final start = (upgradeStyle['panelOpacityStart'] as num).toDouble();
                    final step = (upgradeStyle['panelOpacityStep'] as num).toDouble();
                    final opacities = List<double>.generate(plans.length, (i) {
                      final op = start + step * i;
                      return op.clamp(0.0, 1.0);
                    });

                    final topPad = (upgradeStyle["topHeadingTopPad"] as num).toDouble();
                    final topColor = _c(context, upgradeStyle['topHeadingColorKey']);
                    final topFs = (upgradeStyle['topHeadingFontSize'] as num).toDouble();
                    final topFw = (upgradeStyle['topHeadingFontWeight'] as FontWeight);
                    final topLs = (upgradeStyle['topHeadingLetterSpacing'] as num).toDouble();
                    final topGap = (upgradeStyle['topHeadingBottomGap'] as num).toDouble();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: topPad),
                        Center(
                          child: Text(
                            'Choose a Plan',
                            textAlign: TextAlign.center,
                            style: appFonts['caption']!(topFs).copyWith(
                              fontWeight: topFw,
                              letterSpacing: topLs,
                              color: topColor,
                            ),
                          ),
                        ),
                        SizedBox(height: topGap),
                        SizedBox(
                          height: (upgradeStyle['tabsHeight'] as num).toDouble(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _PeriodTab(
                                label: 'Monthly',
                                selected: _tabIndex == 0,
                                onTap: () => setState(() => _tabIndex = 0),
                              ),
                              const SizedBox(width: 12),
                              _PeriodTab(
                                label: 'Yearly',
                                selected: _tabIndex == 1,
                                onTap: () => setState(() => _tabIndex = 1),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _PlansList(
                            plans: plans,
                            opacities: opacities,
                            userSub: userSub,
                            period: _tabIndex == 0 ? _Period.monthly : _Period.yearly,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Center(
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: (upgradeStyle['compareBtnPadH'] as num).toDouble(),
                                vertical: (upgradeStyle['compareBtnPadV'] as num).toDouble(),
                              ),
                              backgroundColor: _c(context, upgradeStyle['compareBtnBgKey'])
                                  .withOpacity((upgradeStyle['compareBtnBgOpacity'] as num).toDouble()),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular((upgradeStyle['compareBtnRadius'] as num).toDouble()),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pushNamed('/plans'),
                            child: Text(
                              'Compare Plans',
                              style: TextStyle(
                                fontSize: (upgradeStyle['compareBtnFs'] as num).toDouble(),
                                fontWeight: FontWeight.w600,
                                color: _c(context, upgradeStyle['compareBtnTextColorKey']),
                              ),
                            ),
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
      },
    );
  }
}

class _PeriodTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PeriodTab({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final Color border = _c(context, 'primary');
    final Color text = selected ? _c(context, 'primary') : _c(context, 'contrast').withOpacity(0.7);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected ? 2 : 1),
        ),
        child: Text(label, style: appFonts['caption']!(upgradeStyle['tabFs']).copyWith(color: text)),
      ),
    );
  }
}

enum _Period { monthly, yearly }

class _PlansList extends StatelessWidget {
  final List<_Plan> plans;
  final List<double> opacities;
  final _UserSub? userSub;
  final _Period period;
  const _PlansList({
    required this.plans,
    required this.opacities,
    required this.userSub,
    required this.period,
  });

  double _monthlyPriceOf(Map<String, dynamic> m) {
    return (m['month'] is num) ? (m['month'] as num).toDouble() : double.tryParse('${m['month']}') ?? 0.0;
  }

  double _yearlyPriceOf(Map<String, dynamic> m) {
    final y = (m['year'] is num) ? (m['year'] as num).toDouble() : double.tryParse('${m['year']}');
    if (y != null && y > 0) return y;
    final mth = _monthlyPriceOf(m);
    return mth * 12.0;
  }

  @override
  Widget build(BuildContext context) {
    final topGapToFirst = (upgradeStyle['tabsToFirstItemGap'] as num).toDouble();
    final listBottomPadding = (upgradeStyle['listBottomPadding'] as num).toDouble();
    final gap = (upgradeStyle['boxGap'] as num).toDouble();
    final headingGap = (upgradeStyle['headingToPanelGap'] as num).toDouble();
    final headingOffsetX = (upgradeStyle['headingOffsetX'] as num).toDouble();
    final headingColor = _c(context, upgradeStyle['headingColorKey']);
    final headingFs = (upgradeStyle['headingFontSize'] as num).toDouble();
    final headingFw = (upgradeStyle['headingFontWeight'] as FontWeight);
    final headingLs = (upgradeStyle['headingLetterSpacing'] as num).toDouble();

    return ScrollConfiguration(
      behavior: const _NoGlowScrollBehavior(),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.only(bottom: listBottomPadding, top: topGapToFirst),
        physics: const ClampingScrollPhysics(),
        itemCount: plans.length,
        separatorBuilder: (_, __) => SizedBox(height: gap),
        itemBuilder: (context, i) {
          final p = plans[i];
          final opacity = opacities[i];
          final locale = Localizations.localeOf(context).languageCode;

          final title = _cap(p.key);
          final monthlyPrice = _monthlyPriceOf(p.data);
          final yearlyPrice = _yearlyPriceOf(p.data);

          String? savingsText;
          bool savingsUseSecondary = false;

          final userPlan = userSub?.plan;
          final userInterval = userSub?.interval;

          if (period == _Period.monthly) {
            if (userPlan == p.key && userInterval == 'm') {
              savingsText = tr('currentplan', locale);
              savingsUseSecondary = false;
            } else {
              savingsText = null;
            }
          } else {
            if (userPlan == p.key && userInterval == 'y') {
              savingsText = tr('currentplan', locale);
              savingsUseSecondary = false;
            } else if (p.key != 'kitten') {
              final baseline = monthlyPrice * 12.0;
              final save = (baseline > 0) ? ((1 - (yearlyPrice / baseline)) * 100.0) : 0.0;
              if (save > 0) {
                savingsText = 'You save ${save.toStringAsFixed(0)}%';
                savingsUseSecondary = true;
              } else {
                savingsText = null;
              }
            } else {
              savingsText = null;
            }
          }

          final price = (period == _Period.monthly) ? monthlyPrice : yearlyPrice;
          final desc = tr(p.key, locale);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Transform.translate(
                offset: Offset(headingOffsetX, 0),
                child: Text(
                  title,
                  style: appFonts['caption']!(headingFs).copyWith(
                    fontWeight: headingFw,
                    letterSpacing: headingLs,
                    color: headingColor,
                  ),
                ),
              ),
              SizedBox(height: headingGap),
              _PlanPanel(
                description: desc,
                savingsText: savingsText,
                savingsUseSecondary: savingsUseSecondary,
                price: price,
                radius: (upgradeStyle['boxRadius'] as num).toDouble(),
                panelOpacity: opacity,
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PlanPanel extends StatelessWidget {
  final String description;
  final String? savingsText;
  final bool savingsUseSecondary;
  final double price;
  final double radius;
  final double panelOpacity;
  final VoidCallback? onTap;

  const _PlanPanel({
    required this.description,
    required this.savingsText,
    required this.savingsUseSecondary,
    required this.price,
    required this.radius,
    required this.panelOpacity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final padV = (upgradeStyle['boxPadV'] as num).toDouble();
    final padH = (upgradeStyle['boxPadH'] as num).toDouble();

    final panelBase = _c(context, upgradeStyle['panelBgColor']);
    final panelBgColor = panelBase.withOpacity(panelOpacity);

    final descBg = _c(context, upgradeStyle['pillBgKey']);
    final descFg = _c(context, upgradeStyle['pillFgKey']);
    final pillFs = (upgradeStyle['pillFontSize'] as num).toDouble();
    final pillFw = (upgradeStyle['pillFontWeight'] as FontWeight);
    final pillPadH = (upgradeStyle['pillPadH'] as num).toDouble();
    final pillPadV = (upgradeStyle['pillPadV'] as num).toDouble();

    final priceColor = upgradeStyle['priceColor'] as Color;
    final priceFs = (upgradeStyle['priceFontSize'] as num).toDouble();
    final priceFw = (upgradeStyle['priceFontWeight'] as FontWeight);

    final offsetX = (upgradeStyle['pillBadgeOffsetX'] as num).toDouble();
    final offsetY = (upgradeStyle['pillBadgeOffsetY'] as num).toDouble();

    final double panelH = (upgradeStyle['panelHeight'] as num).toDouble();
    final bool useFixedHeight = panelH > 0;

    final content = Material(
      color: panelBgColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: padV, horizontal: padH),
          child: Column(
            mainAxisAlignment: useFixedHeight ? MainAxisAlignment.center : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: pillPadH, vertical: pillPadV),
                    decoration: ShapeDecoration(color: descBg, shape: const StadiumBorder()),
                    child: Text(
                      description,
                      style: TextStyle(fontSize: pillFs, fontWeight: pillFw, color: descFg, height: 1.0),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    price <= 0 ? 'Free' : '${price.toStringAsFixed(2)} USD',
                    style: TextStyle(fontSize: priceFs, fontWeight: priceFw, color: priceColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    final badge = (savingsText != null)
        ? Positioned(
            right: -offsetX,
            bottom: -offsetY,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: pillPadH, vertical: pillPadV),
              decoration: const ShapeDecoration(shape: StadiumBorder(), color: Colors.black),
              child: Text(
                savingsText!,
                style: TextStyle(
                  fontSize: pillFs,
                  fontWeight: pillFw,
                  color: savingsUseSecondary ? _c(context, 'secondary') : descFg,
                ),
              ),
            ),
          )
        : const SizedBox.shrink();

    final core = Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: content),
        if (savingsText != null) badge,
      ],
    );

    return useFixedHeight ? SizedBox(height: panelH, child: core) : core;
  }
}

class _Plan {
  final String key;
  final Map<String, dynamic> data;
  _Plan({required this.key, required this.data});
}

class _UserSub {
  final String? plan;
  final String? interval;
  _UserSub({required this.plan, required this.interval});
}

class _NoGlowScrollBehavior extends ScrollBehavior {
  const _NoGlowScrollBehavior();
  @override
  Widget buildOverscrollIndicator(BuildContext context, Widget child, ScrollableDetails details) => child;
}
