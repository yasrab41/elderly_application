import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/features/authentication/screens/login.dart';

// Import sub-screens (Assumed paths - put these in the same folder or organize as you prefer)
import 'edit_profile_screen.dart';
import 'account_screen.dart';
import 'notifications_screen.dart';
import 'instructions_screen.dart';
import 'about_app_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final User? user = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final username = user.displayName ?? 'Valued Member';
    final email = user.email ?? 'No email available';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // ================= USER HEADER =================
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 🚀 Professional Static Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    // backgroundImage line is removed because we are not using Firebase Storage
                    child: Icon(
                      Icons
                          .person_rounded, // Using rounded version for a softer, modern look
                      size: 50,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    username,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // ================= MENU OPTIONS =================

            // 1. Edit Profile (Personal Info)
            _ProfileTile(
              icon: Icons.edit_outlined,
              title: 'Edit Profile',
              subtitle: 'Update name & details',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen())),
            ),

            // 2. Account (Security & Settings)
            _ProfileTile(
              icon: Icons.manage_accounts_outlined,
              title: 'Account Settings',
              subtitle: 'Email, Password, Delete Account',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AccountScreen())),
            ),

            // 3. Notifications (Placeholder)
            _ProfileTile(
              icon: Icons.notifications_active_outlined,
              title: 'Notifications',
              subtitle: 'Reminders & Alerts',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const NotificationsScreen())),
            ),

            const SizedBox(height: 25),

            // 4. Instructions / Help
            _ProfileTile(
              icon: Icons.help_outline,
              title: 'How to Use App',
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const InstructionsScreen())),
            ),

            // 5. About App
            _ProfileTile(
              icon: Icons.info_outline,
              title: 'About App',
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AboutAppScreen())),
            ),

            const SizedBox(height: 30),

            // ================= SIGN OUT =================
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final authService = ref.read(authServiceProvider);
                  await authService.signOut();
                  if (!context.mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const Login()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[50],
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign Out',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper Widget for consistent list tiles
class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _ProfileTile(
      {required this.icon,
      required this.title,
      this.subtitle,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle),
          child: Icon(icon, color: Theme.of(context).primaryColor),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        subtitle: subtitle != null
            ? Text(subtitle!, style: TextStyle(color: Colors.grey[600]))
            : null,
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
