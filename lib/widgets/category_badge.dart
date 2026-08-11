import 'package:flutter/material.dart';

import '../config/theme.dart';
import '../models/journal_category.dart';

class CategoryBadge extends StatelessWidget {
  const CategoryBadge({
    super.key,
    required this.category,
    this.compact = false,
    this.light = false,
  });

  final JournalCategory category;
  final bool compact;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fg = light ? Colors.white : AppTheme.primary;
    final bg = light
        ? Colors.white.withValues(alpha: 0.2)
        : AppTheme.primaryLight;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: light ? null : Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(category.icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 4),
          Text(
            category.label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontSize: compact ? 10 : 11,
                ),
          ),
        ],
      ),
    );
  }
}

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final JournalCategory selected;
  final ValueChanged<JournalCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: AppTheme.textMuted,
                fontSize: 12,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: JournalCategory.values.map((cat) {
            final isSelected = cat == selected;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: cat != JournalCategory.values.last ? 8 : 0,
                ),
                child: GestureDetector(
                  onTap: () => onChanged(cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? const LinearGradient(
                              colors: [AppTheme.primary, AppTheme.primaryDark],
                            )
                          : null,
                      color: isSelected ? null : AppTheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryDark : AppTheme.border,
                      ),
                      boxShadow: isSelected ? AppTheme.primaryShadow : null,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          cat.icon,
                          size: 18,
                          color: isSelected ? Colors.white : AppTheme.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat.label,
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontSize: 10,
                                color: isSelected ? Colors.white : AppTheme.textMuted,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
