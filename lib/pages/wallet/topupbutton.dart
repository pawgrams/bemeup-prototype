// Datei: pages/wallet/topupbutton.dart
import 'package:flutter/material.dart';
import '../../../theme/dark.dart';
import '../../../theme/light.dart';
import '../../widgets/popup.dart';
import 'topupwidget.dart';

final Map<String, dynamic> panelStyle = {
  'ButtonFontSize': 14.0,
  'ButtonHeight': 24.0,
  'ButtonPaddingH': 10.0,
  'ButtonPaddingV': 0.0,
  'ButtonRadius': 16.0,
  'ButtonGap': 14.0,
  'ButtonAlignY': 0.0,
  'ButtonBoxShadowColor': Colors.black,
  'ButtonBoxShadowBlur': 6.0,
  'ButtonBoxShadowSpread': 2.0,
  'ButtonBoxShadowOpacity': 0.8,
  'ButtonBoxShadowOffsetX': 0.0,
  'ButtonBoxShadowOffsetY': 0.0,
  'GlowBlur': 6.0,
  'GlowSpread': 2.0,
  'GlowOpacity': 1.0,
  'iconSize': 14.0,
  'TopupLabel': 'Topup',
  'WithdrawLabel': 'Withdraw',
  'WithdrawOpacity': 0.85,
  'WithdrawEnabled': false,
  'WithdrawHasShadow': false,
  'HorizontalMargin': 14.0,
  'VerticalMargin': 12.0,
  'LabelSpacing': 6.0,
};

Color panelColor(BuildContext context, String key) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final themeMap = isDark ? darkThemeMap : lightThemeMap;
  final c = themeMap[key];
  if (c is Color) return c;
  if (key == "black") return Colors.black;
  if (key == "grey") return Colors.grey;
  return Colors.blue;
}

class TopUpButtonsRow extends StatelessWidget {
  final VoidCallback? onPressed1; 
  final VoidCallback? onPressed2;

  const TopUpButtonsRow({
    super.key,
    this.onPressed1,
    this.onPressed2,
  });

  void _openTopupPopup(BuildContext context) {
    showPopup(
      yOffset: 0,
      child: const TopUpWidget(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double h = (panelStyle['ButtonHeight'] as num).toDouble();
    final double fontSize = (panelStyle['ButtonFontSize'] as num).toDouble();
    final double iconSize = (panelStyle['iconSize'] as num).toDouble();
    final double gap = (panelStyle['ButtonGap'] as num).toDouble();
    final Color prim = panelColor(context, 'primary');
    final Color base = panelColor(context, 'base');
    final double horizMargin = (panelStyle['HorizontalMargin'] as num).toDouble();
    final double vertMargin = (panelStyle['VerticalMargin'] as num).toDouble();

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: horizMargin, vertical: vertMargin),
      child: Row(
        children: [
          Expanded(
            child: _buildButton(
              context: context,
              h: h,
              fontSize: fontSize,
              iconSize: iconSize,
              prim: prim,
              base: base,
              label: panelStyle['TopupLabel'],
              icon: Icons.arrow_circle_up,
              onPressed: onPressed1 ?? () => _openTopupPopup(context),
              enabled: true,
              opacity: 1.0,
              hasShadow: true,
              glow: true,
            ),
          ),
          SizedBox(width: gap),
          Expanded(
            child: _buildButton(
              context: context,
              h: h,
              fontSize: fontSize,
              iconSize: iconSize,
              prim: prim,
              base: base,
              label: panelStyle['WithdrawLabel'],
              icon: Icons.arrow_circle_down,
              onPressed: panelStyle['WithdrawEnabled'] ? (onPressed2 ?? () {}) : null,
              enabled: panelStyle['WithdrawEnabled'],
              opacity: (panelStyle['WithdrawOpacity'] as num).toDouble(),
              hasShadow: panelStyle['WithdrawHasShadow'],
              glow: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required BuildContext context,
    required double h,
    required double fontSize,
    required double iconSize,
    required Color prim,
    required Color base,
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required bool enabled,
    required double opacity,
    required bool hasShadow,
    required bool glow,
  }) {
    final Color textColor = prim.withOpacity(enabled ? 1.0 : opacity);
    return Opacity(
      opacity: enabled ? 1.0 : opacity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(h / 2),
          boxShadow: [
            if (hasShadow)
              BoxShadow(
                color: (panelStyle['ButtonBoxShadowColor'] as Color)
                    .withOpacity((panelStyle['ButtonBoxShadowOpacity'] as num).toDouble()),
                blurRadius: (panelStyle['ButtonBoxShadowBlur'] as num).toDouble(),
                spreadRadius: (panelStyle['ButtonBoxShadowSpread'] as num).toDouble(),
                offset: Offset(
                  (panelStyle['ButtonBoxShadowOffsetX'] as num).toDouble(),
                  (panelStyle['ButtonBoxShadowOffsetY'] as num).toDouble(),
                ),
              ),
            if (glow)
              BoxShadow(
                color: prim.withOpacity((panelStyle['GlowOpacity'] as num).toDouble()),
                blurRadius: (panelStyle['GlowBlur'] as num).toDouble(),
                spreadRadius: (panelStyle['GlowSpread'] as num).toDouble(),
              ),
          ],
        ),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: (panelStyle['ButtonPaddingH'] as num).toDouble(),
              vertical: (panelStyle['ButtonPaddingV'] as num).toDouble(),
            ),
            minimumSize: Size(h, h + 5),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            backgroundColor: base.withOpacity(1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular((panelStyle['ButtonRadius'] as num).toDouble()),
            ),
          ),
          onPressed: enabled ? onPressed : null,
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: textColor),
              SizedBox(width: (panelStyle['LabelSpacing'] as num).toDouble()),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
