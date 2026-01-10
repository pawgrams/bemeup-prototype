// Datei: layout.dart
import 'package:flutter/material.dart';
import 'widgets/menu.dart';
import 'widgets/header.dart';
import 'translations/translations.dart';
import 'widgets/styles/scrollbar.dart';
import 'widgets/elements/background.dart';
import 'widgets/contents/page_bg.dart';
import 'widgets/utils/childscroll.dart';
import '../../widgets/player.dart';
import 'widgets/minipopup.dart';
import 'widgets/popup.dart';

class AppLayout extends StatelessWidget {
  final Widget child;
  final String pageTitle;
  final String? tooltipCategory;
  final VoidCallback? onBack;
  final String? customImagePath;
  final Widget? appBarMiddle;

  const AppLayout({
    super.key,
    required this.child,
    required this.pageTitle,
    this.tooltipCategory,
    this.onBack,
    this.customImagePath,
    this.appBarMiddle,
  });

  Widget buildShiftedContent(Widget child) {
    return Transform.translate(
      offset: const Offset(0, -0.2),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final tooltipKey = 'tt_${tooltipCategory ?? ''}';
    final tooltipText = tr(tooltipKey, locale);
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final size = MediaQuery.of(context).size;

    String bgImage = pageToBg[pageTitle.toLowerCase()] ?? pageToBg['blank']!;
    final bool isBlank = (pageToBg[pageTitle.toLowerCase()] == null) || (pageTitle.toLowerCase() == 'blank');

    Widget buildScrollable(Widget inner) {
      final controller = ScrollController();
      return Builder(
        builder: (context) => HoverScrollbar(
          controller: controller,
          child: SingleChildScrollView(
            controller: controller,
            child: inner,
          ),
        ),
      );
    }

    Widget mainLayout;

    if (isPortrait) {
      mainLayout = Scaffold(
        backgroundColor: Colors.transparent,
        body: PageStorage(
          bucket: PageStorageBucket(),
          child: childScrollWrapper(
            context,
            pageTitle,
            buildShiftedContent(child),
            buildScrollable,
          ),
        ),
        bottomNavigationBar: const Menu(),
        appBar: PageAppBar(
          title: tr('pg_${pageTitle}', locale),
          tooltip: tooltipText,
          onBack: onBack,
          middleWidget: appBarMiddle,
        ),
      );
    } else {
      const double maxMenuWidth = 90;
      final double targetMenuWidth = size.width * 0.13;
      final double menuWidth = targetMenuWidth > maxMenuWidth ? maxMenuWidth : targetMenuWidth;
      mainLayout = Scaffold(
        backgroundColor: Colors.transparent,
        body: Row(
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                minWidth: 60,
                maxWidth: maxMenuWidth,
              ),
              child: SizedBox(
                width: menuWidth,
                child: const Menu(),
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: size.height * 0.1,
                    child: PageAppBar(
                      title: tr('pg_${pageTitle}', locale),
                      tooltip: tooltipText,
                      onBack: onBack,
                      middleWidget: appBarMiddle,
                    ),
                  ),
                  PageStorage(
                    bucket: PageStorageBucket(),
                    child: childScrollWrapper(
                      context,
                      pageTitle,
                      buildShiftedContent(child),
                      buildScrollable,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        DeviceBackground(
          imageName: bgImage,
          blank: (customImagePath == null) && isBlank,
          customImagePath: customImagePath,
        ),
        mainLayout,
        const PopupOverlay(),
        const PlayerWidget(),
        MiniPopupOverlay(),
      ],
    );
  }
}
