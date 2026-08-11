import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/theme.dart';
import '../../models/daily_reading.dart';
import '../../providers/scripture_provider.dart';

class DailyScriptureScreen extends ConsumerWidget {
  const DailyScriptureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final readingAsync = ref.watch(dailyReadingProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: readingAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          ),
          error: (_, __) => _ErrorView(
            onRetry: () => ref.read(dailyReadingProvider.notifier).refresh(),
          ),
          data: (reading) => _ReadingView(reading: reading),
        ),
      ),
    );
  }
}

class _ReadingView extends StatelessWidget {
  const _ReadingView({required this.reading});

  final DailyReading reading;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                _CircleButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Navigator.pop(context),
                ),
                const Spacer(),
                Text(
                  DateFormat('MMM d, yyyy').format(reading.date),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                const SizedBox(width: 44),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Orthodox Daily\nReadings',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                if (reading.summaryTitle.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    reading.summaryTitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Scripture in modern English',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppTheme.textMuted,
                        fontSize: 11,
                      ),
                ),
                if (reading.titles.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    reading.titles.join(' · '),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                if (reading.fastDescription.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoChip(
                    icon: Icons.restaurant_outlined,
                    label: reading.fastDescription,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (reading.epistle != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _ReadingSection(reading: reading.epistle!),
            ),
          ),
        if (reading.gospel != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: _ReadingSection(reading: reading.gospel!, highlighted: true),
            ),
          ),
        if (reading.saints.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saints of the Day',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  ...reading.saints.map(
                    (saint) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppTheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              saint,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _ReadingSection extends StatelessWidget {
  const _ReadingSection({
    required this.reading,
    this.highlighted = false,
  });

  final ScriptureReading reading;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: highlighted ? AppTheme.primary : AppTheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: highlighted ? null : Border.all(color: AppTheme.border),
        boxShadow: highlighted ? AppTheme.primaryShadow : AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reading.source,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: highlighted
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppTheme.primary,
                  fontSize: 12,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            reading.reference,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: highlighted ? Colors.white : AppTheme.textDark,
                  fontSize: 18,
                ),
          ),
          const SizedBox(height: 16),
          ...reading.verses.map(
            (verse) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontSize: 15,
                        height: 1.65,
                        color: highlighted
                            ? Colors.white.withValues(alpha: 0.95)
                            : AppTheme.textDark,
                      ),
                  children: [
                    TextSpan(
                      text: '${verse.verse} ',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: highlighted
                            ? Colors.white
                            : AppTheme.primary,
                        fontSize: 13,
                      ),
                    ),
                    TextSpan(text: verse.content),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppTheme.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.textDark, size: 22),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 48, color: AppTheme.textMuted),
          const SizedBox(height: 16),
          const Text('Could not load readings'),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
