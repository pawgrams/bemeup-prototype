// Datei: widgets/header.dart
import 'package:flutter/material.dart';
import 'elements/pagetitle.dart';
import 'elements/options.dart';

class PageAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? tooltip;
  final VoidCallback? onBack;
  final VoidCallback? onOptionsTap;
  final Widget? middleWidget;

  const PageAppBar({
    super.key,
    required this.title,
    this.tooltip,
    this.onBack,
    this.onOptionsTap,
    this.middleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? Colors.black.withOpacity(0.4)
        : Colors.white.withOpacity(0.6);

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Row(
        children: [
          const SizedBox(width: 16),
          Expanded(
            child: tooltip != null
                ? pageTitleWithTooltip(
                    context: context,
                    text: title,
                    tooltip: tooltip!,
                    onBack: onBack ?? () => Navigator.of(context).maybePop(),
                  )
                : GestureDetector(
                    onTap: onBack ?? () => Navigator.of(context).maybePop(),
                    child: Text(title),
                  ),
          ),
          if (middleWidget != null) Padding(
            padding: const EdgeInsets.only(right: 8),
            child: middleWidget!,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OptionsIcon(onTap: onOptionsTap),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
