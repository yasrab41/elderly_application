import 'package:elderly_prototype_app/core/app_theme.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: Remove Firebase/Notification imports from here, they are in Splash Screen now

void main() {
  // Only keep this. It is fast.
  WidgetsFlutterBinding.ensureInitialized();

  // RUN APP IMMEDIATELY. Do not await anything here.
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Note: We don't need to watch auth here anymore for the 'home' property,
    // because SplashScreen decides where to go once loading is done.

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Application Prototype',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light,

      // Point home to the Splash Screen
      home: const SplashScreen(),
    );
  }
}
