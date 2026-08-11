import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/theme.dart';
import '../models/journal_entry.dart';

class FeaturedEntryCard extends StatelessWidget {
  const FeaturedEntryCard({
    super.key,
    required this.entry,
    required this.onTap,
    this.isToday = true,
  });

  final JournalEntry? entry;
  final VoidCallback onTap;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final hasEntry = entry != null && !entry!.isEmpty;
    final date = entry?.entryDate ?? DateTime.now();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: AppTheme.primaryShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    hasEntry ? Icons.check_rounded : Icons.edit_note_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primary,
                    size: 22,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              isToday ? "Today's Journal" : DateFormat('EEEE').format(date),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              hasEntry
                  ? entry!.preview
                  : 'Pour out your heart about today…',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 20,
                    height: 1.35,
                  ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
