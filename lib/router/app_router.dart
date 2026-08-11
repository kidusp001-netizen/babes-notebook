import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/app_config.dart';
import '../models/journal_category.dart';
import '../providers/onboarding_provider.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/journal/journal_editor_screen.dart';
import '../screens/journal/journal_list_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/reminder_settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/scripture/daily_scripture_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final onboarding = ref.watch(onboardingCompleteProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _RouterRefreshListenable(ref),
    redirect: (context, state) {
      if (onboarding.isLoading) return null;

      final onboardingDone = onboarding.value ?? false;
      final path = state.matchedLocation;

      // First launch: onboarding splashes, then straight to home — no login.
      if (!onboardingDone) {
        return path == '/onboarding' ? null : '/onboarding';
      }

      if (path == '/onboarding' || path == '/') {
        return '/home';
      }

      // Legacy auth routes — not used in personal mode.
      if (AppConfig.skipAuth && (path == '/login' || path == '/signup')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/calendar',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CalendarScreen(),
            ),
          ),
          GoRoute(
            path: '/entries',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: JournalListScreen(),
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ProfileScreen(),
            ),
          ),
        ],
      ),
      GoRoute(
        path: '/write',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return JournalEditorScreen(
            entryDate: extra?['date'] as DateTime?,
            entryId: extra?['id'] as String?,
            initialContent: extra?['content'] as String?,
            initialCategory: extra?['category'] as JournalCategory?,
          );
        },
      ),
      GoRoute(
        path: '/scripture',
        builder: (context, state) => const DailyScriptureScreen(),
      ),
      GoRoute(
        path: '/reminder-settings',
        builder: (context, state) => const ReminderSettingsScreen(),
      ),
    ],
  );
});

class _RouterRefreshListenable extends ChangeNotifier {
  _RouterRefreshListenable(this.ref) {
    ref.listen(onboardingCompleteProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
