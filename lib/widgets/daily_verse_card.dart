import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../config/theme.dart';
import '../models/daily_reading.dart';
import '../providers/scripture_provider.dart';

class DailyVerseCard extends ConsumerWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(dailyReadingProvider);

    return readingAsync.when(
      loading: () => _LoadingCard(),
      error: (_, __) => _ErrorCard(onRetry: () {
        ref.read(dailyReadingProvider.notifier).refresh();
      }),
      data: (reading) => _VerseCard(reading: reading),
    );
  }
}

class _VerseCard extends StatelessWidget {
  const _VerseCard({required this.reading});

  final DailyReading reading;

  @override
  Widget build(BuildContext context) {
    final gospel = reading.gospel;

    return GestureDetector(
      onTap: () => context.push('/scripture'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(22),
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Reading",
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: AppTheme.primary,
                              fontSize: 12,
                            ),
                      ),
                      if (reading.summaryTitle.isNotEmpty)
                        Text(
                          reading.summaryTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppTheme.textMuted,
                ),
              ],
            ),
            if (gospel != null) ...[
              const SizedBox(height: 16),
              Text(
                gospel.shortReference,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '“${gospel.excerpt}”',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 14,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textMuted,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRetry,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppTheme.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Could not load today\'s reading. Tap to retry.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
