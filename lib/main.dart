// 1. Remove unused imports
// import 'package:elderly_prototype_app/features/authentication/screens/signup.dart';
// import 'features/medicine_reminders/screens/reminder_list_page.dart';

// 2. Add required imports for the Auth Gate
import 'package:elderly_prototype_app/features/authentication/screens/login.dart';
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/app_theme.dart';
import 'features/medicine_reminders/data/datasources/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Notification Service must be initialized before running the app
  await NotificationService().init();
  runApp(const ProviderScope(child: MyApp()));
}

// 3. Change to ConsumerWidget
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  // 4. Add WidgetRef ref to the build method
  Widget build(BuildContext context, WidgetRef ref) {
    // 5. Watch the auth provider. The state is User? (nullable Firebase User).
    final user = ref.watch(authNotifierProvider);

    // Check if the user object is not null (i.e., user is logged in).
    final isLoggedIn = user != null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Application Prototype',
      theme: AppTheme.lightTheme,
      themeMode: ThemeMode.light, // Force light mode

      // 6. 🛑 IMPLEMENT THE AUTH GATE using a simple null check 🛑
      home: isLoggedIn
          ? const StartScreen() // If user is logged in (User is not null)
          : const Login(), // If user is not logged in (User is null)

      // Note: This implementation assumes the Firebase initialization is fast.
      // If you need a proper "Loading" screen while Firebase checks the state,
      // you would need to introduce an AsyncValue wrapper or a separate boolean
      // state in your AuthNotifier to track initialization status.
      // However, for simplicity and to match the current provider's return type (User?),
      // the direct check is used.
    );
  }
}
