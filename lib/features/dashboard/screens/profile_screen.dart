import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';

// Import Login screen for navigation
import 'package:elderly_prototype_app/features/authentication/screens/login.dart';

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

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. FIX: Watch 'authNotifierProvider' instead of 'authStateChangesProvider'
    // This returns 'User?' directly, not an AsyncValue.
    final User? user = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    // 2. Logic to handle if user is null (not logged in)
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    final username = user.displayName ?? 'Elderly User';
    final email = user.email ?? 'No email available';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            username,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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

            // --- Sign Out Tile ---
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                // 1. Perform the Sign Out using your authServiceProvider
                final authService = ref.read(authServiceProvider);
                await authService.signOut();

                // 2. Check if the widget is still in the tree
                if (!context.mounted) return;

                // 3. Navigate back to Login and clear the stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Login()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
