import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/theme.dart';
import 'config/preview_config.dart';
import 'config/supabase_config.dart';
import 'screens/setup_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  ErrorWidget.builder = (details) {
    return Material(
      color: AppTheme.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Something went wrong.\n\n${details.exceptionAsString()}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textDark),
          ),
        ),
      ),
    );
  };

  if (PreviewConfig.enabled) {
    runApp(const ProviderScope(child: BabesNotebookApp()));
    return;
  }

  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey, // ignore: deprecated_member_use
    );
    runApp(const ProviderScope(child: BabesNotebookApp()));
  } else {
    runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const SetupScreen(),
      ),
    );
  }
}
