// Datei: widgets\elements\dropdown.dart
import 'package:flutter/material.dart';
import '../../theme/dark.dart';
import '../../theme/light.dart';
import '../styles/edges.dart';
import '../styles/glow_element.dart';
import '../styles/shadow_element.dart';
import 'inputs.dart';
import '../styles/scrollbar.dart';

final Map<String, dynamic> dropdownStyle = {
  'lineHeight': 40,
  'visibleLines': 5,
};

class SimpleDropdownInput extends StatefulWidget {
  final List<String> options;
  final void Function(String)? onChanged;
  final String? initialValue;
  final String hint;

  const SimpleDropdownInput({
    Key? key,
    required this.options,
    this.onChanged,
    this.initialValue,
    this.hint = '',
  }) : super(key: key);

  @override
  State<SimpleDropdownInput> createState() => _SimpleDropdownInputState();
}

class _SimpleDropdownInputState extends State<SimpleDropdownInput> {
  late final TextEditingController _controller;
  bool _open = false;
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _fieldKey = GlobalKey();
  final double lineHeight = dropdownStyle['lineHeight'].toDouble();
  final double visibleLines = dropdownStyle['visibleLines'].toDouble();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode.addListener(() {
      if (!mounted) return;
      setState(() => _open = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = inputActive;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = isDark ? darkThemeMap : lightThemeMap;
    final isFocused = _open;

    return ShadowElement(
      blur: 20,
      opacity: 0.8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        decoration: BoxDecoration(
          borderRadius: appEdges(),
          boxShadow: buildGlow(
            isFocused: isFocused,
            color: theme[style['borderColor']]!,
          ),
        ),
        child: Column(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final ScrollController scrollController = ScrollController();

                return Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    TextField(
                      key: _fieldKey,
                      controller: _controller,
                      focusNode: _focusNode,
                      style: const TextStyle(fontSize: 14),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: buildInputDecoration(
                        style,
                        isDark,
                        widget.hint,
                        isFocused,
                        1,
                      ).copyWith(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 11,
                        ),
                        suffixIcon: null,
                      ),
                      onTap: () {
                        _focusNode.requestFocus();
                        _controller.selection = TextSelection(
                          baseOffset: 0,
                          extentOffset: _controller.text.length,
                        );
                        if (!mounted) return;
                        setState(() => _open = true);
                      },
                      onChanged: (_) {
                        if (!mounted) return;
                        setState(() {});
                      },
                    ),
                    Theme(
                      data: Theme.of(context).copyWith(
                        scaffoldBackgroundColor: theme[style['bgColor']],
                        cardColor: theme[style['bgColor']],
                        shadowColor: theme[style['borderColor']],
                        hoverColor:
                            theme[style['itemHover']]!.withOpacity(0.1),
                        popupMenuTheme: PopupMenuThemeData(
                          color: theme[style['bgColor']],
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: appEdges(),
                            side: BorderSide(
                              color: theme[style['borderColor']]!,
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: theme[style['fontColor']],
                        ),
                        offset: Offset(0, lineHeight),
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                          maxWidth: constraints.maxWidth,
                        ),
                        onOpened: () => _focusNode.requestFocus(),
                        onCanceled: () => _focusNode.unfocus(),
                        onSelected: (value) {
                          final current = _controller.text.trim();
                          final next = current.isEmpty ? value : '$current; $value';
                          _controller.text = next;
                          _controller.selection = TextSelection.collapsed(offset: next.length);
                          widget.onChanged?.call(next);
                          _focusNode.unfocus();
                        },
                        itemBuilder: (_) {
                          final items = widget.options.map((o) {
                            return PopupMenuItem<String>(
                              value: o,
                              child: Text(
                                o,
                                style: TextStyle(
                                  color: theme[style['fontColor']],
                                ),
                              ),
                            );
                          }).toList();

                          return [
                            PopupMenuItem<String>(
                              enabled: false,
                              height: 0,
                              padding: const EdgeInsets.only(top: 8),
                              child: const SizedBox.shrink(),
                            ),
                            PopupMenuItem<String>(
                              enabled: false,
                              child: Container(
                                constraints: BoxConstraints(
                                  maxHeight: visibleLines * lineHeight,
                                ),
                                child: ScrollConfiguration(
                                behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                                child: HoverScrollbar(
                                  controller: scrollController,
                                  child: ListView(
                                    controller: scrollController,
                                    padding: EdgeInsets.zero,
                                    children: items,
                                  ),
                                ),
                              ),
                              ),
                            ),
                            PopupMenuItem<String>(
                              enabled: false,
                              height: 0,
                              padding: const EdgeInsets.only(bottom: 8),
                              child: const SizedBox.shrink(),
                            ),
                          ];
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 2),
          ],
        ),
      ),
    );
  }
}
