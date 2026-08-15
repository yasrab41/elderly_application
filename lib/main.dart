import 'package:elderly_prototype_app/core/app_theme.dart';
import 'package:elderly_prototype_app/core/localization/app_language.dart';
import 'package:elderly_prototype_app/core/localization/language_controller.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ADD THIS

Future<void> main() async {
  // 1. Ensure bindings are initialized so we can communicate with the OS
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. Load .env BEFORE anything else uses it
  await dotenv.load(fileName: ".env");

  // 2b. Resolve starting language (saved choice, or device language as a
  // fallback) before the first frame — avoids any flash of the wrong
  // language on first launch.
  await AppLanguageController.initialize();

  // 3. PRESERVE NATIVE SPLASH
  // This keeps the native logo on screen until we are ready to remove it.
  // This prevents the "white screen" flash between Native -> Flutter.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 4. RUN APP INSTANTLY
  // No await Firebase. No await Database. Just run the UI.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Rebuilding MaterialApp with a new `key` whenever the language changes
    // guarantees every screen re-reads AppStrings fresh — including ones
    // already open. The tradeoff: this resets the navigation stack back to
    // the splash/start screen, since AppStrings isn't hooked into Flutter's
    // normal InheritedWidget rebuild propagation. Acceptable for a
    // deliberate, rarely-used settings action.
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: AppLanguageController.notifier,
      builder: (context, language, _) {
        return MaterialApp(
          key: ValueKey(language),
          debugShowCheckedModeBanner: false,
          title: 'Elderly Application Prototype',
          theme: AppTheme.lightTheme,
          themeMode: ThemeMode.light,
          // Pass control to the Flutter Splash Screen immediately
          home: const SplashScreen(),
        );
      },
    );
  }
}
