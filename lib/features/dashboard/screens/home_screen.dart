import 'dart:async';
import 'dart:io'; // NEW: Required for platform checking
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/features/brain_games/screens/brain_games_dashboard.dart';
import 'package:elderly_prototype_app/features/chatbot/screens/chatbot_screen.dart';
import 'package:elderly_prototype_app/features/water_reminder/screens/water_reminder_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:vibration/vibration.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_sms/background_sms.dart'; // NEW: Background SMS package

// Feature Imports
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/emergency/screens/emergency_settings_screen.dart';
import 'package:elderly_prototype_app/features/emergency/providers/contact_provider.dart';
import 'package:elderly_prototype_app/features/fitness/screens/fitness_screen.dart';
import 'package:elderly_prototype_app/features/health_tracking/screens/health_tracking_screen.dart';
import 'package:elderly_prototype_app/features/medicine_reminders/screens/reminder_list_page.dart';
import 'package:elderly_prototype_app/features/nearby_services/screens/nearby_services_hub_screen.dart';
import 'package:elderly_prototype_app/core/localization/app_language.dart';
import 'package:elderly_prototype_app/core/localization/language_controller.dart';
import 'package:elderly_prototype_app/features/friend_network/screens/friend_network_hub_screen.dart';
import 'package:elderly_prototype_app/features/friend_network/providers/notifications_provider.dart';

import 'package:provider/provider.dart' as provider; // Add 'as provider'
import 'package:elderly_prototype_app/features/chatbot/providers/chat_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const Color _baseBrown = Color(0xFF48352A);
  static const Color _lightBrown = Color(0xFF7B6658);
  static const Color _lighterBrown = Color(0xFFC0A597);
  static const Color _redAlert = Color(0xFFEF5350);
  static const Color _greenSafe = Color(0xFF4CAF50);

  bool _isEmergencyActive = false;
  String _lastSentMessage = "";

  // Not const anymore: some entries reference AppStrings getters that
  // resolve based on the current language, not fixed compile-time values.
  // A getter (re-evaluated on every access) instead of a static const field
  // is required both to compile and to actually pick up language changes.
  List<Map<String, dynamic>> get _gridItems => [
        {
          'title': AppStrings.sosSettingsTitle,
          'subtitle': AppStrings.sosSettingsSubtitle,
          'icon': Icons.admin_panel_settings_outlined,
          'color': Color(0xFFFCE4EC),
          'iconColor': Color(0xFFE91E63),
        },
        {
          'title': AppStrings.medicineRemindersTitle,
          'subtitle': AppStrings.medicineRemindersGridSubtitle,
          'icon': Icons.medical_information_outlined,
          'color': Color(0xFFE8F5E9),
          'iconColor': Color(0xFF4CAF50),
        },
        {
          'title': AppStrings.fitnessTitle,
          'subtitle': AppStrings.fitnessGridSubtitle,
          'icon': Icons.directions_run_outlined,
          'color': Color(0xFFFFF3E0),
          'iconColor': Color(0xFFFF9800),
        },
        {
          'title': AppStrings.healthTitle,
          'subtitle': AppStrings.healthGridSubtitle,
          'icon': Icons.monitor_heart_outlined,
          'color': Color(0xFFEAEDFF),
          'iconColor': Color(0xFF3F51B5),
        },
        {
          'title': AppStrings.waterTitle,
          'subtitle': AppStrings.waterGridSubtitle,
          'icon': Icons.water_drop_outlined,
          'color': Color.fromARGB(255, 219, 237, 252),
          'iconColor': Color(0xFF2196F3),
        },
        {
          'title': AppStrings.brainGamesTitle,
          'subtitle': AppStrings.brainGamesGridSubtitle,
          'icon': Icons.games_rounded,
          'color': Color(0xFFF3E5F5),
          'iconColor': Color(0xFF9C27B0),
        },
        {
          'title': AppStrings.chatbotTitle,
          'subtitle': AppStrings.chatbotGridSubtitle,
          'icon': Icons.support_agent,
          'color': Color.fromARGB(255, 243, 226, 233),
          'iconColor': Color.fromARGB(255, 176, 39, 119),
        },
        {
          'title': AppStrings.nearbyServicesTitle,
          'subtitle': AppStrings.nearbyServicesGridSubtitle,
          'icon': Icons.map_rounded,
          'color': Color(0xFFE0F7FA),
          'iconColor': Color(0xFF00838F),
        },
        {
          'title': AppStrings.friendNetworkTitle,
          'subtitle': AppStrings.friendNetworkHubSubtitle,
          'icon': Icons.people_alt_rounded,
          'color': Color(0xFFF3E5F5),
          'iconColor': Color(0xFF8E24AA),
        },
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPermissionsSilent();
    });
  }

  Future<void> _checkPermissionsSilent() async {
    await [
      Permission.location,
      Permission.phone,
      Permission.sms,
    ].request();
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.phone,
      Permission.sms,
    ].request();

    // DEBUG: Check what the phone actually says
    print("SMS Permission: ${statuses[Permission.sms]}");
    print("Location Permission: ${statuses[Permission.location]}");
    if (statuses[Permission.location]!.isDenied ||
        statuses[Permission.phone]!.isDenied ||
        statuses[Permission.sms]!.isDenied) {
      print("SMS PERMISSION WAS DENIED BY USER");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppStrings.emergencyPermissionsRequiredMessage)),
        );
      }
      return false;
    }
    return true;
  }

  void _startEmergencySequence() async {
    bool hasPermissions = await _checkPermissions();
    if (!hasPermissions) return;

    final contactsState = ref.read(contactNotifierProvider);
    final contacts = contactsState.maybeWhen(
      data: (c) => c,
      orElse: () => [],
    );

    if (contacts.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.noContacts)),
        );
      }
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CountdownDialog(
          onFinished: () {
            Navigator.pop(context);
            _executeEmergencyAlert();
          },
        ),
      );
    }
  }

  Future<void> _executeEmergencyAlert() async {
    if (await Vibration.hasVibrator() == true) {
      Vibration.vibrate(duration: 500);
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // FIXED: Corrected string interpolation for latitude
      String mapLink =
          "https://maps.google.com/?q=${position.latitude},${position.longitude}";
      String messageRaw = "${AppStrings.emergencyAlertMessage}\n$mapLink";
      // String messageRaw = "Help Me!";

      setState(() {
        _lastSentMessage = messageRaw;
        _isEmergencyActive = true;
      });

      final contacts = ref.read(contactNotifierProvider).value ?? [];

      // --- NEW LOGIC: SMS STRATEGY ---
      if (Platform.isAndroid) {
        // Send directly in background for Android
        for (var contact in contacts) {
          var status = await BackgroundSms.sendMessage(
            phoneNumber: contact.phoneNumber,
            message: messageRaw,
          );
          print("SMS Status for ${contact.phoneNumber}: $status");
        }
      } else {
        // Use Intent for iOS
        final recipientNumbers = contacts.map((c) => c.phoneNumber).join(',');
        final encodedMessage = Uri.encodeComponent(messageRaw);
        final Uri smsUri =
            Uri.parse('sms:$recipientNumbers?body=$encodedMessage');

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }

      // --- THE DELAY ---
      // Wait 5 seconds to ensure message is processed before call starts
      await Future.delayed(const Duration(seconds: 5));

      final primaryContact = contacts.firstWhere(
        (c) => c.isPrimary,
        orElse: () => contacts.first,
      );

      await FlutterPhoneDirectCaller.callNumber(primaryContact.phoneNumber);

      if (mounted) _showAlertSentDialog();
    } catch (e) {
      debugPrint("Error in SOS: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.emergencyAlertFailedPrefix}$e')),
        );
      }
    }
  }

  Future<void> _executeSafeAlert() async {
    try {
      final contacts = ref.read(contactNotifierProvider).value ?? [];
      String messageRaw = AppStrings.safeNowSmsMessage;

      if (Platform.isAndroid) {
        for (var contact in contacts) {
          await BackgroundSms.sendMessage(
            phoneNumber: contact.phoneNumber,
            message: messageRaw,
          );
        }
      } else {
        final recipientNumbers = contacts.map((c) => c.phoneNumber).join(',');
        final encodedMessage = Uri.encodeComponent(messageRaw);
        final Uri smsUri =
            Uri.parse('sms:$recipientNumbers?body=$encodedMessage');

        if (await canLaunchUrl(smsUri)) {
          await launchUrl(smsUri);
        }
      }

      setState(() {
        _isEmergencyActive = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              backgroundColor: Colors.green,
              content: Text(AppStrings.safeAlertSentMessage)),
        );
      }
    } catch (e) {
      debugPrint("Error sending safe alert: $e");
    }
  }

  void _showAlertSentDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red),
            const SizedBox(width: 10),
            Text(AppStrings.emergencySentTitle,
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.emergencyMessageSentToContacts,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
            Text(AppStrings.callingPrimaryContactMessage,
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppStrings.okButton)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(contactNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          _buildCurvedHeader(context),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                _buildWelcomeStatusCard(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 20.0),
                  child: Column(
                    children: [
                      if (_isEmergencyActive)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _executeSafeAlert,
                              icon: const Icon(Icons.check_circle,
                                  color: Colors.white),
                              label: Text(AppStrings.imSafeNowButton,
                                  style: const TextStyle(
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _startEmergencySequence,
                          icon:
                              const Icon(Icons.emergency, color: Colors.white),
                          label: Text(AppStrings.sosTitle,
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
                  child: Text(
                    AppStrings.yourHealthHubTitle,
                    style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: _baseBrown),
                  ),
                ),
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

                      if (item['title'] == AppStrings.medicineRemindersTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ReminderListPage()));
                      } else if (item['title'] == AppStrings.sosSettingsTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const EmergencySettingsScreen()));
                      } else if (item['title'] == AppStrings.fitnessTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FitnessScreen()));
                      } else if (item['title'] == AppStrings.healthTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HealthTrackingScreen()));
                      } else if (item['title'] == AppStrings.waterTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WaterReminderScreen()));
                      } else if (item['title'] == AppStrings.brainGamesTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const BrainGamesDashboard()));
                      } else if (item['title'] == AppStrings.chatbotTitle) {
                        final currentUser = ref.read(authNotifierProvider);
                        final userId = currentUser?.uid ?? "guest_user";

                        onTapAction = () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => provider.ChangeNotifierProvider(
                                  // Use the prefix here
                                  create: (_) =>
                                      ChatProvider(currentUserId: userId),
                                  child: ChatbotScreen(),
                                ),
                              ),
                            );
                      } else if (item['title'] ==
                          AppStrings.nearbyServicesTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NearbyServicesHubScreen()));
                      } else if (item['title'] ==
                          AppStrings.friendNetworkTitle) {
                        onTapAction = () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const FriendNetworkHubScreen()));
                      } else {
                        onTapAction = () {};
                      }

                      final isFriendNetworkTile =
                          item['title'] == AppStrings.friendNetworkTitle;

                      return _buildFeatureCard(
                        item['title'],
                        item['subtitle'],
                        item['icon'],
                        item['color'],
                        item['iconColor'],
                        onTapAction,
                        badgeCount: isFriendNetworkTile
                            ? watchTotalNotificationCount(ref)
                            : 0,
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

  Widget _buildCurvedHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 170.0,
      pinned: true,
      elevation: 10,
      shadowColor: _baseBrown,
      // TEMPORARY — testing the language mechanism for Step 1. Will be
      // removed once the real Language setting is added to the Profile
      // screen in Step 3.
      actions: [
        IconButton(
          icon: const Icon(Icons.translate_rounded, color: Colors.white),
          tooltip: 'TEMP: toggle EN/TR',
          onPressed: () {
            final next = AppLanguageController.isTurkish
                ? AppLanguage.english
                : AppLanguage.turkish;
            AppLanguageController.setLanguage(next);
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 35.0, bottom: 16.0),
        title: Text(
          AppStrings.appBrandName,
          style: const TextStyle(
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
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              const Text('👋', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppStrings.homeWelcomeBack,
                        style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: _baseBrown)),
                    const SizedBox(height: 4),
                    Text(AppStrings.homeWelcomeSubtitle,
                        style: TextStyle(color: _baseBrown, fontSize: 16)),
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
      Color bgColor, Color iconColor, VoidCallback onTap,
      {int badgeCount = 0}) {
    final card = Card(
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
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (badgeCount <= 0) return card;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: -6,
          right: -6,
          child: Container(
            padding: const EdgeInsets.all(5),
            constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
            decoration: BoxDecoration(
              color: const Color(0xFFE53935),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                badgeCount > 9 ? '9+' : '$badgeCount',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
      title: Text(AppStrings.sosAlertHeaderText,
          style:
              const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${AppStrings.sendingAlertInPrefix}$_seconds',
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.red)),
          const SizedBox(height: 10),
          Text(AppStrings.alertingContactsMessage, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            _timer?.cancel();
            Navigator.pop(context);
          },
          child: Text(AppStrings.cancelAlertButton,
              style: const TextStyle(color: Colors.grey, fontSize: 16)),
        )
      ],
    );
  }
}
