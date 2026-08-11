import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../config/theme.dart';

/// Pink queen-themed formatting bar — sits above the keyboard / Done button.
class QueenEditorToolbar extends StatefulWidget {
  const QueenEditorToolbar({
    super.key,
    required this.controller,
    this.compact = false,
  });

  final QuillController controller;
  final bool compact;

  @override
  State<QueenEditorToolbar> createState() => _QueenEditorToolbarState();
}

class _QueenEditorToolbarState extends State<QueenEditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  bool _isActive(Attribute attribute) {
    return widget.controller
        .getSelectionStyle()
        .attributes
        .containsKey(attribute.key);
  }

  void _toggle(Attribute attribute) {
    final active = _isActive(attribute);
    widget.controller.formatSelection(
      active ? Attribute.clone(attribute, null) : attribute,
    );
  }

  void _setHeader(int? level) {
    if (level == null) {
      widget.controller.formatSelection(Attribute.clone(Attribute.h1, null));
      widget.controller.formatSelection(Attribute.clone(Attribute.h2, null));
      widget.controller.formatSelection(Attribute.clone(Attribute.h3, null));
      return;
    }
    final attr = switch (level) {
      1 => Attribute.h1,
      2 => Attribute.h2,
      _ => Attribute.h3,
    };
    widget.controller.formatSelection(attr);
  }

  int? _currentHeaderLevel() {
    final attrs = widget.controller.getSelectionStyle().attributes;
    if (attrs.containsKey(Attribute.h1.key)) return 1;
    if (attrs.containsKey(Attribute.h2.key)) return 2;
    if (attrs.containsKey(Attribute.h3.key)) return 3;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.compact) {
      return Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _CompactIconButton(
                icon: Icons.undo_rounded,
                onTap: widget.controller.undo,
              ),
              _CompactIconButton(
                icon: Icons.redo_rounded,
                onTap: widget.controller.redo,
              ),
              const _CompactDivider(),
              _CompactIconButton(
                icon: Icons.format_bold_rounded,
                selected: _isActive(Attribute.bold),
                onTap: () => _toggle(Attribute.bold),
              ),
              _CompactIconButton(
                icon: Icons.format_italic_rounded,
                selected: _isActive(Attribute.italic),
                onTap: () => _toggle(Attribute.italic),
              ),
              _CompactIconButton(
                icon: Icons.format_underlined_rounded,
                selected: _isActive(Attribute.underline),
                onTap: () => _toggle(Attribute.underline),
              ),
              _CompactIconButton(
                icon: Icons.format_list_bulleted_rounded,
                selected: _isActive(Attribute.ul),
                onTap: () => _toggle(Attribute.ul),
              ),
              _CompactIconButton(
                icon: Icons.format_clear_rounded,
                onTap: () {
                  for (final attr in [
                    Attribute.bold,
                    Attribute.italic,
                    Attribute.underline,
                    Attribute.strikeThrough,
                    Attribute.ul,
                    Attribute.ol,
                    Attribute.blockQuote,
                  ]) {
                    widget.controller
                        .formatSelection(Attribute.clone(attr, null));
                  }
                  _setHeader(null);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.surface,
            AppTheme.primaryLight.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Format your letter',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.primary,
                        fontSize: 12,
                        letterSpacing: 0.3,
                      ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Row(
              children: [
                _ToolGroup(
                  label: 'Edit',
                  children: [
                    _FormatChip(
                      icon: Icons.undo_rounded,
                      label: 'Undo',
                      onTap: widget.controller.undo,
                    ),
                    _FormatChip(
                      icon: Icons.redo_rounded,
                      label: 'Redo',
                      onTap: widget.controller.redo,
                    ),
                  ],
                ),
                const _GroupDivider(),
                _ToolGroup(
                  label: 'Style',
                  children: [
                    _FormatChip(
                      icon: Icons.format_bold_rounded,
                      label: 'Bold',
                      selected: _isActive(Attribute.bold),
                      onTap: () => _toggle(Attribute.bold),
                    ),
                    _FormatChip(
                      icon: Icons.format_italic_rounded,
                      label: 'Italic',
                      selected: _isActive(Attribute.italic),
                      onTap: () => _toggle(Attribute.italic),
                    ),
                    _FormatChip(
                      icon: Icons.format_underlined_rounded,
                      label: 'Underline',
                      selected: _isActive(Attribute.underline),
                      onTap: () => _toggle(Attribute.underline),
                    ),
                    _FormatChip(
                      icon: Icons.format_strikethrough_rounded,
                      label: 'Strike',
                      selected: _isActive(Attribute.strikeThrough),
                      onTap: () => _toggle(Attribute.strikeThrough),
                    ),
                  ],
                ),
                const _GroupDivider(),
                _ToolGroup(
                  label: 'Lists',
                  children: [
                    _FormatChip(
                      icon: Icons.format_list_bulleted_rounded,
                      label: 'Bullets',
                      selected: _isActive(Attribute.ul),
                      onTap: () => _toggle(Attribute.ul),
                    ),
                    _FormatChip(
                      icon: Icons.format_list_numbered_rounded,
                      label: 'Number',
                      selected: _isActive(Attribute.ol),
                      onTap: () => _toggle(Attribute.ol),
                    ),
                    _FormatChip(
                      icon: Icons.format_quote_rounded,
                      label: 'Quote',
                      selected: _isActive(Attribute.blockQuote),
                      onTap: () => _toggle(Attribute.blockQuote),
                    ),
                  ],
                ),
                const _GroupDivider(),
                _ToolGroup(
                  label: 'Size',
                  children: [
                    _FormatChip(
                      icon: Icons.text_fields_rounded,
                      label: 'Normal',
                      selected: _currentHeaderLevel() == null,
                      onTap: () => _setHeader(null),
                    ),
                    _FormatChip(
                      icon: Icons.title_rounded,
                      label: 'Title',
                      selected: _currentHeaderLevel() == 1,
                      onTap: () => _setHeader(1),
                    ),
                    _FormatChip(
                      icon: Icons.text_increase_rounded,
                      label: 'Sub',
                      selected: _currentHeaderLevel() == 2,
                      onTap: () => _setHeader(2),
                    ),
                  ],
                ),
                const _GroupDivider(),
                _FormatChip(
                  icon: Icons.format_clear_rounded,
                  label: 'Clear',
                  accent: true,
                  onTap: () {
                    for (final attr in [
                      Attribute.bold,
                      Attribute.italic,
                      Attribute.underline,
                      Attribute.strikeThrough,
                      Attribute.ul,
                      Attribute.ol,
                      Attribute.blockQuote,
                    ]) {
                      widget.controller
                          .formatSelection(Attribute.clone(attr, null));
                    }
                    _setHeader(null);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolGroup extends StatelessWidget {
  const _ToolGroup({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 10,
                color: AppTheme.textMuted,
                letterSpacing: 0.5,
              ),
        ),
        const SizedBox(height: 6),
        Row(mainAxisSize: MainAxisSize.min, children: children),
      ],
    );
  }
}

class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 52,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: AppTheme.border,
    );
  }
}

class _FormatChip extends StatelessWidget {
  const _FormatChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.accent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final bg = selected
        ? const LinearGradient(
            colors: [AppTheme.primary, AppTheme.primaryDark],
          )
        : accent
            ? LinearGradient(
                colors: [
                  AppTheme.blush,
                  AppTheme.primaryLight.withValues(alpha: 0.6),
                ],
              )
            : null;

    final fg = selected ? Colors.white : AppTheme.textDark;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: bg,
              color: bg == null ? AppTheme.surface : null,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? AppTheme.primaryDark
                    : accent
                        ? AppTheme.roseGold
                        : AppTheme.border,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white70 : AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CompactDivider extends StatelessWidget {
  const _CompactDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppTheme.border,
    );
  }
}

class _CompactIconButton extends StatelessWidget {
  const _CompactIconButton({
    required this.icon,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: 40,
          height: 36,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? AppTheme.primaryDark : Colors.transparent,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: selected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}
