import 'package:flutter/material.dart';

/// 8 simple, distinct avatar options (icon + color) — no photo upload,
/// no external image assets, nothing to moderate. Used app-wide (Profile
/// screen, Friend Network) so a user's avatar is always the same everywhere.
class AvatarOption {
  final IconData icon;
  final Color color;
  const AvatarOption(this.icon, this.color);
}

const List<AvatarOption> avatarOptions = [
  AvatarOption(Icons.face_rounded, Color(0xFF1E88E5)),
  AvatarOption(Icons.face_3_rounded, Color(0xFFE53935)),
  AvatarOption(Icons.face_4_rounded, Color(0xFF43A047)),
  AvatarOption(Icons.face_6_rounded, Color(0xFFFB8C00)),
  AvatarOption(Icons.person_rounded, Color(0xFF8E24AA)),
  AvatarOption(Icons.person_2_rounded, Color(0xFF00897B)),
  AvatarOption(Icons.person_3_rounded, Color(0xFF6D4C41)),
  AvatarOption(Icons.person_4_rounded, Color(0xFFC2185B)),
];
