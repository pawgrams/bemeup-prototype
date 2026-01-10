// Datei: pages\wallet\balances.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../../widgets/contents/fonts.dart';
import '../../widgets/elements/tooltip.dart';
import '../../translations/translations.dart';
import '../../context/dummy_logged_user.dart';

final Map<String, dynamic> balancesStyle = {
  'outerMarginH': 14.0,
  'outerMarginV': 12.0,
  'boxPadV': 12.0,
  'boxRadius': 12.0,
  'boxGap': 14.0,
  'captionFontSize': 16.0,
  'captionLetterSpacing': 1.2,
  'captionFontWeight': FontWeight.w700,
  'captionColorKeyLeft': 'primary',
  'captionColorKeyRight': 'primary',
  'valueFontSize': 14.0,
  'valueFontWeight': FontWeight.bold,
  'valueColorKey': 'contrast',
  'boxBgOpacity': 0.7,
  'boxBgKey': 'base',
  'lineGap': 4.0,
  'tooltipIconSize': 12.0,
  'tooltipSpacing': 6.0,
};

class Balances extends StatefulWidget {
  final String? userUuid;
  const Balances({super.key, this.userUuid});

  @override
  State<Balances> createState() => _BalancesState();
}

class _BalancesState extends State<Balances> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userBalancesProvider.loadBalances(
        userUuid: widget.userUuid,
        resetVCredits: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: userBalancesProvider,
      builder: (context, _) {
        final lineGap  = balancesStyle["lineGap"];
        final isLoading = userBalancesProvider.loading;
        final credits   = userBalancesProvider.getVCredits;
        final earnings  = userBalancesProvider.getVEarnings;
        final currency  = userBalancesProvider.getCurrency;

        Color balancesColor(String key) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final themeMap = isDark ? darkThemeMap : lightThemeMap;
          return themeMap[key] ?? Colors.blue;
        }

        Widget captionWithTooltip(String textKey, String tooltipKey, String colorKey) {
          final locale = Localizations.localeOf(context).languageCode;
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                tr(textKey, locale),
                style: appFonts['caption']!(balancesStyle['captionFontSize']).copyWith(
                  fontWeight: balancesStyle['captionFontWeight'],
                  color: balancesColor(colorKey),
                  letterSpacing: balancesStyle["captionLetterSpacing"]
                ),
              ),
              infoTooltip(
                context: context,
                text: tr('tt_$tooltipKey', locale),
                size: balancesStyle['tooltipIconSize'],
                spacing: balancesStyle['tooltipSpacing'],
              ),
            ],
          );
        }

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(
            horizontal: balancesStyle['outerMarginH'],
            vertical: balancesStyle['outerMarginV'],
          ),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: balancesStyle['boxPadV']),
                        decoration: BoxDecoration(
                          color: balancesColor(balancesStyle['boxBgKey'])
                              .withOpacity(balancesStyle['boxBgOpacity']),
                          borderRadius: BorderRadius.circular(balancesStyle['boxRadius']),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            captionWithTooltip('credits', 'credits', balancesStyle['captionColorKeyLeft']),
                            SizedBox(height: lineGap),
                            Text(
                              "$credits",
                              style: appFonts['text']!(balancesStyle['valueFontSize']).copyWith(
                                fontWeight: balancesStyle['valueFontWeight'],
                                color: balancesColor(balancesStyle['valueColorKey']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: balancesStyle['boxGap']),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: balancesStyle['boxPadV']),
                        decoration: BoxDecoration(
                          color: balancesColor(balancesStyle['boxBgKey'])
                              .withOpacity(balancesStyle['boxBgOpacity']),
                          borderRadius: BorderRadius.circular(balancesStyle['boxRadius']),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            captionWithTooltip('earnings', 'earnings', balancesStyle['captionColorKeyRight']),
                            SizedBox(height: lineGap),
                            Text(
                              "${earnings.toStringAsFixed(2)} ${currency.toUpperCase()}",
                              style: appFonts['text']!(balancesStyle['valueFontSize']).copyWith(
                                fontWeight: balancesStyle['valueFontWeight'],
                                color: balancesColor(balancesStyle['valueColorKey']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
