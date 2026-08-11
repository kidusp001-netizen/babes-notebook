import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/journal_entry.dart';

class DateStrip extends StatelessWidget {
  const DateStrip({
    super.key,
    required this.selectedDate,
    required this.datesWithEntries,
    required this.onDateSelected,
    this.dayCount = 14,
  });

  final DateTime selectedDate;
  final Set<DateTime> datesWithEntries;
  final ValueChanged<DateTime> onDateSelected;
  final int dayCount;

  @override
  Widget build(BuildContext context) {
    final today = JournalEntry.normalizeDate(DateTime.now());
    final start = today.subtract(Duration(days: dayCount ~/ 2));

    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: dayCount,
        itemBuilder: (context, index) {
          final date = JournalEntry.normalizeDate(
            start.add(Duration(days: index)),
          );
          final selected = date == JournalEntry.normalizeDate(selectedDate);
          final hasEntry = datesWithEntries.contains(date);

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: 56,
              margin: EdgeInsets.only(right: index == dayCount - 1 ? 0 : 10),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border,
                ),
                boxShadow: selected ? AppTheme.primaryShadow : AppTheme.cardShadow,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date).substring(0, 3),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.8)
                              : AppTheme.textMuted,
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: selected ? Colors.white : AppTheme.textDark,
                          fontSize: 20,
                        ),
                  ),
                  if (hasEntry && !selected)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  else
                    const SizedBox(height: 9),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
