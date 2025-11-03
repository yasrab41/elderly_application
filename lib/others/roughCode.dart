import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F2F5), // Light grey background
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Color(0xFF5D5FEF), // Purple-blue for the app bar
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.only(left: 16.0, bottom: 16.0),
              title: Text(
                'Training',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5D5FEF), Color(0xFF8B7FFD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: () {}),
              IconButton(icon: Icon(Icons.save), onPressed: () {}),
              IconButton(icon: Icon(Icons.arrow_forward_ios), onPressed: () {}),
            ],
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your program',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 10),
                      // Next Workout Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF5D5FEF), Color(0xFF8B7FFD)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Next workout',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Legs Toning\nand Glutes Workout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Icon(Icons.timer,
                                            color: Colors.white70, size: 18),
                                        SizedBox(width: 5),
                                        Text('60 min',
                                            style: TextStyle(
                                                color: Colors.white70)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: Colors.white,
                                child: Icon(Icons.play_arrow,
                                    color: Color(0xFF5D5FEF)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Encouragement Card
                      Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              // Placeholder for the running figure image
                              Container(
                                width: 80,
                                height: 80,
                                // You would use an Image.asset or Image.network here
                                // For now, a colored box
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Center(
                                    child: Text('🏃‍♀️',
                                        style: TextStyle(fontSize: 40))),
                              ),
                              SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'You are doing great',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    Text(
                                      'keep it up\nstick to your plan',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Area of focus',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      // GridView for Area of Focus
                      GridView.count(
                        shrinkWrap:
                            true, // Important to allow GridView inside a Column/ListView
                        physics:
                            NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        childAspectRatio: 1.2, // Adjust as needed
                        children: [
                          _buildFocusCard('Glutes', Colors.pink.shade50),
                          _buildFocusCard('Abs', Colors.blue.shade50),
                          _buildFocusCard('Arms', Colors.green.shade50),
                          _buildFocusCard('Legs', Colors.orange.shade50),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Circuit 1: Legs Toning',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 10),
                      // List of exercises (from Image 1)
                      _buildExerciseTile(
                          'Plie Squat and Heel Raises', '55 seconds'),
                      SizedBox(height: 15),
                      _buildExerciseTile('Squat Kickback', '60 seconds'),
                      SizedBox(height: 15),
                      _buildExerciseTile(
                          'Squat with Side Leg Lift', '120 seconds'),
                      SizedBox(height: 15),
                      _buildExerciseTile('Lunges',
                          '45 seconds'), // Example additional exercise
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color(0xFF5D5FEF),
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: 'Workouts'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildFocusCard(String title, Color backgroundColor) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: backgroundColor, // Background color for the card
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for icon/image
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.category, color: Colors.grey), // Example icon
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseTile(String title, String duration) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors
                    .grey[300], // Placeholder for exercise video thumbnail
              ),
              child:
                  Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
            ),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    duration,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            // You can add a trailing icon here if needed, like an info icon
          ],
        ),
      ),
    );
  }
}
