import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/features/authentication/services/auth_service.dart';
import 'package:elderly_prototype_app/core/providers/avatar_provider.dart';
import 'package:elderly_prototype_app/core/widgets/avatar_picker.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the field with the current name from our AuthProvider
    final user = ref.read(authNotifierProvider);
    if (user != null) {
      _nameController.text = user.displayName ?? '';
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(avatarProvider.notifier).loadIfNeeded();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Logic to Save Name Only ---
  Future<void> _updateProfileName() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterNameValidation)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Update the display name in Firebase Auth
        await user.updateDisplayName(_nameController.text.trim());

        if (!mounted) return;

        Navigator.pop(context); // Return to Profile Screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppStrings.nameUpdatedMessage)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${AppStrings.errorSavingNamePrefix}${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.editProfileTileTitle),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.changeYourNameTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5D4037),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.nameAppearanceNote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Avatar Picker
                Text(
                  AppStrings.avatarLabel,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.avatarUsageNote,
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 14),
                AvatarPicker(
                  selectedId: ref.watch(avatarProvider),
                  onSelected: (id) =>
                      ref.read(avatarProvider.notifier).setAvatar(id),
                ),
                const SizedBox(height: 30),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.fullNameLabel,
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProfileName,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppStrings.saveChangesButton,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),

        // --- Elderly-Friendly Loading Overlay ---
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        AppStrings.savingNameMessage,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(AppStrings.pleaseWaitMessage),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
