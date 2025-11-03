import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/fitness_screen_old.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/health_screen.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/home_screen.dart';
import 'package:elderly_prototype_app/features/dashboard/screens/setting_screen.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _currentIndex = 2;
  final List<Widget> _screens = [
    HomeScreen(),
    HealthScreen(),
    FitnessScreen(),
    SettingScreen(),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF48352A),
      child: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFF48352A),
            foregroundColor: Colors.white,
            centerTitle: true,
            title: Text('Elderly App Prototype'),
          ),
          body: _screens[_currentIndex],
          bottomNavigationBar: CurvedNavigationBar(
            color: Color(0xFF48352A),
            backgroundColor: Colors.transparent,
            buttonBackgroundColor: Color(0xFFCa7842),
            height: 60,
            index: _currentIndex,
            items: [
              Icon(
                Icons.home,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.health_and_safety,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.run_circle_outlined,
                size: 30,
                color: Colors.white,
              ),
              Icon(
                Icons.settings,
                size: 30,
                color: Colors.white,
              ),
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
