import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/journal_category.dart';

class FilterChips extends StatefulWidget {
  const FilterChips({
    super.key,
    required this.onChanged,
    this.selected = JournalCategoryFilter.all,
  });

  final ValueChanged<String> onChanged;
  final String selected;

  @override
  State<FilterChips> createState() => _FilterChipsState();
}

class _FilterChipsState extends State<FilterChips> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void didUpdateWidget(FilterChips oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      _selected = widget.selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: JournalCategoryFilter.options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final label = JournalCategoryFilter.options[index];
          final selected = _selected == label;
          return GestureDetector(
            onTap: () {
              setState(() => _selected = label);
              widget.onChanged(label);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border,
                ),
                boxShadow: selected ? null : AppTheme.cardShadow,
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected ? Colors.white : AppTheme.textMuted,
                      fontSize: 14,
                    ),
              ),
            ),
          );
        },
      ),
    );
  }
}
