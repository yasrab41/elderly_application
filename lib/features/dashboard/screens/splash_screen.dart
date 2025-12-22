import 'package:elderly_prototype_app/features/authentication/screens/login.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/data/datasources/notification_service.dart';
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrapApp();
  }

  Future<void> _bootstrapApp() async {
    // ---------------------------------------------------------
    // 1. REMOVE NATIVE SPLASH IMMEDIATELY
    // ---------------------------------------------------------
    // Do not await anything before this. This reveals your Flutter UI
    // (the brown background + spinner) instantly.
    FlutterNativeSplash.remove();

    // ---------------------------------------------------------
    // 2. PARALLEL INITIALIZATION
    // ---------------------------------------------------------
    // We use a try-catch so one failure doesn't crash the app startup.
    try {
      await Future.wait([
        // Task A: Firebase
        Firebase.apps.isEmpty
            ? Firebase.initializeApp(
                options: DefaultFirebaseOptions.currentPlatform)
            : Future.value(),

        // Task B: Notifications (The likely culprit of the 30s delay)
        // We ensure this doesn't block the UI even if it's slow.
        _initNotificationsSafe(),

        // Task C: Minimum delay (so the spinner is visible for at least 1.5s)
        Future.delayed(const Duration(milliseconds: 1500)),
      ]);
    } catch (e) {
      debugPrint("Startup Error: $e");
    }

    if (!mounted) return;

    // ---------------------------------------------------------
    // 3. NAVIGATE
    // ---------------------------------------------------------
    final user = ref.read(authNotifierProvider);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
            user != null ? const StartScreen() : const Login(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  // Wrapper to prevent Notification errors from stopping app launch
  Future<void> _initNotificationsSafe() async {
    try {
      // If this takes 30s, it runs in background while spinner spins
      await NotificationService().init();
    } catch (e) {
      debugPrint("Notification Init Failed: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF48352A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.health_and_safety, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text(
              "HealthCare+",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
