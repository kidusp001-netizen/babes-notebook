import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../config/theme.dart';
import '../../models/daily_reading.dart';
import '../../providers/scripture_provider.dart';
import '../../services/reminder_settings_service.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() =>
      _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  late bool _enabled;
  late TimeOfDay _time;
  late OrthodoxCalendar _calendar;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(reminderSettingsProvider).valueOrNull ??
        ReminderSettings.defaults;
    _enabled = settings.enabled;
    _time = settings.time;
    _calendar = settings.calendar;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await ref.read(reminderSettingsProvider.notifier).updateSettings(
          ReminderSettings(
            enabled: _enabled,
            hour: _time.hour,
            minute: _time.minute,
            calendar: _calendar,
          ),
        );
    await ref.read(dailyReadingProvider.notifier).refresh();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  _RoundIconButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Daily Reminder',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                children: [
                  _HeroBanner(enabled: _enabled, time: _time),
                  const SizedBox(height: 28),
                  _ToggleCard(
                    enabled: _enabled,
                    onChanged: (v) => setState(() => _enabled = v),
                  ),
                  const SizedBox(height: 16),
                  _TimeCard(
                    time: _time,
                    enabled: _enabled,
                    onTap: _pickTime,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_rounded,
                          color: AppTheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Orthodox Calendar',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _CalendarOption(
                          label: 'New Calendar',
                          subtitle: 'Gregorian',
                          icon: Icons.wb_sunny_outlined,
                          selected: _calendar == OrthodoxCalendar.gregorian,
                          onTap: () => setState(
                            () => _calendar = OrthodoxCalendar.gregorian,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CalendarOption(
                          label: 'Old Calendar',
                          subtitle: 'Julian',
                          icon: Icons.nightlight_round,
                          selected: _calendar == OrthodoxCalendar.julian,
                          onTap: () => setState(
                            () => _calendar = OrthodoxCalendar.julian,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_stories_rounded,
                            color: AppTheme.primary, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Each morning you\'ll receive today\'s Gospel reading — a gentle nudge to start with Him.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 13,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_rounded, size: 20),
                            SizedBox(width: 8),
                            Text('Save Reminder'),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.enabled, required this.time});

  final bool enabled;
  final TimeOfDay time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primaryDark,
            AppTheme.navDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppTheme.primaryShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -10,
            right: -10,
            child: Icon(
              Icons.auto_awesome,
              size: 80,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Icon(
              Icons.auto_awesome,
              size: 40,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Daily Scripture\nReminder ♡',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                      height: 1.15,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                enabled
                    ? 'Gospel reading at ${time.format(context)}'
                    : 'Turn on to receive today\'s Gospel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: enabled ? AppTheme.primary.withValues(alpha: 0.4) : AppTheme.border,
          width: enabled ? 1.5 : 1,
        ),
        boxShadow: enabled ? AppTheme.primaryShadow : AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled ? AppTheme.primaryLight : AppTheme.blush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              enabled ? Icons.notifications_active_rounded : Icons.notifications_off_outlined,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enable reminder', style: Theme.of(context).textTheme.titleMedium),
                Text('Daily push notification',
                    style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
            activeThumbColor: AppTheme.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  const _TimeCard({
    required this.time,
    required this.enabled,
    required this.onTap,
  });

  final TimeOfDay time;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final formatted = time.format(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.border),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: enabled
                      ? [AppTheme.roseGold, AppTheme.primary]
                      : [AppTheme.border, AppTheme.border],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.access_time_filled_rounded,
                color: enabled ? Colors.white : AppTheme.textMuted,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Reminder time',
                      style: Theme.of(context).textTheme.bodyMedium),
                  Text(
                    formatted,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 28,
                          color: enabled ? AppTheme.primary : AppTheme.textMuted,
                        ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_calendar_rounded,
                color: enabled ? AppTheme.primary : AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}

class _CalendarOption extends StatelessWidget {
  const _CalendarOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryDark],
                )
              : null,
          color: selected ? null : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? AppTheme.primaryShadow : AppTheme.cardShadow,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? Colors.white : AppTheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: selected ? Colors.white : AppTheme.textDark,
                    fontSize: 14,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: selected
                        ? Colors.white.withValues(alpha: 0.8)
                        : AppTheme.textMuted,
                    fontSize: 12,
                  ),
            ),
            if (selected) ...[
              const SizedBox(height: 6),
              Icon(Icons.check_circle_rounded,
                  color: Colors.white.withValues(alpha: 0.9), size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

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
