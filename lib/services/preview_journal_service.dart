import 'package:uuid/uuid.dart';

import '../models/journal_category.dart';
import '../models/journal_entry.dart';

/// In-memory journal storage for local UI preview.
class PreviewJournalService {
  PreviewJournalService() {
    _entries.addAll(_seedEntries);
  }

  static const _userId = 'preview-user';
  static const _uuid = Uuid();

  final List<JournalEntry> _entries = [];

  Future<List<JournalEntry>> fetchAll() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List<JournalEntry>.from(_entries)
      ..sort((a, b) {
        final dateCmp = b.entryDate.compareTo(a.entryDate);
        if (dateCmp != 0) return dateCmp;
        return b.updatedAt.compareTo(a.updatedAt);
      });
  }

  Future<JournalEntry> save({
    String? id,
    required DateTime entryDate,
    required String content,
    required JournalCategory category,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final normalized = JournalEntry.normalizeDate(entryDate);
    final now = DateTime.now().toUtc();

    if (id != null) {
      final index = _entries.indexWhere((e) => e.id == id);
      if (index >= 0) {
        final updated = _entries[index].copyWith(
          entryDate: normalized,
          content: content,
          category: category,
          updatedAt: now,
        );
        _entries[index] = updated;
        return updated;
      }
    }

    final entry = JournalEntry(
      id: id ?? _uuid.v4(),
      userId: _userId,
      entryDate: normalized,
      content: content,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    _entries.add(entry);
    return entry;
  }

  Future<void> delete(String id) async {
    _entries.removeWhere((e) => e.id == id);
  }

  static List<JournalEntry> get _seedEntries {
    final now = DateTime.now();
    final today = JournalEntry.normalizeDate(now);
    final yesterday = today.subtract(const Duration(days: 1));
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final threeDaysAgo = today.subtract(const Duration(days: 3));

    return [
      JournalEntry(
        id: 'seed-1',
        userId: _userId,
        entryDate: today,
        category: JournalCategory.gratitude,
        content:
            'Today was full of small blessings. The morning was quiet and I had time to pray before the day started. '
            'Thank You for the sunshine, for coffee with a friend, and for patience when things got busy.',
        createdAt: now.toUtc().subtract(const Duration(hours: 2)),
        updatedAt: now.toUtc().subtract(const Duration(hours: 2)),
      ),
      JournalEntry(
        id: 'seed-1b',
        userId: _userId,
        entryDate: today,
        category: JournalCategory.prayer,
        content:
            'Lord, please watch over my family tonight. Give us peace before sleep and strength for tomorrow.',
        createdAt: now.toUtc().subtract(const Duration(hours: 1)),
        updatedAt: now.toUtc().subtract(const Duration(hours: 1)),
      ),
      JournalEntry(
        id: 'seed-2',
        userId: _userId,
        entryDate: yesterday,
        category: JournalCategory.reflection,
        content:
            'I felt overwhelmed at work today. I brought it all to You in the afternoon — and You gave me peace. '
            'Remind me that I don\'t have to carry everything alone.',
        createdAt: yesterday.toUtc(),
        updatedAt: yesterday.toUtc(),
      ),
      JournalEntry(
        id: 'seed-3',
        userId: _userId,
        entryDate: twoDaysAgo,
        category: JournalCategory.gratitude,
        content:
            'Sunday was beautiful. Church felt like coming home. Grateful for worship, for community, '
            'and for a slow evening walk.',
        createdAt: twoDaysAgo.toUtc(),
        updatedAt: twoDaysAgo.toUtc(),
      ),
      JournalEntry(
        id: 'seed-4',
        userId: _userId,
        entryDate: threeDaysAgo,
        category: JournalCategory.reflection,
        content:
            'A hard conversation today, but I think it was needed. Thank You for courage and for softening hearts.',
        createdAt: threeDaysAgo.toUtc(),
        updatedAt: threeDaysAgo.toUtc(),
      ),
    ];
  }
}

final previewJournalServiceProvider = PreviewJournalService();
