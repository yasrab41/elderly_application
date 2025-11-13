import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Note: We are using firebase_auth's User, so no custom model import is needed.
import 'package:firebase_auth/firebase_auth.dart';

// Placeholder for instructions screen (assuming it exists)
class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('App Instructions')),
      body: Center(
          child: Text('Detailed instructions for app use.',
              style: theme.textTheme.titleLarge)),
    );
  }
}

// Placeholder helper function for InstructionsScreen
Widget _buildInstructionSection(BuildContext context,
    {required IconData icon,
    required String title,
    required List<String> steps}) {
  final theme = Theme.of(context);
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: theme.colorScheme.secondary, size: 28),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.secondary,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ...steps
          .map((step) => Padding(
                padding: const EdgeInsets.only(left: 36.0, top: 4),
                child: Text('• $step', style: theme.textTheme.bodyLarge),
              ))
          .toList(),
    ],
  );
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authState is now of type User? (nullable Firebase User)
    final User? user = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    // --- FIX: Explicit Null Check ---
    if (user == null) {
      // If the user object is null, it means we are either logged out or still initializing.
      // In a real app, you might show a dedicated Sign In/Loading screen here.
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // --- End Fix ---

    // Now 'user' is guaranteed non-null (User) inside this block
    final username = user.displayName ?? 'Elderly User';
    final email = user.email ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: theme.colorScheme.primary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // --- User Profile Header Card ---
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  children: <Widget>[
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          theme.colorScheme.secondary.withOpacity(0.1),
                      child: Icon(Icons.person,
                          size: 35, color: theme.colorScheme.secondary),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          username,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- General Settings Section ---
            Text(
              'App Management',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            const Divider(height: 10, thickness: 1),

            // Instructions Tile
            ListTile(
              leading:
                  Icon(Icons.help_outline, color: theme.colorScheme.primary),
              title: const Text('How to Use the App (Instructions)'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const InstructionsScreen()),
                );
              },
            ),

            // Theme/Appearance Tile
            ListTile(
              leading: Icon(Icons.color_lens_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Appearance & Theme'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Handle theme change logic
              },
            ),

            // Reminder Settings Tile
            ListTile(
              leading: Icon(Icons.notifications_active_outlined,
                  color: theme.colorScheme.primary),
              title: const Text('Reminder & Notification Settings'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Navigate to detailed notification settings
              },
            ),

            const SizedBox(height: 24),

            // --- Account Section ---
            Text(
              'Account',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            const Divider(height: 10, thickness: 1),

            // Sign Out Tile
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out'),
              onTap: () {
                ref.read(authNotifierProvider.notifier).signOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
