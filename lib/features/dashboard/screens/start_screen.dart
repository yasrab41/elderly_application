import 'package:elderly_prototype_app/features/dashboard/screens/fitness_screen_old.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/health_screen.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/home_screen.dart'
    as home;
import 'package:elderly_prototype_app/features/dashboard/screens/setting_screen.dart';
import 'package:flutter/material.dart';

// 1. Import the new reusable navigation widget
import 'widgets/curved_bottom_nav.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  // Set index to 0 for the HomeScreen to be the initial page
  int _currentIndex = 0;
  final List<Widget> _screens = [
    home.HomeScreen(),
    HealthScreen(),
    // Using placeholder screens for other pages
    FitnessScreen(),
    SettingScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF48352A), // Base Brown
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          body: _screens[_currentIndex],

          // 2. Use the new, cleaner widget here
          bottomNavigationBar: CurvedBottomNav(
            currentIndex: _currentIndex,
            onTap: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
          ),
        ),
      ),
    );
  }
}
