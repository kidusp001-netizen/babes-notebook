import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/journal_entry.dart';

/// Full month grid for browsing notes on any past date.
class JournalMonthCalendar extends StatelessWidget {
  const JournalMonthCalendar({
    super.key,
    required this.focusedMonth,
    required this.selectedDate,
    required this.datesWithEntries,
    required this.onDateSelected,
    required this.onMonthChanged,
    this.onMonthLabelTap,
  });

  final DateTime focusedMonth;
  final DateTime selectedDate;
  final Set<DateTime> datesWithEntries;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<DateTime> onMonthChanged;
  final VoidCallback? onMonthLabelTap;

  static final _firstMonth = DateTime(2020, 1);

  DateTime get _today => JournalEntry.normalizeDate(DateTime.now());

  DateTime get _normalizedFocus =>
      DateTime(focusedMonth.year, focusedMonth.month);

  bool get _canGoForward {
    final next = DateTime(_normalizedFocus.year, _normalizedFocus.month + 1);
    return !next.isAfter(DateTime(_today.year, _today.month));
  }

  bool get _canGoBack => !_normalizedFocus.isBefore(_firstMonth);

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy').format(_normalizedFocus);
    final days = _buildDayCells(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_rounded,
                  size: 18, color: AppTheme.primary),
              const SizedBox(width: 8),
              Text(
                'Browse all dates',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppTheme.primary,
                      fontSize: 12,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _NavButton(
                icon: Icons.chevron_left_rounded,
                enabled: _canGoBack,
                onTap: () {
                  onMonthChanged(
                    DateTime(_normalizedFocus.year, _normalizedFocus.month - 1),
                  );
                },
              ),
              Expanded(
                child: GestureDetector(
                  onTap: onMonthLabelTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          monthLabel,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppTheme.textDark,
                                    fontSize: 15,
                                  ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more_rounded,
                            size: 18, color: AppTheme.textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                enabled: _canGoForward,
                onTap: () {
                  onMonthChanged(
                    DateTime(_normalizedFocus.year, _normalizedFocus.month + 1),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: _weekdayLabels(context)
                .map(
                  (label) => Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 4,
            childAspectRatio: 1.05,
            children: days,
          ),
        ],
      ),
    );
  }

  List<String> _weekdayLabels(BuildContext context) {
    final firstDay = MaterialLocalizations.of(context).firstDayOfWeekIndex;
    const names = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    return List.generate(7, (i) => names[(firstDay + i) % 7]);
  }

  List<Widget> _buildDayCells(BuildContext context) {
    final firstOfMonth = _normalizedFocus;
    final daysInMonth =
        DateTime(firstOfMonth.year, firstOfMonth.month + 1, 0).day;
    final firstWeekday = firstOfMonth.weekday % 7;
    final firstDayIndex =
        MaterialLocalizations.of(context).firstDayOfWeekIndex;
    final leading = (firstWeekday - firstDayIndex + 7) % 7;

    final cells = <Widget>[];

    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }

    for (var day = 1; day <= daysInMonth; day++) {
      final date = JournalEntry.normalizeDate(
        DateTime(firstOfMonth.year, firstOfMonth.month, day),
      );
      final isSelected = date == JournalEntry.normalizeDate(selectedDate);
      final isToday = date == _today;
      final isFuture = date.isAfter(_today);
      final hasEntry = datesWithEntries.contains(date);

      cells.add(
        _DayCell(
          day: day,
          isSelected: isSelected,
          isToday: isToday,
          isFuture: isFuture,
          hasEntry: hasEntry,
          onTap: isFuture ? null : () => onDateSelected(date),
        ),
      );
    }

    return cells;
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          child: Icon(
            icon,
            color: enabled ? AppTheme.primary : AppTheme.border,
          ),
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.isFuture,
    required this.hasEntry,
    required this.onTap,
  });

  final int day;
  final bool isSelected;
  final bool isToday;
  final bool isFuture;
  final bool hasEntry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isFuture
        ? AppTheme.textMuted.withValues(alpha: 0.35)
        : isSelected
            ? Colors.white
            : AppTheme.textDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  )
                : null,
            color: isSelected
                ? null
                : isToday
                    ? AppTheme.primaryLight.withValues(alpha: 0.45)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: isToday && !isSelected
                ? Border.all(color: AppTheme.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$day',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: textColor,
                      fontWeight:
                          isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
              ),
              if (hasEntry && !isFuture)
                Container(
                  margin: const EdgeInsets.only(top: 3),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
