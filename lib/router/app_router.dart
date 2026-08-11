import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/preview_config.dart';
import '../models/journal_category.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/calendar/calendar_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/journal/journal_editor_screen.dart';
import '../screens/journal/journal_list_screen.dart';
import '../screens/profile/reminder_settings_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/scripture/daily_scripture_screen.dart';
import '../screens/shell/main_shell.dart';
import '../screens/splash_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: _AuthRefreshListenable(ref),
    redirect: (context, state) {
      if (PreviewConfig.enabled) {
        if (state.matchedLocation == '/') return '/home';
        return null;
      }

      if (authState.isLoading) return null;

      final isLoggedIn = ref.read(isAuthenticatedProvider);
      final path = state.matchedLocation;
      final isAuthRoute = path == '/login' || path == '/signup';
      final isSplash = path == '/';

      if (authState.isLoading && isSplash) return null;

      if (!isLoggedIn && !isAuthRoute && !isSplash && path != '/write' && path != '/scripture' && path != '/reminder-settings') {
        return '/login';
      }
      if (isLoggedIn && (isAuthRoute || isSplash)) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
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

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this.ref) {
    ref.listen(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref ref;
}
