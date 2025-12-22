import 'package:elderly_prototype_app/core/app_theme.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main() {
  // 1. Ensure bindings are initialized so we can communicate with the OS
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 2. PRESERVE NATIVE SPLASH
  // This keeps the native logo on screen until we are ready to remove it.
  // This prevents the "white screen" flash between Native -> Flutter.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 3. RUN APP INSTANTLY
  // No await Firebase. No await Database. Just run the UI.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Application Prototype',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,
      // Pass control to the Flutter Splash Screen immediately
      home: const SplashScreen(),
    );
  }
}
