import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';

class CurvedBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CurvedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      color: const Color(0xFF48352A),
      backgroundColor: Colors.transparent, // Let content show through
      buttonBackgroundColor: const Color(0xFFCa7842),
      height: 60,
      index: currentIndex,
      items: const [
        Icon(Icons.home, size: 30, color: Colors.white),
        Icon(Icons.health_and_safety, size: 30, color: Colors.white),
        Icon(Icons.run_circle_outlined, size: 30, color: Colors.white),
        Icon(Icons.settings, size: 30, color: Colors.white),
      ],
      onTap: onTap, // Pass the tap event up to the parent
    );
  }
}
