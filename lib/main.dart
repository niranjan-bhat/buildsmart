import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (guard prevents duplicate-app error on hot restart)
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  // Firebase App Check (debug provider for development)
  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox<Map>(AppConstants.checklistBox);
  await Hive.openBox(AppConstants.settingsBox);
  await Hive.openBox(AppConstants.userBox);

  runApp(const ProviderScope(child: BuildSmartApp()));
}

class BuildSmartApp extends ConsumerStatefulWidget {
  const BuildSmartApp({super.key});

  @override
  ConsumerState<BuildSmartApp> createState() => _BuildSmartAppState();
}

class _BuildSmartAppState extends ConsumerState<BuildSmartApp> {
  @override
  void initState() {
    super.initState();
    _initFcm();
  }

  void _initFcm() {
    final fcmService = ref.read(fcmServiceProvider);
    fcmService.initialize(
      onForegroundMessage: (message) {
        debugPrint('FCM Foreground: ${message.notification?.title}');
        // Show in-app notification snackbar if needed
      },
      onMessageOpenedApp: (message) {
        debugPrint('FCM Opened: ${message.data}');
        // Navigate based on message data
        final projectId = message.data['projectId'] as String?;
        final imageId = message.data['imageId'] as String?;
        if (projectId != null && imageId != null) {
          ref.read(routerProvider).go('/projects/$projectId/analysis/$imageId');
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(_themeModeProvider);

    final locale = ref.watch(localProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

final _themeModeProvider = StateProvider<ThemeMode>((ref) {
  final box = Hive.box(AppConstants.settingsBox);
  final stored = box.get(AppConstants.themeKey, defaultValue: 'system') as String;
  switch (stored) {
    case 'dark':
      return ThemeMode.dark;
    case 'light':
      return ThemeMode.light;
    default:
      return ThemeMode.system;
  }
});

// Exported so SettingsScreen can toggle it
final themeModeProvider = _themeModeProvider;

final _localProvider = StateProvider<Locale>((ref) {
  final code = Hive.box(AppConstants.settingsBox)
      .get(AppConstants.languageKey, defaultValue: 'en') as String;
  return Locale(code);
});

// Exported so SettingsScreen can switch locale
final localProvider = _localProvider;
