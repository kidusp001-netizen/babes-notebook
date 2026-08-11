import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/journal_entry.dart';
import 'category_badge.dart';

class TimelineEntryTile extends StatelessWidget {
  const TimelineEntryTile({
    super.key,
    required this.entry,
    required this.onTap,
    this.isLast = false,
  });

  final JournalEntry entry;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 56,
            child: Column(
              children: [
                Text(
                  DateFormat('h:mm a').format(entry.updatedAt.toLocal()),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 11,
                        color: AppTheme.textMuted,
                      ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : AppTheme.border,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: GestureDetector(
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
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primary, AppTheme.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            DateFormat('d').format(entry.entryDate),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    DateFormat('EEEE, MMM d')
                                        .format(entry.entryDate),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontSize: 15),
                                  ),
                                ),
                                CategoryBadge(
                                  category: entry.category,
                                  compact: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              entry.preview,
                              style: Theme.of(context).textTheme.bodyMedium,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
