import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../config/theme.dart';

/// Horizontal formatting bar — sits below the note, scroll for all tools.
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

  void _clearFormatting() {
    for (final attr in [
      Attribute.bold,
      Attribute.italic,
      Attribute.underline,
      Attribute.strikeThrough,
      Attribute.ul,
      Attribute.ol,
      Attribute.blockQuote,
    ]) {
      widget.controller.formatSelection(Attribute.clone(attr, null));
    }
    _setHeader(null);
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.compact;

    return Container(
      margin: EdgeInsets.fromLTRB(compact ? 12 : 16, 0, compact ? 12 : 16, 4),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(compact ? 16 : 20),
        border: Border.all(color: AppTheme.border),
        boxShadow: compact
            ? null
            : [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 6),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Format your letter — slide for more',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.primary,
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _ToolButton(
                  icon: Icons.undo_rounded,
                  label: compact ? null : 'Undo',
                  onTap: widget.controller.undo,
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.redo_rounded,
                  label: compact ? null : 'Redo',
                  onTap: widget.controller.redo,
                  compact: compact,
                ),
                const _ToolDivider(),
                _ToolButton(
                  icon: Icons.format_bold_rounded,
                  label: compact ? null : 'Bold',
                  selected: _isActive(Attribute.bold),
                  onTap: () => _toggle(Attribute.bold),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.format_italic_rounded,
                  label: compact ? null : 'Italic',
                  selected: _isActive(Attribute.italic),
                  onTap: () => _toggle(Attribute.italic),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.format_underlined_rounded,
                  label: compact ? null : 'Underline',
                  selected: _isActive(Attribute.underline),
                  onTap: () => _toggle(Attribute.underline),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.format_strikethrough_rounded,
                  label: compact ? null : 'Strike',
                  selected: _isActive(Attribute.strikeThrough),
                  onTap: () => _toggle(Attribute.strikeThrough),
                  compact: compact,
                ),
                const _ToolDivider(),
                _ToolButton(
                  icon: Icons.format_list_bulleted_rounded,
                  label: compact ? null : 'Bullets',
                  selected: _isActive(Attribute.ul),
                  onTap: () => _toggle(Attribute.ul),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.format_list_numbered_rounded,
                  label: compact ? null : 'Number',
                  selected: _isActive(Attribute.ol),
                  onTap: () => _toggle(Attribute.ol),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.format_quote_rounded,
                  label: compact ? null : 'Quote',
                  selected: _isActive(Attribute.blockQuote),
                  onTap: () => _toggle(Attribute.blockQuote),
                  compact: compact,
                ),
                const _ToolDivider(),
                _ToolButton(
                  icon: Icons.text_fields_rounded,
                  label: compact ? null : 'Normal',
                  selected: _currentHeaderLevel() == null,
                  onTap: () => _setHeader(null),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.title_rounded,
                  label: compact ? null : 'Title',
                  selected: _currentHeaderLevel() == 1,
                  onTap: () => _setHeader(1),
                  compact: compact,
                ),
                _ToolButton(
                  icon: Icons.text_increase_rounded,
                  label: compact ? null : 'Sub',
                  selected: _currentHeaderLevel() == 2,
                  onTap: () => _setHeader(2),
                  compact: compact,
                ),
                const _ToolDivider(),
                _ToolButton(
                  icon: Icons.format_clear_rounded,
                  label: compact ? null : 'Clear',
                  onTap: _clearFormatting,
                  compact: compact,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolDivider extends StatelessWidget {
  const _ToolDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppTheme.border,
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.onTap,
    this.label,
    this.selected = false,
    this.compact = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? label;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final width = compact ? 40.0 : (label != null ? 52.0 : 40.0);
    final height = compact ? 36.0 : 48.0;

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            width: width,
            height: height,
            decoration: BoxDecoration(
              gradient: selected
                  ? const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    )
                  : null,
              color: selected ? null : AppTheme.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? AppTheme.primaryDark : AppTheme.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: compact ? 18 : 20,
                  color: selected ? Colors.white : AppTheme.textDark,
                ),
                if (label != null && !compact) ...[
                  const SizedBox(height: 2),
                  Text(
                    label!,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white70 : AppTheme.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
