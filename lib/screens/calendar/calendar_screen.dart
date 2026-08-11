import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/journal_entry.dart';
import '../../services/journal_service.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/date_strip.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/journal_month_calendar.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _selectedDay = JournalEntry.normalizeDate(DateTime.now());
    _focusedMonth = DateTime(_selectedDay.year, _selectedDay.month);
  }

  void _selectDay(DateTime date) {
    setState(() {
      _selectedDay = date;
      _focusedMonth = DateTime(date.year, date.month);
    });
  }

  void _focusMonth(DateTime month) {
    setState(() => _focusedMonth = DateTime(month.year, month.month));
  }

  Future<void> _pickMonthYear() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Jump to any date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) _selectDay(JournalEntry.normalizeDate(picked));
  }

  void _openEditor({JournalEntry? entry}) {
    context.push('/write', extra: {
      'date': entry?.entryDate ?? _selectedDay,
      if (entry != null) ...{
        'id': entry.id,
        'content': entry.content,
        'category': entry.category,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final notifier = ref.read(journalEntriesProvider.notifier);
    final datesWithEntries = notifier.datesWithEntries;
    final dayEntries = notifier.entriesForDate(_selectedDay);
    final isToday =
        JournalEntry.normalizeDate(DateTime.now()) == _selectedDay;

    return SafeArea(
      child: entriesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
        error: (_, __) => const Center(child: Text('Could not load calendar')),
        data: (entries) {
          final monthEntries = entries.where((e) {
            return e.entryDate.year == _selectedDay.year &&
                e.entryDate.month == _selectedDay.month;
          }).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Babe's Notebook",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                  GestureDetector(
                    onTap: _pickMonthYear,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('MMMM yyyy').format(_focusedMonth),
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: AppTheme.textDark),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.expand_more_rounded,
                              size: 16, color: AppTheme.textMuted),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              DateStrip(
                selectedDate: _selectedDay,
                datesWithEntries: datesWithEntries,
                onDateSelected: _selectDay,
              ),
              const SizedBox(height: 16),
              JournalMonthCalendar(
                focusedMonth: _focusedMonth,
                selectedDate: _selectedDay,
                datesWithEntries: datesWithEntries,
                onDateSelected: _selectDay,
                onMonthChanged: _focusMonth,
                onMonthLabelTap: _pickMonthYear,
              ),
              const SizedBox(height: 28),
              Text(
                isToday ? 'Today' : 'Selected day',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat('EEEE, MMMM d').format(_selectedDay),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => _openEditor(),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, AppTheme.primaryDark],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: AppTheme.primaryShadow,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.add_rounded,
                            color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dayEntries.isEmpty
                                  ? 'Write for this day'
                                  : 'Add another note',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              'Tap any date on the calendar above ♡',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (dayEntries.isNotEmpty) ...[
                const SizedBox(height: 20),
                Text(
                  '${dayEntries.length} note${dayEntries.length == 1 ? '' : 's'}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 12),
                ...dayEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DayEntryCard(
                      entry: entry,
                      onTap: () => _openEditor(entry: entry),
                    ),
                  ),
                ),
              ],
              if (monthEntries.isNotEmpty) ...[
                const SizedBox(height: 32),
                Text(
                  'This month',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...monthEntries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MonthEntryRow(
                      entry: entry,
                      onTap: () => _openEditor(entry: entry),
                    ),
                  ),
                ),
              ] else if (dayEntries.isEmpty) ...[
                const SizedBox(height: 24),
                const EmptyState(
                  icon: Icons.calendar_month_rounded,
                  title: 'Nothing this month yet',
                  subtitle: 'Pick a day on the calendar and start writing.',
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _DayEntryCard extends StatelessWidget {
  const _DayEntryCard({required this.entry, required this.onTap});

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CategoryBadge(category: entry.category, compact: true),
                  const SizedBox(height: 8),
                  Text(
                    entry.preview,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _MonthEntryRow extends StatelessWidget {
  const _MonthEntryRow({required this.entry, required this.onTap});

  final JournalEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            Text(
              DateFormat('d').format(entry.entryDate),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primary,
                  ),
            ),
            const SizedBox(width: 12),
            CategoryBadge(category: entry.category, compact: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.preview,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
