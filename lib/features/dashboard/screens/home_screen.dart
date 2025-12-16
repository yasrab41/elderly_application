import 'dart:async'; // For Timer
import 'package:elderly_prototype_app/features/health_tracking/screens/health_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart'; // ⚠️ REQUIRED: Add to pubspec.yaml

import 'package:elderly_prototype_app/core/app_theme.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/emergency/screens/emergency_settings_screen.dart';
import 'package:elderly_prototype_app/features/emergency/providers/contact_provider.dart';

import 'package:elderly_prototype_app/features/dashboard/screens/fitness_screen_old.dart';
import 'package:elderly_prototype_app/features/fitness/screens/fitness_screen.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/screens/reminder_list_page.dart';

// --- 1. Changed to ConsumerStatefulWidget to handle Timer & "Safe Mode" state ---
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // Color Palette
  final Color _baseBrown = const Color(0xFF48352A);
  final Color _lightBrown = const Color(0xFF7B6658);
  final Color _lighterBrown = const Color(0xFFC0A597);
  final Color _redAlert = const Color(0xFFEF5350);
  final Color _greenSafe = const Color(0xFF4CAF50); // Green for Safe button

  // --- STATE VARIABLES ---
  bool _isEmergencyActive =
      false; // Tracks if alert was sent (to show Safe button)
  String _lastSentMessage = ""; // Stores the message to show in dialog

  // Data for the GridView
  final List<Map<String, dynamic>> _gridItems = const [
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
      'title': 'Health Tracking',
      'subtitle': 'Track your health data',
      'icon': Icons.monitor_heart_outlined,
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

  // --- 2. PERMISSION CHECK ---
  Future<bool> _checkPermissions() async {
    // Request multiple permissions at once
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
      Permission.sms, // Crucial for Android to send messages
    ].request();

    if (statuses[Permission.location]!.isDenied ||
        statuses[Permission.phone]!.isDenied ||
        statuses[Permission.sms]!.isDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Permissions required for Emergency Alert')),
        );
      }
      return false;
    }
    return true;
  }

  // --- 3. EMERGENCY LOGIC ---

  void _startEmergencySequence() async {
    // 1. Check Permissions first
    bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) return;

    // 2. Check if contacts exist
    final contactsState = ref.read(contactNotifierProvider);
    final contacts = contactsState.maybeWhen(
      data: (c) => c,
      orElse: () => [],
    );

    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(AppStrings.noContacts)),
        );
      }
      return;
    }

    // 3. Show Countdown Dialog
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CountdownDialog(
          onFinished: () {
            Navigator.pop(context); // Close countdown dialog
            _executeEmergencyAlert(); // Execute Logic
          },
        ),
      );
    }
  }

  Future<void> _executeEmergencyAlert() async {
    // A. Haptic Feedback
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 500);
    }

    try {
      // B. Get Location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Create Message
      String mapLink =
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      String messageRaw = "${AppStrings.emergencyAlertMessage}\n $mapLink";

      setState(() {
        _lastSentMessage = messageRaw;
        _isEmergencyActive = true; // Show "I'm Safe" button
      });

      // C. Get Contacts
      final contacts = ref.read(contactNotifierProvider).value ?? [];

      // D. Send SMS Intent
      final recipientNumbers = contacts.map((c) => c.phoneNumber).join(';');

      // *** FIX FOR PLUS SIGNS ***
      // We use encodeComponent (not QueryComponent) to strictly use %20
      final encodedMessage = Uri.encodeComponent(messageRaw);

      // Manually construct the URI string to avoid Dart's auto-encoding behavior (which uses +)
      final Uri smsUri =
          Uri.parse('sms:$recipientNumbers?body=$encodedMessage');

      if (await canLaunchUrl(smsUri)) {
        // LaunchMode.externalApplication is safer for SMS apps
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      }

      // E. Call Primary Contact
      final primaryContact = contacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => contacts.first,
      );

      await FlutterPhoneDirectCaller.callNumber(primaryContact.phoneNumber);

      // F. Show Confirmation Dialog (What was sent)
      if (mounted) _showAlertSentDialog();
    } catch (e) {
      debugPrint("Error in SOS: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Alert failed: $e")),
        );
      }
    }
  }

  // --- 4. SAFE BUTTON LOGIC ---
  Future<void> _executeSafeAlert() async {
    try {
      final contacts = ref.read(contactNotifierProvider).value ?? [];
      String messageRaw =
          "I AM SAFE NOW. Please disregard the previous emergency alert.";

      final recipientNumbers = contacts.map((c) => c.phoneNumber).join(';');

      // *** FIX FOR PLUS SIGNS ***
      final encodedMessage = Uri.encodeComponent(messageRaw);
      final Uri smsUri =
          Uri.parse('sms:$recipientNumbers?body=$encodedMessage');

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri, mode: LaunchMode.externalApplication);
      }

      setState(() {
        _isEmergencyActive = false; // Hide Safe Button
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              backgroundColor: Colors.green,
              content: Text("Safe alert sent successfully")),
        );
      }
    } catch (e) {
      debugPrint("Error sending safe alert: $e");
    }
  }

  // --- DIALOGS ---

  void _showAlertSentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text("Emergency Sent!",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("The following message was sent to your contacts:",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade100),
              ),
              child:
                  Text(_lastSentMessage, style: const TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 10),
            const Text("Calling primary contact...",
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text("OK")),
        ],
      ),
    );
  }

  // --- BUILD METHOD ---

  @override
  Widget build(BuildContext context) {
    // 🔥 FIX 1: Eagerly load contacts when Home Screen opens.
    // This solves the "No contacts added yet" error on first click!
    ref.watch(contactNotifierProvider);

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

                // --- EMERGENCY SECTION ---
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                  child: Column(
                    children: [
                      // If Alert Sent, show Safe Button
                      if (_isEmergencyActive)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _executeSafeAlert,
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              label: const Text("I'M SAFE NOW",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _greenSafe,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                elevation: 5,
                              ),
                            ),
                          ),
                        ),

                      // Emergency Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _startEmergencySequence,
                          icon:
                              const Icon(Icons.emergency, color: Colors.white),
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
                    ],
                  ),
                ),

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

                      VoidCallback onTapAction;
                      if (item['title'] == 'Medicine Reminders') {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReminderListPage()));
                      } else if (item['title'] == 'Emergency Contacts') {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const EmergencySettingsScreen()));
                      } else if (item['title'] == 'Daily Exercises') {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FitnessScreen()));
                      } else if (item['title'] == 'Health Tracking') {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HealthTrackingScreen()));
                      } else {
                        onTapAction = () {};
                      }

                      return _buildFeatureCard(
                        item['title'],
                        item['subtitle'],
                        item['icon'],
                        item['color'],
                        item['iconColor'],
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

  // --- WIDGET BUILDERS (Unchanged Helpers) ---

  Widget _buildCurvedHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 170.0,
      pinned: true,
      elevation: 10,
      shadowColor: _baseBrown,
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
              color: Colors.white, fontSize: 25.0, fontWeight: FontWeight.bold),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
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
                    Text('Welcome back',
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF48352A))),
                    SizedBox(height: 4),
                    Text('You are doing great. Check your reminders.',
                        style:
                            TextStyle(color: Color(0xFF48352A), fontSize: 16)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, IconData icon,
      Color bgColor, Color iconColor, VoidCallback onTap) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: bgColor,
      child: InkWell(
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
                  Text(title,
                      style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- HELPER: SEPARATE WIDGET FOR TIMER TO PREVENT REBUILDS ---
class _CountdownDialog extends StatefulWidget {
  final VoidCallback onFinished;
  const _CountdownDialog({required this.onFinished});

  @override
  State<_CountdownDialog> createState() => _CountdownDialogState();
}

class _CountdownDialogState extends State<_CountdownDialog> {
  int _seconds = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds <= 1) {
        timer.cancel();
        widget.onFinished();
      } else {
        setState(() {
          _seconds--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("🚨 SOS ALERT",
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("Sending alert in $_seconds",
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          const SizedBox(height: 10),
          const Text("Alerting contacts with your location.",
              textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
          child: const Text("Cancel Alert",
              style: TextStyle(color: Colors.grey, fontSize: 16)),
        )
      ],
    );
  }
}
