import 'package:flutter/material.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HealthScreenState createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  // We'll manage scroll offset to drive animations
  double _scrollOffset = 0.0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Define a color palette inspired by Image 3 (brown) and Image 4 (soft pastels)
  final Color _primaryBrown = Color(0xFF6B4226); // Darker brown from Image 3
  final Color _softBlue = Color(0xFFE3F2FD); // Light blue
  final Color _softPink = Color(0xFFFCE4EC); // Light pink
  final Color _softGreen = Color(0xFFE8F5E9); // Light green
  final Color _softOrange = Color(0xFFFFF3E0); // Light orange
  final Color _redAlert = Color(0xFFEF5350); // Red for emergency
  final Color _textColor = Colors.grey.shade800; // General text color

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8), // Very light grey background
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            backgroundColor:
                Color(0xFFF8F8F8), // Match background or a very light color
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: _textColor),
              onPressed: () {
                // Navigate back
              },
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.mic, color: _textColor),
                onPressed: () {
                  // Voice command functionality
                },
              ),
            ],
            expandedHeight: 180.0, // Adjust height as needed
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: false,
              titlePadding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              title: Text(
                'HealthCare+',
                style: TextStyle(
                  color: _textColor,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            pinned: true,
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Emergency Access Section
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        margin: EdgeInsets.only(bottom: 20.0),
                        child: Container(
                          padding: EdgeInsets.all(20.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emergency Access',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: _textColor,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Quick access to emergency services and contacts',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    // Trigger emergency alert
                                  },
                                  icon: Icon(Icons.emergency,
                                      color: Colors.white),
                                  label: Text(
                                    'Send Emergency Alert',
                                    style: TextStyle(
                                        fontSize: 16.0, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _redAlert, // Emergency red
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Emergency contacts: John Smith, Sarah Johnson',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: _redAlert.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Grid of Health Features
                      Text(
                        'Your Health Hub',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: _textColor,
                        ),
                      ),
                      SizedBox(height: 15),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 1.0, // Square cards
                        ),
                        itemCount: 5, // Number of items in the grid
                        itemBuilder: (context, index) {
                          // Calculate animation properties based on scroll offset
                          final double cardOffset =
                              index * 120.0; // Estimate card height + spacing
                          final double startAnimationOffset =
                              200.0; // Start animating when scroll reaches this point
                          final double endAnimationOffset = startAnimationOffset +
                              (MediaQuery.of(context).size.height /
                                  2); // End animation over half screen height

                          double opacity = 0.0;
                          double translateY = 50.0;

                          if (_scrollOffset >
                              cardOffset - startAnimationOffset) {
                            final double progress = ((_scrollOffset -
                                        (cardOffset - startAnimationOffset)) /
                                    (endAnimationOffset - startAnimationOffset))
                                .clamp(0.0, 1.0);
                            opacity = progress;
                            translateY = 50.0 * (1.0 - progress);
                          }

                          return Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(0, translateY),
                              child: _buildHealthFeatureCard(index),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Note: CurvedNavigationBar is assumed to be in your parent screen
      // If you want a basic bottom nav here for testing, uncomment below:
      /*
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _primaryBrown,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medical_services), label: 'Health'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center), label: 'Fitness'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Social'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      */
    );
  }

  Widget _buildHealthFeatureCard(int index) {
    String title;
    String subtitle;
    IconData icon;
    Color bgColor;

    switch (index) {
      case 0:
        title = 'On-Duty Pharmacies';
        subtitle = 'Find open pharmacies nearby';
        icon = Icons.local_pharmacy;
        bgColor = _softPink;
        break;
      case 1:
        title = 'Medicine Reminders';
        subtitle = 'Set medication schedules';
        icon = Icons.medical_services;
        bgColor = _softBlue;
        break;
      case 2:
        title = 'Daily Exercises';
        subtitle = 'Simple fitness routines';
        icon = Icons.fitness_center;
        bgColor = _softGreen;
        break;
      case 3:
        title = 'Social Activities';
        subtitle = 'Community events nearby';
        icon = Icons.people;
        bgColor = _softOrange;
        break;
      case 4:
        title = 'Brain Games';
        subtitle = 'Keep your mind sharp';
        icon = Icons.lightbulb_outline;
        bgColor = _softBlue; // Re-using for variety
        break;
      default:
        title = 'Feature';
        subtitle = 'Explore more';
        icon = Icons.more_horiz;
        bgColor = Colors.grey.shade200;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: bgColor,
      child: InkWell(
        onTap: () {
          // Handle card tap
          print('$title tapped!');
        },
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 28, color: _textColor.withOpacity(0.7)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey[600],
                    ),
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
