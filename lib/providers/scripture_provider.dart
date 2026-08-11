import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_reading.dart';
import '../services/notification_service.dart';
import '../services/orthocal_service.dart';
import '../services/reminder_settings_service.dart';

final orthocalServiceProvider = Provider<OrthocalService>((ref) {
  return OrthocalService();
});

final reminderSettingsServiceProvider = Provider<ReminderSettingsService>((ref) {
  return ReminderSettingsService();
});

final reminderSettingsProvider =
    AsyncNotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
  ReminderSettingsNotifier.new,
);

class ReminderSettingsNotifier extends AsyncNotifier<ReminderSettings> {
  @override
  Future<ReminderSettings> build() async {
    return ref.read(reminderSettingsServiceProvider).load();
  }

  Future<void> updateSettings(ReminderSettings settings) async {
    await ref.read(reminderSettingsServiceProvider).save(settings);
    state = AsyncData(settings);

    if (settings.enabled) {
      await _syncNotification(settings);
    } else {
      await NotificationService.instance.cancelDailyReminder();
    }
  }

  Future<void> _syncNotification(ReminderSettings settings) async {
    final granted = await NotificationService.instance.requestPermission();
    if (!granted) {
      final disabled = settings.copyWith(enabled: false);
      await ref.read(reminderSettingsServiceProvider).save(disabled);
      state = AsyncData(disabled);
      return;
    }

    final reading = await ref.read(dailyReadingProvider.future);
    await NotificationService.instance.scheduleDailyReminder(
      time: settings.time,
      title: reading.notificationTitle,
      body: reading.notificationBody,
    );
  }
}

final dailyReadingProvider =
    AsyncNotifierProvider<DailyReadingNotifier, DailyReading>(
  DailyReadingNotifier.new,
);

class DailyReadingNotifier extends AsyncNotifier<DailyReading> {
  @override
  Future<DailyReading> build() async {
    final settings = await ref.watch(reminderSettingsProvider.future);
    return ref.read(orthocalServiceProvider).fetchToday(
          calendar: settings.calendar,
        );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final settings = await ref.read(reminderSettingsProvider.future);
      return ref.read(orthocalServiceProvider).fetchToday(
            calendar: settings.calendar,
          );
    });
  }

  Future<void> syncNotificationIfEnabled() async {
    final settings = ref.read(reminderSettingsProvider).valueOrNull;
    if (settings == null || !settings.enabled) return;

    final reading = state.valueOrNull;
    if (reading == null) return;

    await NotificationService.instance.scheduleDailyReminder(
      time: settings.time,
      title: reading.notificationTitle,
      body: reading.notificationBody,
    );
  }
}
