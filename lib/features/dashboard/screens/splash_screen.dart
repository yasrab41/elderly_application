import 'package:elderly_prototype_app/features/authentication/screens/login.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/data/datasources/notification_service.dart';
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. Initialize Firebase
    // We check if it's already initialized to avoid errors during hot reload
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // 2. Initialize Notification Service (The heavy process)
    await NotificationService().init();

    // 3. (Optional) Artificial delay to show logo if loading is too fast
    // await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // 4. Check Authentication State
    // We read the provider directly here to decide where to go
    final user = ref.read(authNotifierProvider);

    // 5. Navigate to the correct screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) =>
            user != null ? const StartScreen() : const Login(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF48352A), // Your App Base Brown
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon or Logo
            const Icon(
              Icons.health_and_safety,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              "HealthCare+",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 40),
            // Loading Spinner
            const CircularProgressIndicator(
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              "Loading your safe routes...",
              style: TextStyle(color: Colors.white70),
            )
          ],
        ),
      ),
    );
  }
}
