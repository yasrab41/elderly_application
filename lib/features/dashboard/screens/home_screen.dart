import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:vibration/vibration.dart';

import 'package:elderly_prototype_app/core/app_theme.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/emergency/screens/emergency_settings_screen.dart';
import 'package:elderly_prototype_app/features/emergency/providers/contact_provider.dart';

import 'package:elderly_prototype_app/features/dashboard/screens/fitness_screen_old.dart';
import 'package:elderly_prototype_app/features/fitness/screens/fitness_screen.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/screens/reminder_list_page.dart';
import 'package:flutter/material.dart';

// ⚠️ IMPORTANT: You must create this file (e.g., reminder_list_page.dart)
// and define the ReminderListPage class for this code to run.
// For now, it's included here as a basic placeholder.

class HomeScreen extends ConsumerWidget {
  HomeScreen({super.key});

  // Color Palette
  final Color _baseBrown = const Color(0xFF48352A);
  final Color _lightBrown = const Color(0xFF7B6658);
  final Color _lighterBrown = const Color(0xFFC0A597);
  final Color _redAlert = const Color(0xFFEF5350);
  final Color _textColor = Colors.grey.shade800;

  // Data for the GridView
  final List<Map<String, dynamic>> _gridItems = const [
    // {
    //   'title': 'On-Duty Pharmacies',
    //   'subtitle': 'Find open pharmacies nearby',
    //   'icon': Icons.local_hospital_outlined,
    //   'color': Color(0xFFFCE4EC),
    //   'iconColor': Color(0xFFE91E63),
    // },
    {
      'title': 'Emergency Contacts',
      'subtitle': AppStrings.sosSettingsSubtitle,
      'icon': Icons.admin_panel_settings_outlined,
      'color': Color(0xFFFCE4EC),
      'iconColor': Color(0xFFE91E63),
    },
    {
      'title': 'Medicine Reminders',
      'subtitle': 'Set medication schedules',
      'icon': Icons.medical_information_outlined,
      'color': Color(0xFFE3F2FD),
      'iconColor': Color(0xFF2196F3),
    },
    {
      'title': 'Daily Exercises',
      'subtitle': 'Simple fitness routines',
      'icon': Icons.directions_run_outlined,
      'color': Color(0xFFE8F5E9),
      'iconColor': Color(0xFF4CAF50),
    },
    {
      'title': 'Social Activities',
      'subtitle': 'Community events nearby',
      'icon': Icons.groups_outlined,
      'color': Color(0xFFFFF3E0),
      'iconColor': Color(0xFFFF9800),
    },
    {
      'title': 'Brain Games',
      'subtitle': 'Keep your mind sharp',
      'icon': Icons.lightbulb_outline,
      'color': Color(0xFFF3E5F5),
      'iconColor': Color(0xFF9C27B0),
    },
  ];

  // --- 1. EMERGENCY LOGIC START ---

  Future<void> _executeEmergencyAlert(
      BuildContext context, WidgetRef ref) async {
    // A. Get Contacts
    final contactsState = ref.read(contactNotifierProvider);
    final contacts = contactsState.maybeWhen(
      data: (c) => c,
      orElse: () => [],
    );

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.noContacts)),
      );
      return;
    }

    // B. Haptic Feedback
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 500);
    }

    try {
      // C. Get Location
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Create Google Maps Link
      String mapLink =
          "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
      String message = "${AppStrings.emergencyAlertMessage} $mapLink";

      // D. Send SMS (Using url_launcher for safety/reliability)
      // This creates a group SMS intent
      final recipientNumbers = contacts.map((c) => c.phoneNumber).join(';');
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: recipientNumbers,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }

      // E. Call Primary Contact
      final primaryContact = contacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => contacts.first,
      );

      await FlutterPhoneDirectCaller.callNumber(primaryContact.phoneNumber);
    } catch (e) {
      debugPrint("Error in SOS: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Alert failed: $e")),
      );
    }
  }

  // --- EMERGENCY LOGIC END ---

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Curved Top Header
          _buildCurvedHeader(context),

          // 2. Main Content
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildWelcomeStatusCard(),

                // 2. Pass context and ref to the button builder
                _buildEmergencyButton(context, ref),

                // Health Hub Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
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
                      childAspectRatio: 0.9,
                    ),
                    itemCount: _gridItems.length,
                    itemBuilder: (context, index) {
                      final item = _gridItems[index];
                      // 🚀 NEW FUNCTIONALITY: Determine the onTap function based on the item title
                      VoidCallback onTapAction;

                      if (item['title'] == 'Medicine Reminders') {
                        // This is the specific navigation logic requested
                        onTapAction = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReminderListPage(),
                            ),
                          );
                        };
                      } else if (item['title'] == 'Emergency Contacts') {
                        onTapAction = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const EmergencySettingsScreen()),
                          );
                        };
                      } else if (item['title'] == 'Daily Exercises') {
                        onTapAction = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FitnessScreen(),
                            ),
                          );
                        };
                      } else if (item['title'] == 'Social Activities') {
                        onTapAction = () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FitnessScreen2(),
                            ),
                          );
                        };
                      } else {
                        // Placeholder for future features
                        onTapAction = () {
                          // Placeholder logic for other features
                          debugPrint('Tapped on: ${item['title']}');
                        };
                      }

                      return _buildFeatureCard(
                        item['title'] as String,
                        item['subtitle'] as String,
                        item['icon'] as IconData,
                        item['color'] as Color,
                        item['iconColor'] as Color,
                        // Pass the determined onTap action
                        onTapAction,
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
      expandedHeight: 170.0,
      pinned: true,
      elevation: 10,
      shadowColor: _baseBrown,
      // leading: IconButton(
      //   icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      //   onPressed: () => Navigator.of(context).pop(),
      // ),
      actions: [
        IconButton(
          icon: const Icon(Icons.mic, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 35.0, bottom: 16.0),
        title: const Text(
          'HealthCare+',
          style: TextStyle(
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
      padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 15.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
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
                      'Welcome back',
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

  // Widget _buildEmergencyButton() {
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
  //     child: SizedBox(
  //       width: double.infinity,
  //       child: ElevatedButton.icon(
  //         onPressed: () {
  //           // Trigger emergency alert logic
  //         },
  //         icon: const Icon(Icons.emergency, color: Colors.white),
  //         label: const Text(
  //           'Send Emergency Alert',
  //           style: TextStyle(
  //               fontSize: 18.0,
  //               color: Colors.white,
  //               fontWeight: FontWeight.bold),
  //         ),
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: _redAlert,
  //           padding: const EdgeInsets.symmetric(vertical: 18),
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(15.0),
  //           ),
  //           elevation: 5,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Widget _buildEmergencyButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () {
            // Show Countdown Dialog
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (dialogContext) =>
                  _buildCountdownDialog(dialogContext, context, ref),
            );
          },
          icon: const Icon(Icons.emergency, color: Colors.white),
          label: const Text(AppStrings.sosTitle,
              style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.white,
                  fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: _redAlert,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            elevation: 5,
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownDialog(
      BuildContext dialogContext, BuildContext parentContext, WidgetRef ref) {
    return StatefulBuilder(
      builder: (context, setState) {
        int countdown = 5;

        Timer? timer;

        void startTimer() {
          timer = Timer.periodic(const Duration(seconds: 1), (t) {
            if (countdown <= 1) {
              t.cancel();
              if (Navigator.canPop(context)) Navigator.pop(context);
              _executeEmergencyAlert(parentContext, ref);
            } else {
              countdown--;
              if (context.mounted) setState(() {});
            }
          });
        }

        // Start timer only once
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (timer == null) {
            startTimer();
          }
        });

        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text("🚨 SOS ALERT",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sending alert in $countdown",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text("Alerting contacts with your location.",
                  textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                timer?.cancel();
                Navigator.pop(context);
              },
              child: const Text("Cancel",
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
            )
          ],
        );
      },
    );
  }

  // Widget _buildCountdownDialog(
  //     BuildContext dialogContext, BuildContext parentContext, WidgetRef ref) {
  //   int countdown = 5;
  //   return StatefulBuilder(
  //     builder: (context, setState) {
  //       // Simple timer logic
  //       if (countdown == 5) {
  //         Timer.periodic(const Duration(seconds: 1), (timer) {
  //           if (countdown == 1) {
  //             timer.cancel();
  //             if (context.mounted) Navigator.pop(context); // Close dialog
  //             _executeEmergencyAlert(parentContext, ref); // Trigger Logic
  //           } else {
  //             if (context.mounted) {
  //               setState(() => countdown--);
  //             }
  //           }
  //         });
  //       }

  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: const Text("🚨 SOS ALERT",
  //             style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text("${AppStrings.sosSendingAlert} $countdown",
  //                 style: const TextStyle(
  //                     fontSize: 20, fontWeight: FontWeight.bold)),
  //             const SizedBox(height: 10),
  //             const Text("Alerting contacts with your location.",
  //                 textAlign: TextAlign.center),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(
  //                   context); // This cancels the timer implicitly by unmounting
  //             },
  //             child: const Text(AppStrings.sosCancelButton,
  //                 style: TextStyle(
  //                     color: Colors.green,
  //                     fontSize: 16,
  //                     fontWeight: FontWeight.bold)),
  //           )
  //         ],
  //       );
  //     },
  //   );
  // }

  // MODIFIED: Accepts a VoidCallback onTap parameter to handle navigation
  Widget _buildFeatureCard(String title, String subtitle, IconData icon,
      Color bgColor, Color iconColor, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      color: bgColor,
      child: InkWell(
        // Use the passed-in onTap function for navigation/action
        onTap: onTap,
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
                      color: Colors.black87,
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
