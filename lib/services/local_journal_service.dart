import 'package:uuid/uuid.dart';

import '../models/journal_category.dart';
import '../models/journal_entry.dart';
import 'journal_cache_service.dart';

/// Journal stored locally on her device — no account needed.
class LocalJournalService {
  LocalJournalService._();
  static final instance = LocalJournalService._();

  static const userId = 'babe';
  static const _uuid = Uuid();
  final _cache = JournalCacheService.instance;

  Future<List<JournalEntry>> fetchAll() async {
    final entries = await _cache.loadEntries(userId);
    entries.sort((a, b) {
      final dateCmp = b.entryDate.compareTo(a.entryDate);
      if (dateCmp != 0) return dateCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return entries;
  }

  Future<JournalEntry> save({
    String? id,
    required DateTime entryDate,
    required String content,
    required JournalCategory category,
  }) async {
    final now = DateTime.now().toUtc();
    final normalized = JournalEntry.normalizeDate(entryDate);
    final entryId = id ?? _uuid.v4();

    JournalEntry? existing;
    if (id != null) {
      final all = await fetchAll();
      for (final e in all) {
        if (e.id == id) {
          existing = e;
          break;
        }
      }
    }

    final entry = JournalEntry(
      id: entryId,
      userId: userId,
      entryDate: normalized,
      content: content,
      category: category,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
    );

    await _cache.upsertEntry(userId, entry);
    return entry;
  }

  Future<void> delete(String id) async {
    await _cache.removeEntry(userId, id);
  }
}

final localJournalServiceProvider = LocalJournalService.instance;
