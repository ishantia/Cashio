import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cashio/l10n/generated/app_localizations.dart';

import 'core/providers.dart';
import 'core/router/app_router.dart';
import 'data/services/workmanager_cloud_backup_scheduler.dart';
import 'presentation/providers/backup_providers.dart';

import 'presentation/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final scheduler = WorkmanagerCloudBackupScheduler();
  await scheduler.initialize();

  // If automatic backup is enabled, ensure the periodic task is scheduled.
  // We can do this here or let the settings UI handle it. We'll do a quick check.
  if (sharedPreferences.getBool('automatic_backup_enabled') == true) {
    await scheduler.schedule();
  }

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const CashioApp(),
    ),
  );
}

class CashioApp extends ConsumerStatefulWidget {
  const CashioApp({super.key});

  @override
  ConsumerState<CashioApp> createState() => _CashioAppState();
}

class _CashioAppState extends ConsumerState<CashioApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Opportunistic backup on startup
    _runOpportunisticBackup();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _runOpportunisticBackup();
    }
  }

  void _runOpportunisticBackup() {
    // Run asynchronously without awaiting, so it doesn't block UI
    Future.microtask(() {
      try {
        ref.read(opportunisticBackupServiceProvider).checkAndRunBackup();
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final localeCode = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Cashio',
      theme: AppTheme.lightTheme,
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: ThemeMode.light, // Forcing light mode to focus on polish first
      locale: localeCode != null ? Locale(localeCode) : const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ar'),
        Locale('tr'),
        Locale('de'),
        Locale('fr'),
        Locale('es'),
      ],
      routerConfig: router,
    );
  }
}
