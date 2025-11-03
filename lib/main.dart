import 'package:elderly_prototype_app/firebase_options.dart';
// Note: Keeping the signup import, but it won't be the home for now
// import 'package:elderly_prototype_app/features/authentication/screens/signup3.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <--- NEW

// --- Imports for Medicine Reminder Feature ---
import 'core/app_theme.dart'; // <--- NEW: Your custom theme
import 'features/medicine_reminders/screens/reminder_list_page.dart'; // <--- NEW: The page you requested
import 'features/medicine_reminders/data/datasources/notification_service.dart'; // <--- NEW: Notification setup

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase Initialization (already here)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Notification Service Initialization (Must be called before runApp)
  await NotificationService().init(); // <--- NEW

  // 3. Run the app wrapped in ProviderScope for Riverpod
  runApp(const ProviderScope(child: MyApp())); // <--- UPDATED
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Elderly Application Prototype',

      // 1. Set the Custom Theme
      theme: AppTheme.lightTheme, // <--- NEW

      // 2. Set the requested Home Screen
      // NOTE: Temporarily set to ReminderListPage as requested.
      //       Later, this will likely be your HomeScreen or LoginScreen.
      home: const ReminderListPage(), // <--- UPDATED
    );
  }
}
