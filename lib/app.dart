import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/theme.dart';
import 'router/app_router.dart';
import 'services/notification_service.dart';
import 'providers/scripture_provider.dart';

class BabesNotebookApp extends ConsumerStatefulWidget {
  const BabesNotebookApp({super.key});

  @override
  ConsumerState<BabesNotebookApp> createState() => _BabesNotebookAppState();
}

class _BabesNotebookAppState extends ConsumerState<BabesNotebookApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    await NotificationService.instance.init();
    try {
      await ref.read(dailyReadingProvider.future);
      await ref.read(dailyReadingProvider.notifier).syncNotificationIfEnabled();
    } catch (_) {
      // Offline or API unavailable on first launch.
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: "Babe's Notebook",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
      routerConfig: router,
    );
  }
}
