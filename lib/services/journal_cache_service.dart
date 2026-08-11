import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/journal_entry.dart';

/// Local cache + pending sync queue so the journal works offline.
class JournalCacheService {
  JournalCacheService._();
  static final instance = JournalCacheService._();

  static const _entriesPrefix = 'journal_entries_';
  static const _pendingPrefix = 'journal_pending_';

  Future<List<JournalEntry>> loadEntries(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_entriesPrefix$userId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => JournalEntry.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveEntries(String userId, List<JournalEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString('$_entriesPrefix$userId', encoded);
  }

  Future<void> upsertEntry(String userId, JournalEntry entry) async {
    final entries = await loadEntries(userId);
    final index = entries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      entries[index] = entry;
    } else {
      entries.insert(0, entry);
    }
    entries.sort((a, b) {
      final dateCmp = b.entryDate.compareTo(a.entryDate);
      if (dateCmp != 0) return dateCmp;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    await saveEntries(userId, entries);
  }

  Future<void> removeEntry(String userId, String entryId) async {
    final entries = await loadEntries(userId);
    entries.removeWhere((e) => e.id == entryId);
    await saveEntries(userId, entries);
  }

  Future<List<Map<String, dynamic>>> loadPending(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_pendingPrefix$userId');
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> savePending(
    String userId,
    List<Map<String, dynamic>> pending,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_pendingPrefix$userId', jsonEncode(pending));
  }

  Future<void> addPendingSave(String userId, JournalEntry entry) async {
    final pending = await loadPending(userId);
    pending.removeWhere(
      (p) => p['type'] == 'save' && p['entry']['id'] == entry.id,
    );
    pending.add({'type': 'save', 'entry': entry.toJson()});
    await savePending(userId, pending);
  }

  Future<void> addPendingDelete(String userId, String entryId) async {
    final pending = await loadPending(userId);
    pending.removeWhere(
      (p) => p['type'] == 'save' && p['entry']['id'] == entryId,
    );
    pending.add({'type': 'delete', 'id': entryId});
    await savePending(userId, pending);
  }

  Future<void> clearPending(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_pendingPrefix$userId');
  }
}
