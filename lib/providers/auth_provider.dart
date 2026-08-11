import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) async* {
  if (AppConfig.skipAuth) {
    yield const AuthState(AuthChangeEvent.signedIn, null);
    return;
  }
  final client = ref.watch(supabaseClientProvider);
  yield AuthState(
    AuthChangeEvent.initialSession,
    client.auth.currentSession,
  );
  yield* client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  if (AppConfig.skipAuth) return null;
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  if (AppConfig.skipAuth) return true;
  return ref.watch(currentUserProvider) != null;
});

final displayNameProvider = Provider<String>((ref) {
  if (AppConfig.skipAuth) return 'Babe';
  final user = ref.watch(currentUserProvider);
  final name = user?.userMetadata?['display_name'] as String?;
  if (name != null && name.isNotEmpty) return name.split(' ').first;
  return 'Babe';
});
