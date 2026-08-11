import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/journal_category.dart';
import '../../models/journal_entry.dart';
import '../../providers/journal_offline_provider.dart';
import '../../services/journal_service.dart';
import '../../widgets/category_badge.dart';
import '../../widgets/daily_verse_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_chips.dart';
import '../../widgets/home_header.dart';
import '../../widgets/journal_card.dart';
import '../../widgets/offline_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _filter = JournalCategoryFilter.all;

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(journalEntriesProvider);
    final isOffline = ref.watch(journalOfflineProvider);
    final today = JournalEntry.normalizeDate(DateTime.now());
    final notifier = ref.read(journalEntriesProvider.notifier);

    return SafeArea(
      child: RefreshIndicator(
        color: AppTheme.primary,
        onRefresh: () => ref.read(journalEntriesProvider.notifier).refresh(),
        child: entriesAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (_, __) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: const [
              EmptyState(
                icon: Icons.cloud_off_outlined,
                title: 'Could not load entries',
                subtitle: 'Pull down to try again.',
              ),
            ],
          ),
          data: (entries) {
            final todayEntries = notifier
                .entriesForDate(today)
                .where((e) => JournalCategoryFilter.matches(_filter, e.category))
                .toList();
            final recent = notifier
                .filterByCategory(_filter)
                .where((e) =>
                    JournalEntry.normalizeDate(e.entryDate) != today)
                .take(8)
                .toList();

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 120),
              children: [
                const HomeHeader(),
                if (isOffline) const OfflineBanner(),
                const SizedBox(height: 20),
                const DailyVerseCard(),
                const SizedBox(height: 28),
                Text(
                  'Write Today',
                  style: Theme.of(context).textTheme.displayLarge,
                ),
                const SizedBox(height: 16),
                FilterChips(
                  selected: _filter,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: 20),
                _NewNoteCard(onTap: () => _openEditor(context, date: today)),
                if (todayEntries.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    "${todayEntries.length} note${todayEntries.length == 1 ? '' : 's'} today",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppTheme.textMuted,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...todayEntries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TodayEntryTile(
                        entry: entry,
                        onTap: () => _openEditor(
                          context,
                          date: entry.entryDate,
                          entry: entry,
                        ),
                      ),
                    ),
                  ),
                ],
                if (recent.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Journals',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () => context.go('/entries'),
                        child: const Text('See all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 190,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recent.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final entry = recent[index];
                        return JournalCard(
                          entry: entry,
                          compact: true,
                          onTap: () => _openEditor(
                            context,
                            date: entry.entryDate,
                            entry: entry,
                          ),
                        );
                      },
                    ),
                  ),
                ],
                if (entries.isEmpty) ...[
                  const SizedBox(height: 32),
                  const EmptyState(
                    icon: Icons.edit_note_rounded,
                    title: 'Start your first journal',
                    subtitle: 'Tap the card above to write today.',
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  void _openEditor(
    BuildContext context, {
    required DateTime date,
    JournalEntry? entry,
  }) {
    context.push('/write', extra: {
      'date': date,
      if (entry != null) ...{
        'id': entry.id,
        'content': entry.content,
        'category': entry.category,
      },
    });
  }
}

class _NewNoteCard extends StatelessWidget {
  const _NewNoteCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
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
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'New note',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  Text(
                    'Write another letter today ♡',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

class _TodayEntryTile extends StatelessWidget {
  const _TodayEntryTile({required this.entry, required this.onTap});

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
                    entry.isEmpty ? 'Tap to continue writing…' : entry.preview,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 14,
                          height: 1.4,
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
