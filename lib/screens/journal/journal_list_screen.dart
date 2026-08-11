import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../services/journal_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/timeline_entry_tile.dart';

class JournalListScreen extends ConsumerWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(journalEntriesProvider);

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
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'All Journals',
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${entries.length} ${entries.length == 1 ? 'entry' : 'entries'}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                if (entries.isEmpty)
                  const SliverFillRemaining(
                    child: EmptyState(
                      icon: Icons.menu_book_rounded,
                      title: 'No journals yet',
                      subtitle: 'Your entries will appear here.',
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final entry = entries[index];
                          return TimelineEntryTile(
                            entry: entry,
                            isLast: index == entries.length - 1,
                            onTap: () => context.push('/write', extra: {
                              'date': entry.entryDate,
                              'id': entry.id,
                              'content': entry.content,
                              'category': entry.category,
                            }),
                          );
                        },
                        childCount: entries.length,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
