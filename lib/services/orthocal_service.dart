import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_reading.dart';
import 'modern_scripture_service.dart';

class OrthocalService {
  static const _baseUrl = 'https://orthocal.info/api';
  static const _cachePrefix = 'orthocal_reading_v3_';
  final _modern = ModernScriptureService();

  Future<DailyReading> fetchForDate(
    DateTime date, {
    OrthodoxCalendar calendar = OrthodoxCalendar.gregorian,
  }) async {
    final normalized = DateTime(date.year, date.month, date.day);
    final cacheKey = _cacheKey(normalized, calendar);

    final cached = await _readCache(cacheKey, normalized);
    if (cached != null) return cached;

    final cal = calendar == OrthodoxCalendar.julian ? 'julian' : 'gregorian';
    final url =
        '$_baseUrl/$cal/${normalized.year}/${normalized.month}/${normalized.day}/';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('Could not load Orthodox readings.');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final reading = DailyReading.fromJson(json, normalized);
    final modern = await _modern.applyModernText(reading);
    await _writeCache(cacheKey, modern);
    return modern;
  }

  Future<DailyReading> fetchToday({
    OrthodoxCalendar calendar = OrthodoxCalendar.gregorian,
  }) {
    return fetchForDate(DateTime.now(), calendar: calendar);
  }

  String _cacheKey(DateTime date, OrthodoxCalendar calendar) {
    final cal = calendar == OrthodoxCalendar.julian ? 'j' : 'g';
    return '$_cachePrefix$cal${date.year}${date.month}${date.day}';
  }

  Future<DailyReading?> _readCache(String key, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return DailyReading.fromJson(json, date);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeCache(String key, DailyReading reading) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(reading.toJson()));
  }
}
