import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({super.key});

  // Color Palette
  final Color _baseBrown = const Color(0xFF48352A);
  final Color _lightBrown = const Color(0xFF7B6658);
  final Color _lighterBrown = const Color(0xFFC0A597);
  final Color _redAlert = const Color(0xFFEF5350);
  final Color _textColor = Colors.grey.shade800;

  // Data for the GridView
  final List<Map<String, dynamic>> _gridItems = const [
    {
      'title': 'On-Duty Pharmacies',
      'subtitle': 'Find open pharmacies nearby',
      'icon': Icons.local_hospital_outlined,
      'color': Color(0xFFFCE4EC),
      'iconColor': Color(0xFFE91E63)
    },
    {
      'title': 'Medicine Reminders',
      'subtitle': 'Set medication schedules',
      'icon': Icons.medical_information_outlined,
      'color': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF2196F3)
    },
    {
      'title': 'Daily Exercises',
      'subtitle': 'Simple fitness routines',
      'icon': Icons.directions_run_outlined,
      'color': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF4CAF50)
    },
    {
      'title': 'Social Activities',
      'subtitle': 'Community events nearby',
      'icon': Icons.groups_outlined,
      'color': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFFF9800)
    },
    {
      'title': 'Brain Games',
      'subtitle': 'Keep your mind sharp',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFFF3E5F5),
      'iconColor': Color(0xFF9C27B0)
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Curved Top Header (Stays pinned when condensed)
          _buildCurvedHeader(context),

          // 2. Main Content
          SliverList(
            delegate: SliverChildListDelegate(
              [
                // 🚀 ADJUSTMENT 1: Welcome Status Card moved here (was below Emergency)
                _buildWelcomeStatusCard(),

                // 🚀 ADJUSTMENT 2: Emergency Access Button (Reduced top margin)
                _buildEmergencyButton(),

                // 🚀 ADJUSTMENT 3: Health Hub Title (Reduced top padding for closer alignment)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                  child: Text(
                    'Your Health Hub',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: _baseBrown,
                    ),
                  ),
                ),

                // 3. GridView for Features
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      // Aspect Ratio fix remains to prevent overflow
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _gridItems.length,
                    itemBuilder: (context, index) {
                      final item = _gridItems[index];
                      return _buildFeatureCard(
                        item['title'] as String,
                        item['subtitle'] as String,
                        item['icon'] as IconData,
                        item['color'] as Color,
                        item['iconColor'] as Color,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget Builders ---

  Widget _buildCurvedHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 160.0,
      // 🚀 Pinned: true ensures the AppBar "freezes" at the top when scrolling
      pinned: true,
      elevation: 10,
      shadowColor: _baseBrown, // This color appears when the AppBar is pinned

      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.mic, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 35.0, bottom: 16.0),
        title: Text(
          'HealthCare+',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_baseBrown, _lightBrown],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(50),
              bottomRight: Radius.circular(50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeStatusCard() {
    return Padding(
      // Adjusted top margin to pull it up closer to the curved header
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        // Used a slightly warmer, less opaque lighter brown
        color: _lighterBrown.withOpacity(0.55),
        child: const Padding(
          padding: EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text('👋', style: TextStyle(fontSize: 30)),
              SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, John!',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF48352A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'You are doing great. Check your reminders.',
                      style: TextStyle(color: Color(0xFF48352A), fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton() {
    return Padding(
      // Reduced top margin for closer spacing with the welcome card
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Trigger emergency alert logic
          },
          icon: const Icon(Icons.emergency, color: Colors.white),
          label: const Text(
            'Send Emergency Alert',
            style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: _redAlert,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon,
      Color bgColor, Color iconColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: bgColor,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 34, color: iconColor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87, // Use strong color for title
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
