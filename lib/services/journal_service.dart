import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/preview_config.dart';
import '../models/journal_category.dart';
import '../models/journal_entry.dart';
import '../providers/auth_provider.dart';
import 'preview_journal_service.dart';

class JournalService {
  JournalService(this._client);

  final SupabaseClient _client;
  static const _table = 'journal_entries';
  static const _uuid = Uuid();

  String? get _userId => _client.auth.currentUser?.id;

  Future<List<JournalEntry>> fetchAll() async {
    final userId = _userId;
    if (userId == null) return [];

    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('entry_date', ascending: false)
        .order('updated_at', ascending: false);

    return (response as List)
        .map((row) => JournalEntry.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Future<JournalEntry> save({
    String? id,
    required DateTime entryDate,
    required String content,
    required JournalCategory category,
  }) async {
    final userId = _userId;
    if (userId == null) {
      throw StateError('Must be signed in to save entries.');
    }

    final now = DateTime.now().toUtc();
    final normalized = JournalEntry.normalizeDate(entryDate);
    final entryId = id ?? _uuid.v4();

    final payload = {
      'id': entryId,
      'user_id': userId,
      'entry_date': _formatDate(normalized),
      'content': content,
      'category': category.dbValue,
      'updated_at': now.toIso8601String(),
    };

    if (id == null) {
      payload['created_at'] = now.toIso8601String();
    }

    final response = await _client
        .from(_table)
        .upsert(payload, onConflict: 'id')
        .select()
        .single();

    return JournalEntry.fromJson(Map<String, dynamic>.from(response));
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

final journalServiceProvider = Provider<Object>((ref) {
  if (PreviewConfig.enabled) return previewJournalServiceProvider;
  return JournalService(ref.watch(supabaseClientProvider));
});

class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntry>> {
  dynamic get _service => ref.read(journalServiceProvider);

  @override
  Future<List<JournalEntry>> build() async {
    return _service.fetchAll() as Future<List<JournalEntry>>;
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.fetchAll() as Future<List<JournalEntry>>,
    );
  }

  Future<JournalEntry> saveEntry({
    String? id,
    required DateTime entryDate,
    required String content,
    required JournalCategory category,
  }) async {
    final saved = await _service.save(
          id: id,
          entryDate: entryDate,
          content: content,
          category: category,
        ) as JournalEntry;

    await refresh();
    return saved;
  }

  Future<void> deleteEntry(String id) async {
    await _service.delete(id);
    await refresh();
  }

  List<JournalEntry> entriesForDate(DateTime date) {
    final entries = state.valueOrNull ?? [];
    final normalized = JournalEntry.normalizeDate(date);
    return entries
        .where((e) => JournalEntry.normalizeDate(e.entryDate) == normalized)
        .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  List<JournalEntry> filterByCategory(String filter) {
    final entries = state.valueOrNull ?? [];
    return entries
        .where((e) => JournalCategoryFilter.matches(filter, e.category))
        .toList();
  }

  Set<DateTime> get datesWithEntries {
    final entries = state.valueOrNull ?? [];
    return entries
        .map((e) => JournalEntry.normalizeDate(e.entryDate))
        .toSet();
  }
}

final journalEntriesProvider =
    AsyncNotifierProvider<JournalEntriesNotifier, List<JournalEntry>>(
  JournalEntriesNotifier.new,
);
