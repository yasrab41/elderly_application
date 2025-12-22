import 'package:elderly_prototype_app/features/dashboard/screens/profile_screen/profile_screen.dart';

import 'package:elderly_prototype_app/features/dashboard/screens/home_screen.dart'
    as home;
import 'package:elderly_prototype_app/features/fitness/screens/fitness_screen.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/screens/reminder_list_page.dart';

import 'package:flutter/material.dart';

import 'widgets/curved_bottom_nav.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 0;

  // 2. Update the screens list
  final List<Widget> _screens = [
    home.HomeScreen(),
    ReminderListPage(),
    FitnessScreen(),
    const ProfileScreen(),
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
