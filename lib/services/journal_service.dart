import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/app_config.dart';
import '../config/preview_config.dart';
import '../models/journal_category.dart';
import '../models/journal_entry.dart';
import '../providers/auth_provider.dart';
import '../providers/journal_offline_provider.dart';
import 'journal_cache_service.dart';
import 'local_journal_service.dart';
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
  if (AppConfig.personalMode) return localJournalServiceProvider;
  return JournalService(ref.watch(supabaseClientProvider));
});

class JournalEntriesNotifier extends AsyncNotifier<List<JournalEntry>> {
  dynamic get _service => ref.read(journalServiceProvider);
  final _cache = JournalCacheService.instance;

  String? get _userId {
    if (PreviewConfig.enabled) return 'preview';
    if (AppConfig.personalMode) return LocalJournalService.userId;
    return ref.read(supabaseClientProvider).auth.currentUser?.id;
  }

  @override
  Future<List<JournalEntry>> build() async {
    if (AppConfig.useLocalJournal) {
      return _service.fetchAll() as Future<List<JournalEntry>>;
    }

    final userId = _userId;
    if (userId == null) return [];

    final cached = await _cache.loadEntries(userId);
    if (cached.isNotEmpty) {
      unawaited(_refreshInBackground(userId));
      return cached;
    }

    return _fetchFromNetwork(userId);
  }

  Future<List<JournalEntry>> _fetchFromNetwork(String userId) async {
    try {
      final remote = await _service.fetchAll() as List<JournalEntry>;
      await _cache.saveEntries(userId, remote);
      ref.read(journalOfflineProvider.notifier).state = false;
      await _syncPending(userId);
      return remote;
    } catch (_) {
      ref.read(journalOfflineProvider.notifier).state = true;
      rethrow;
    }
  }

  Future<void> _refreshInBackground(String userId) async {
    try {
      final remote = await _service.fetchAll() as List<JournalEntry>;
      await _cache.saveEntries(userId, remote);
      ref.read(journalOfflineProvider.notifier).state = false;
      await _syncPending(userId);
      state = AsyncData(remote);
    } catch (_) {
      ref.read(journalOfflineProvider.notifier).state = true;
    }
  }

  Future<void> refresh() async {
    if (AppConfig.useLocalJournal) {
      state = AsyncData(
        await _service.fetchAll() as List<JournalEntry>,
      );
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final userId = _userId;
      if (userId == null) return [];

      final cached = await _cache.loadEntries(userId);
      try {
        final remote = await _service.fetchAll() as List<JournalEntry>;
        await _cache.saveEntries(userId, remote);
        ref.read(journalOfflineProvider.notifier).state = false;
        await _syncPending(userId);
        return remote;
      } catch (_) {
        ref.read(journalOfflineProvider.notifier).state = true;
        if (cached.isNotEmpty) return cached;
        rethrow;
      }
    });
  }

  Future<JournalEntry> saveEntry({
    String? id,
    required DateTime entryDate,
    required String content,
    required JournalCategory category,
  }) async {
    if (AppConfig.useLocalJournal) {
      final saved = await _service.save(
            id: id,
            entryDate: entryDate,
            content: content,
            category: category,
          ) as JournalEntry;
      state = AsyncData(await _service.fetchAll() as List<JournalEntry>);
      return saved;
    }

    final userId = _userId;
    if (userId == null) {
      throw StateError('Must be signed in to save entries.');
    }

    final now = DateTime.now().toUtc();
    final local = JournalEntry(
      id: id ?? const Uuid().v4(),
      userId: userId,
      entryDate: JournalEntry.normalizeDate(entryDate),
      content: content,
      category: category,
      createdAt: now,
      updatedAt: now,
    );

    await _cache.upsertEntry(userId, local);
    _updateStateFromCache(await _cache.loadEntries(userId));

    try {
      final saved = await _service.save(
            id: id,
            entryDate: entryDate,
            content: content,
            category: category,
          ) as JournalEntry;
      await _cache.upsertEntry(userId, saved);
      ref.read(journalOfflineProvider.notifier).state = false;
      _updateStateFromCache(await _cache.loadEntries(userId));
      return saved;
    } catch (_) {
      await _cache.addPendingSave(userId, local);
      ref.read(journalOfflineProvider.notifier).state = true;
      return local;
    }
  }

  Future<void> deleteEntry(String id) async {
    if (AppConfig.useLocalJournal) {
      await _service.delete(id);
      state = AsyncData(await _service.fetchAll() as List<JournalEntry>);
      return;
    }

    final userId = _userId;
    if (userId == null) return;

    await _cache.removeEntry(userId, id);
    _updateStateFromCache(await _cache.loadEntries(userId));

    try {
      await _service.delete(id);
      ref.read(journalOfflineProvider.notifier).state = false;
    } catch (_) {
      await _cache.addPendingDelete(userId, id);
      ref.read(journalOfflineProvider.notifier).state = true;
    }
  }

  void _updateStateFromCache(List<JournalEntry> entries) {
    state = AsyncData(entries);
  }

  Future<void> _syncPending(String userId) async {
    final pending = await _cache.loadPending(userId);
    if (pending.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];

    for (final action in pending) {
      try {
        if (action['type'] == 'save') {
          final entry = JournalEntry.fromJson(
            Map<String, dynamic>.from(action['entry']),
          );
          final saved = await _service.save(
                id: entry.id,
                entryDate: entry.entryDate,
                content: entry.content,
                category: entry.category,
              ) as JournalEntry;
          await _cache.upsertEntry(userId, saved);
        } else if (action['type'] == 'delete') {
          await _service.delete(action['id'] as String);
          await _cache.removeEntry(userId, action['id'] as String);
        }
      } catch (_) {
        remaining.add(action);
      }
    }

    await _cache.savePending(userId, remaining);
    if (remaining.isEmpty) {
      ref.read(journalOfflineProvider.notifier).state = false;
    }
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
