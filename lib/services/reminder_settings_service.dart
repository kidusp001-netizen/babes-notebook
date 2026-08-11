import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_reading.dart';

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
    required this.calendar,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final OrthodoxCalendar calendar;

  TimeOfDay get time => TimeOfDay(hour: hour, minute: minute);

  ReminderSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    OrthodoxCalendar? calendar,
  }) {
    return ReminderSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      calendar: calendar ?? this.calendar,
    );
  }

  static const defaults = ReminderSettings(
    enabled: false,
    hour: 7,
    minute: 0,
    calendar: OrthodoxCalendar.gregorian,
  );
}

class ReminderSettingsService {
  static const _enabledKey = 'reminder_enabled';
  static const _hourKey = 'reminder_hour';
  static const _minuteKey = 'reminder_minute';
  static const _calendarKey = 'reminder_calendar';

  Future<ReminderSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final calendarName = prefs.getString(_calendarKey);
    return ReminderSettings(
      enabled: prefs.getBool(_enabledKey) ?? false,
      hour: prefs.getInt(_hourKey) ?? 7,
      minute: prefs.getInt(_minuteKey) ?? 0,
      calendar: calendarName == 'julian'
          ? OrthodoxCalendar.julian
          : OrthodoxCalendar.gregorian,
    );
  }

  Future<void> save(ReminderSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, settings.enabled);
    await prefs.setInt(_hourKey, settings.hour);
    await prefs.setInt(_minuteKey, settings.minute);
    await prefs.setString(
      _calendarKey,
      settings.calendar == OrthodoxCalendar.julian ? 'julian' : 'gregorian',
    );
  }
}
