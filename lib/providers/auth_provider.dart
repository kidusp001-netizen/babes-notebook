import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/preview_config.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  if (PreviewConfig.enabled) {
    return Stream.value(const AuthState(AuthChangeEvent.signedIn, null));
  }
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

final currentUserProvider = Provider<User?>((ref) {
  if (PreviewConfig.enabled) return null;
  return ref.watch(supabaseClientProvider).auth.currentUser;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  if (PreviewConfig.enabled) return true;
  return ref.watch(currentUserProvider) != null;
});

final displayNameProvider = Provider<String>((ref) {
  if (PreviewConfig.enabled) return 'Babe';
  final user = ref.watch(currentUserProvider);
  final name = user?.userMetadata?['display_name'] as String?;
  if (name != null && name.isNotEmpty) return name.split(' ').first;
  return 'Babe';
});
