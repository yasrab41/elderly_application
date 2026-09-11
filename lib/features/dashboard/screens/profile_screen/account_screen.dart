import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/authentication/screens/login.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  Future<void> _sendPasswordReset(BuildContext context, String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.resetLinkSentMessage(email))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.genericErrorPrefix}$e')));
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    // Show confirmation dialog
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(AppStrings.deleteAccountQuestionTitle),
            content: Text(AppStrings.deleteAccountWarningMessage),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(AppStrings.cancelButton)),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text(AppStrings.deleteLabel),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      try {
        await FirebaseAuth.instance.currentUser?.delete();
        if (!context.mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false,
        );
      } catch (e) {
        if (!context.mounted) return;
        // Re-authentication is often required for delete.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.deleteAccountSecurityMessage)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = user?.email ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.accountSettingsTileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(AppStrings.accountInfoSectionTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 10),
          ListTile(
            tileColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.email),
            title: Text(AppStrings.emailAddressLabel),
            subtitle: Text(email), // Read-only
          ),

          const SizedBox(height: 30),
          Text(AppStrings.securitySectionTitle,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey)),
          const SizedBox(height: 10),

          ListTile(
            tileColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.lock_reset, color: Colors.blue),
            title: Text(AppStrings.resetPasswordTileTitle),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => _sendPasswordReset(context, email),
          ),

          const SizedBox(height: 40),

          // Delete Account
          ListTile(
            tileColor: Colors.red[50],
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: Text(AppStrings.deleteAccountTileTitle,
                style: const TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
            onTap: () => _deleteAccount(context),
          ),
        ],
      ),
    );
  }
}
