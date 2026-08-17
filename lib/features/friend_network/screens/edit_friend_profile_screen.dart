import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/providers/avatar_provider.dart';
import 'package:elderly_prototype_app/core/widgets/avatar_picker.dart';
import '../data/models/friend_profile_model.dart';
import '../providers/friend_profile_provider.dart';

class EditFriendProfileScreen extends ConsumerStatefulWidget {
  const EditFriendProfileScreen({super.key});

  @override
  ConsumerState<EditFriendProfileScreen> createState() =>
      _EditFriendProfileScreenState();
}

class _EditFriendProfileScreenState
    extends ConsumerState<EditFriendProfileScreen> {
  late TextEditingController _bioController;
  AgeRangeOption? _ageRange;
  String? _gender;
  late Set<String> _interests;
  late Set<String> _languages;
  late bool _discoverable;
  bool _initialized = false;

  // Not const anymore: these reference AppStrings getters that resolve
  // based on the current language, not fixed compile-time values.
  List<String> get _interestOptions => [
        AppStrings.interestWalking,
        AppStrings.interestGardening,
        AppStrings.interestReading,
        AppStrings.interestCooking,
        AppStrings.interestPainting,
        AppStrings.interestCrochet,
        AppStrings.interestMusic,
        AppStrings.interestExercise,
        AppStrings.interestChess,
        AppStrings.interestVolunteering,
      ];

  List<String> get _languageOptions => [
        AppStrings.languageTurkish,
        AppStrings.languageEnglish,
        AppStrings.languageOther,
      ];

  void _loadFromProfile(FriendProfileModel profile) {
    _bioController = TextEditingController(text: profile.bio);
    _ageRange = profile.ageRange;
    _gender = profile.gender;
    _interests = profile.interests.toSet();
    _languages = profile.languages.toSet();
    _discoverable = profile.discoverable;
    _initialized = true;
  }

  @override
  void dispose() {
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final draft = FriendProfileModel(
      bio: _bioController.text.trim(),
      ageRange: _ageRange,
      gender: _gender,
      interests: _interests.toList(),
      languages: _languages.toList(),
      discoverable: _discoverable,
    );

    final avatarId = ref.read(avatarProvider);
    final success = await ref
        .read(friendProfileProvider.notifier)
        .saveProfile(draft, avatarId: avatarId);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.profileSavedMessage)),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.profileSaveErrorMessage)),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Deferred via addPostFrameCallback deliberately - see
    // friend_network_hub_screen.dart for why calling this directly in
    // initState caused a rebuild-loop regression.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(avatarProvider.notifier).loadIfNeeded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(friendProfileProvider);
    final avatarId = ref.watch(avatarProvider);

    if (!_initialized && !state.isLoading) {
      _loadFromProfile(state.profile);
    }

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.editProfileFriendNetworkButton)),
      body: (state.isLoading || !_initialized)
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildAvatarPicker(avatarId),
                const SizedBox(height: 28),
                _buildSectionLabel(AppStrings.bioLabel),
                const SizedBox(height: 10),
                TextField(
                  controller: _bioController,
                  maxLength: 150,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 17),
                  decoration: InputDecoration(
                    hintText: AppStrings.bioHint,
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(AppStrings.ageRangeLabel),
                const SizedBox(height: 10),
                _buildChoiceRow(
                  options: AgeRangeOption.values.map((e) => e.label).toList(),
                  selected: _ageRange?.label,
                  onSelected: (label) {
                    setState(() {
                      _ageRange = AgeRangeOption.values
                          .firstWhere((e) => e.label == label);
                    });
                  },
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(AppStrings.genderLabel),
                const SizedBox(height: 10),
                _buildChoiceRow(
                  options: [
                    AppStrings.genderMale,
                    AppStrings.genderFemale,
                    AppStrings.genderPreferNotToSay,
                  ],
                  selected: _gender,
                  onSelected: (label) => setState(() => _gender = label),
                  allowDeselect: true,
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(AppStrings.interestsLabel,
                    hint: AppStrings.interestsHint),
                const SizedBox(height: 10),
                _buildMultiChoiceWrap(
                  options: _interestOptions,
                  selected: _interests,
                  onToggle: (label) => setState(() {
                    _interests.contains(label)
                        ? _interests.remove(label)
                        : _interests.add(label);
                  }),
                ),
                const SizedBox(height: 20),
                _buildSectionLabel(AppStrings.languagesLabel),
                const SizedBox(height: 10),
                _buildMultiChoiceWrap(
                  options: _languageOptions,
                  selected: _languages,
                  onToggle: (label) => setState(() {
                    _languages.contains(label)
                        ? _languages.remove(label)
                        : _languages.add(label);
                  }),
                ),
                const SizedBox(height: 28),
                _buildDiscoverableToggle(),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF48352A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: state.isSaving
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Text(AppStrings.saveProfileButton,
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionLabel(String label, {String? hint}) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.black87)),
        if (hint != null) ...[
          const SizedBox(width: 8),
          Text(hint,
              style: const TextStyle(fontSize: 13, color: Colors.black45)),
        ],
      ],
    );
  }

  Widget _buildAvatarPicker(int avatarId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel(AppStrings.chooseAvatarLabel),
        const SizedBox(height: 14),
        AvatarPicker(
          selectedId: avatarId,
          onSelected: (id) => ref.read(avatarProvider.notifier).setAvatar(id),
        ),
      ],
    );
  }

  Widget _buildChoiceRow({
    required List<String> options,
    required String? selected,
    required ValueChanged<String> onSelected,
    bool allowDeselect = false,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((label) {
        final isSelected = selected == label;
        return ChoiceChip(
          label: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          onSelected: (_) =>
              onSelected((isSelected && allowDeselect) ? '' : label),
          selectedColor: const Color(0xFF48352A),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiChoiceWrap({
    required List<String> options,
    required Set<String> selected,
    required ValueChanged<String> onToggle,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((label) {
        final isSelected = selected.contains(label);
        return FilterChip(
          label: Text(label,
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.black87)),
          selected: isSelected,
          onSelected: (_) => onToggle(label),
          selectedColor: const Color(0xFF8D6E63),
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
                color: isSelected ? Colors.transparent : Colors.grey.shade300),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDiscoverableToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.discoverableLabel,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold),
                ),
              ),
              Switch(
                value: _discoverable,
                activeColor: const Color(0xFF43A047),
                onChanged: (value) => setState(() => _discoverable = value),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            AppStrings.discoverableDescription,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
