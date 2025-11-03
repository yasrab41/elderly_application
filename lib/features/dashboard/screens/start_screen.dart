import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/fitness_screen_old.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/health_screen.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/home_screen.dart' as home;
import 'package:elderly_prototype_app/features/dashboard/screens/setting_screen.dart';
import 'package:flutter/material.dart';

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

  // NOTE: I've updated the screens list to use the provided imports.
  // I will only implement HomeScreen in detail below.

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF48352A), // Base Brown
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          // REMOVED AppBar to avoid conflicts with screen content
          body: _screens[_currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
            color: Color(0xFF48352A),
            backgroundColor: Colors.transparent, // Let content show through
            buttonBackgroundColor: Color(0xFFCa7842),
            height: 60,
            index: _currentIndex,
            items: const [
              Icon(Icons.home, size: 30, color: Colors.white),
              Icon(Icons.health_and_safety, size: 30, color: Colors.white),
              Icon(Icons.run_circle_outlined, size: 30, color: Colors.white),
              Icon(Icons.settings, size: 30, color: Colors.white),
            ],
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
