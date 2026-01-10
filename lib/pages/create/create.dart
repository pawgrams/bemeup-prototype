// Datei: frontend\lib\pages\create\create.dart
import 'package:flutter/material.dart';
import '../../widgets/elements/fieldtitles.dart';
import '../../widgets/elements/inputs.dart';
import '../../widgets/elements/dropdown.dart';
import '../../widgets/elements/button.dart';
import '../../translations/translations.dart';
import '../../widgets/contents/genres.dart';
import '../../widgets/contents/songlangs.dart';
import '../../widgets/contents/voices.dart';
import 'createFormController.dart';

class Create extends StatefulWidget {
  const Create({super.key});

  @override
  State<Create> createState() => _CreateState();
}

class _CreateState extends State<Create> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final routeName = ModalRoute.of(context)?.settings.name?.replaceAll('/', '').toLowerCase() ?? '';
    final locale = Localizations.localeOf(context).languageCode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          styledFieldTitleWithTooltip(
            context: context,
            textKey: 'genre',
            tooltipCategory: routeName,
            tooltipKey: 'genre',
          ),
          ValueListenableBuilder<String?>(
            valueListenable: CreateFormController.genreController,
            builder: (context, value, _) => SimpleDropdownInput(
              options: genres,
              initialValue: value,
              hint: tr('ph_sel_type', locale),
              onChanged: (val) => CreateFormController.genreController.value = val,
            ),
          ),
          SizedBox(height: 12),
          styledFieldTitleWithTooltip(
            context: context,
            textKey: 'style',
            tooltipCategory: routeName,
            tooltipKey: 'style',
          ),
          styledInputField(
            context: context,
            style: inputActive,
            controller: CreateFormController.styleController,
            hint: tr('ph_type_gen', locale),
            lines: 2,
          ),
          SizedBox(height: 12),
          styledFieldTitleWithTooltip(
            context: context,
            textKey: 'voice',
            tooltipCategory: routeName,
            tooltipKey: 'voice',
          ),
          ValueListenableBuilder<String?>(
            valueListenable: CreateFormController.voiceController,
            builder: (context, value, _) => SimpleDropdownInput(
              options: voices,
              initialValue: value,
              hint: tr('ph_sel_type', locale),
              onChanged: (val) => CreateFormController.voiceController.value = val,
            ),
          ),
          SizedBox(height: 12),
          styledFieldTitleWithTooltip(
            context: context,
            textKey: 'language',
            tooltipCategory: routeName,
            tooltipKey: 'language',
          ),
          ValueListenableBuilder<String?>(
            valueListenable: CreateFormController.langController,
            builder: (context, value, _) => SimpleDropdownInput(
              options: songlangLabels,
              initialValue: value,
              hint: tr('ph_sel_type', locale),
              onChanged: (val) => CreateFormController.langController.value = val,
            ),
          ),
          SizedBox(height: 12),
          styledFieldTitleWithTooltip(
            context: context,
            textKey: 'lyrics',
            tooltipCategory: routeName,
            tooltipKey: 'lyrics',
          ),
          styledInputField(
            context: context,
            style: inputActive,
            controller: CreateFormController.lyricsController,
            hint: tr('ph_type_gen', locale),
            lines: 5,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: styledButton(
              context: context,
              style: buttonActive,
              onPressed: () {/**/},
              textKey: 'btn_create',
            ),
          ),
          SizedBox(height: 100),
        ],
      ),
    );
  }
}
