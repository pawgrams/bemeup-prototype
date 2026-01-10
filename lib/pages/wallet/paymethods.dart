// Datei: pages/wallet/paymethods.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/contents/fonts.dart';
import '../../widgets/getThumb.dart';
import '../../widgets/styles/scrollbar.dart';

final Map<String, dynamic> payStyle = {
  'usePercentHeightodMediaQuery': 0.55,
  'outerMarginH': 6.0,
  'outerMarginV': 12.0,
  'widgetWidthDelta': 50.0,
  'boxPadV': 10.0,
  'boxPadH': 12.0,
  'boxRadius': 16.0,
  'boxGap': 14.0,
  'boxGapExtra': 10.0,
  'topHeadingTopPad': 14.0,
  'topHeadingFontSize': 16.0,
  'topHeadingFontWeight': FontWeight.w700,
  'topHeadingLetterSpacing': 1.2,
  'topHeadingColorKey': 'primary',
  'topHeadingBottomGap': 40.0,
  'listEdgePadding': 8.0,
  'listBottomPadding': 0.0,
  'headingFontSize': 15.0,
  'headingFontWeight': FontWeight.w700,
  'headingLetterSpacing': 1.2,
  'headingColorKey': 'primary',
  'headingToPanelGap': 6.0,
  'headingOffsetX': 0.0,
  'methodFontSize': 14.0,
  'methodFontWeight': FontWeight.w500,
  'methodTextColorKey': 'primary',
  'methodPillBgKey': 'base',
  'methodPillPadH': 12.0,
  'methodPillPadV': 5.0,
  'methodPillHeight': 27.0,
  'panelBgColor': 'primary',
  'panelOpacity': 0.5,
  'panelEnabledOpacity': 0.85,
  'panelDisabledColor': Colors.white,
  'panelDisabledOpacity': 0.3,
  'panelHeight': 50.0,
  'panelWidth': 180.0,
  'summaryFontSize': 16.0,
  'summaryFontWeight': FontWeight.w600,
  'summaryColorKey': 'contrast',
  'thumbPathPrefix': 'paymethods/',
  'thumbFiletype': 'png',
  'thumbFallback': 'assets/defaults/cover.png',
  'thumbGap': 10.0,
  'thumbLeftPad': 10.0,
  'thumbSizeDelta': -8.0,
  'disabledOpacity': 0.4,
  'savingsFontWeight': FontWeight.w500,
  'savingsDisabledFontWeight': FontWeight.w300,
  'savingsTextColorKey': 'secondary',
  'savingsPillBg': Colors.black,
  'savingsPillPadH': 10.0,
  'savingsPillPadV': 4.0,
  'savingsFontSizeDelta': -2.0,
  'savingsOffsetX': 16.0,
  'savingsOffsetY': 16.0,
  'scrollbarRightInset': 4.0,
  'methodOrder': <String>[
    'earnings',
    'crypto',
    'creditcard',
    'googlepay',
    'applepay',
    'paypal',
    'sepa',
    'paysafecard',
    'giftcard',
  ],
};

Color _c(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  return themeMap[key] ?? Colors.black;
}

class PayMethodsWidget extends StatelessWidget {
  final int selectedCredits;
  final double selectedPriceUsd;

  const PayMethodsWidget({
    super.key,
    required this.selectedCredits,
    required this.selectedPriceUsd,
  });

  @override
  Widget build(BuildContext context) {
    final ref = FirebaseDatabase.instance.ref('paymethods');
    final media = MediaQuery.of(context);
    final maxH = media.size.height * (payStyle["usePercentHeightodMediaQuery"] as num).toDouble();
    final outerH = (payStyle['outerMarginH'] as num).toDouble();
    final widthDelta = (payStyle['widgetWidthDelta'] as num).toDouble();
    final desiredContentWidth =
        (media.size.width - 2 * outerH + widthDelta).clamp(0.0, media.size.width);

    final topHeadingTopPad = (payStyle["topHeadingTopPad"] as num).toDouble();
    final topFs = (payStyle['topHeadingFontSize'] as num).toDouble();
    final topFw = (payStyle['topHeadingFontWeight'] as FontWeight);
    final topLs = (payStyle['topHeadingLetterSpacing'] as num).toDouble();
    final topColor = _c(context, payStyle['topHeadingColorKey']);
    final topGap = (payStyle['topHeadingBottomGap'] as num).toDouble();

    final listBottomPadding = (payStyle['listBottomPadding'] as num).toDouble();
    final listEdgePadding = (payStyle['listEdgePadding'] as num).toDouble();
    final insetRight = (payStyle['scrollbarRightInset'] as num).toDouble();

    final scrollController = ScrollController();

    return Material(
      color: Colors.transparent,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: outerH,
            vertical: (payStyle['outerMarginV'] as num).toDouble(),
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: desiredContentWidth,
              child: StreamBuilder<DatabaseEvent>(
                stream: ref.onValue,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snap.hasData || snap.data?.snapshot.value == null) {
                    return const Center(child: Text('No payment methods found'));
                  }

                  final dynamic raw = snap.data!.snapshot.value;
                  final dynamic v = jsonDecode(jsonEncode(raw));

                  final List<_Method> methods = [];
                  if (v is Map) {
                    v.forEach((key, value) {
                      if (value is Map) {
                        final m = Map<String, dynamic>.from(value);
                        final status = m['status'] == true;
                        final name = (m['name'] ?? '').toString();
                        final maxDiscount = (m['maxdiscount'] is num)
                            ? (m['maxdiscount'] as num).toDouble()
                            : double.tryParse('${m['maxdiscount']}') ?? 0.0;
                        if (name.isNotEmpty) {
                          methods.add(_Method(
                            key: key.toString(),
                            name: name,
                            enabled: status,
                            maxDiscount: maxDiscount,
                          ));
                        }
                      }
                    });
                  }

                  final order = (payStyle['methodOrder'] as List).map((e) => e.toString()).toList();
                  methods.sort((a, b) {
                    final ia = order.indexOf(a.key);
                    final ib = order.indexOf(b.key);
                    final ra = ia < 0 ? 1 << 20 : ia;
                    final rb = ib < 0 ? 1 << 20 : ib;
                    if (ra != rb) return ra.compareTo(rb);
                    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
                  });

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: topHeadingTopPad),
                      Center(
                        child: Text(
                          'Payment Method',
                          textAlign: TextAlign.center,
                          style: appFonts['caption']!(topFs).copyWith(
                            fontWeight: topFw,
                            letterSpacing: topLs,
                            color: topColor,
                          ),
                        ),
                      ),
                      SizedBox(height: topGap),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: insetRight),
                          child: HoverScrollbar(
                            controller: scrollController,
                            child: ListView.separated(
                              controller: scrollController,
                              padding: EdgeInsets.only(
                                top: listEdgePadding,
                                bottom: listBottomPadding + listEdgePadding,
                              ),
                              physics: const ClampingScrollPhysics(),
                              itemCount: methods.length,
                              separatorBuilder: (_, __) => SizedBox(
                                height: (payStyle['boxGap'] as num).toDouble() +
                                    (payStyle['boxGapExtra'] as num).toDouble(),
                              ),
                              itemBuilder: (context, i) {
                                final m = methods[i];
                                return _MethodRow(
                                  keyName: m.key,
                                  name: m.name,
                                  enabled: m.enabled,
                                  maxDiscount: m.maxDiscount,
                                  onTap: m.enabled ? () {} : null,
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: topGap),
                      Row(
                        children: [
                          const Spacer(),
                          Text(
                            '+$selectedCredits Credits   •   ${selectedPriceUsd.toStringAsFixed(2)} USD',
                            style: TextStyle(
                              fontSize: (payStyle['summaryFontSize'] as num).toDouble(),
                              fontWeight: (payStyle['summaryFontWeight'] as FontWeight),
                              color: _c(context, payStyle['summaryColorKey']),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodRow extends StatelessWidget {
  final String keyName;
  final String name;
  final bool enabled;
  final double maxDiscount;
  final VoidCallback? onTap;

  const _MethodRow({
    required this.keyName,
    required this.name,
    required this.enabled,
    required this.maxDiscount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double panelH = (payStyle['panelHeight'] as num).toDouble();
    final double panelW = (payStyle['panelWidth'] as num).toDouble();
    final double thumbGap = (payStyle['thumbGap'] as num).toDouble();
    final double thumbDelta = (payStyle['thumbSizeDelta'] as num).toDouble();
    final double thumbSize = (panelH + thumbDelta).clamp(0.0, 10000.0);
    final double thumbLeftPad = (payStyle['thumbLeftPad'] as num).toDouble();
    final Color primary = _c(context, 'primary');

    final thumbCore = Container(
      width: thumbSize,
      height: thumbSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: (maxDiscount > 0)
            ? [
                BoxShadow(
                  color: primary.withOpacity(1.0),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: GetThumb(
        uuid: keyName,
        size: thumbSize,
        path: (payStyle['thumbPathPrefix'] as String),
        filetype: (payStyle['thumbFiletype'] as String),
        fallbackPath: (payStyle['thumbFallback'] as String),
        shape: 'sphere',
      ),
    );

    return SizedBox(
      height: panelH,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: thumbLeftPad),
          Opacity(opacity: enabled ? 1.0 : 0.5, child: thumbCore),
          SizedBox(width: thumbGap),
          SizedBox(
            width: panelW,
            child: _MethodPanel(
              keyName: keyName,
              name: name,
              enabled: enabled,
              maxDiscount: maxDiscount,
              onTap: onTap,
              fixedHeight: panelH,
            ),
          ),
        ],
      ),
    );
  }
}

class _MethodPanel extends StatelessWidget {
  final String keyName;
  final String name;
  final bool enabled;
  final double maxDiscount;
  final VoidCallback? onTap;
  final double fixedHeight;

  const _MethodPanel({
    required this.keyName,
    required this.name,
    required this.enabled,
    required this.maxDiscount,
    required this.onTap,
    required this.fixedHeight,
  });

  @override
  Widget build(BuildContext context) {
    final padH = (payStyle['boxPadH'] as num).toDouble();
    final radius = (payStyle['boxRadius'] as num).toDouble();

    final panelBase = _c(context, payStyle['panelBgColor']);
    final enabledOpacity = (payStyle['panelEnabledOpacity'] as num).toDouble();
    final disabledColor = (payStyle['panelDisabledColor'] as Color);
    final disabledOpacity = (payStyle['panelDisabledOpacity'] as num).toDouble();
    final panelColor =
        enabled ? panelBase.withOpacity(enabledOpacity) : disabledColor.withOpacity(disabledOpacity);

    final textOpacity = enabled ? 1.0 : 0.5;
    final pillBg = _c(context, payStyle['methodPillBgKey']).withOpacity(textOpacity);
    final pillFg = _c(context, payStyle['methodTextColorKey']).withOpacity(textOpacity);
    final pillFs = (payStyle['methodFontSize'] as num).toDouble();
    final pillFw = (payStyle['methodFontWeight'] as FontWeight);
    final pillPadH = (payStyle['methodPillPadH'] as num).toDouble();
    final pillPadV = (payStyle['methodPillPadV'] as num).toDouble();
    final pillFixedH = (payStyle['methodPillHeight'] as num).toDouble();

    final savingsTextColor = _c(context, payStyle['savingsTextColorKey']);
    final savingsPadH = (payStyle['savingsPillPadH'] as num).toDouble();
    final savingsPadV = (payStyle['savingsPillPadV'] as num).toDouble();
    final savingsDelta = (payStyle['savingsFontSizeDelta'] as num).toDouble();
    final offsetX = (payStyle['savingsOffsetX'] as num).toDouble();
    final offsetY = (payStyle['savingsOffsetY'] as num).toDouble();
    final savingsFs = (pillFs + savingsDelta).clamp(1.0, 10000.0);

    final panel = Material(
      color: panelColor,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        splashColor: enabled ? null : Colors.transparent,
        highlightColor: enabled ? null : Colors.transparent,
        child: SizedBox(
          height: fixedHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: padH),
              Container(
                constraints: (pillFixedH > 0)
                    ? BoxConstraints(minHeight: pillFixedH, maxHeight: pillFixedH)
                    : const BoxConstraints(minHeight: 0),
                padding: EdgeInsets.symmetric(horizontal: pillPadH, vertical: pillPadV),
                decoration: ShapeDecoration(
                  shape: const StadiumBorder(),
                  color: pillBg,
                ),
                alignment: Alignment.center,
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: pillFs,
                    fontWeight: pillFw,
                    color: pillFg,
                    height: 1.0,
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(width: padH),
            ],
          ),
        ),
      ),
    );

    final bool showSavings = maxDiscount > 0 || !enabled;
    final String savingsLabel =
        !enabled ? 'not available' : 'Save up to ${maxDiscount.toStringAsFixed(0)}%';
    final TextStyle savingsStyle = TextStyle(
      fontSize: savingsFs,
      fontWeight: (enabled
          ? payStyle['savingsFontWeight'] as FontWeight
          : payStyle['savingsDisabledFontWeight'] as FontWeight),
      color: !enabled ? Colors.grey : savingsTextColor,
    );

    final savings = showSavings
        ? Positioned(
            right: -offsetX,
            bottom: -offsetY,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: savingsPadH, vertical: savingsPadV),
              decoration: ShapeDecoration(
                shape: const StadiumBorder(),
                color: (payStyle['savingsPillBg'] as Color),
              ),
              child: Text(savingsLabel, style: savingsStyle),
            ),
          )
        : const SizedBox.shrink();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(child: panel),
        if (showSavings) savings,
      ],
    );
  }
}

class _Method {
  final String key;
  final String name;
  final bool enabled;
  final double maxDiscount;
  _Method({
    required this.key,
    required this.name,
    required this.enabled,
    required this.maxDiscount,
  });
}
