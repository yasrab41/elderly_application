import 'package:elderly_prototype_app/core/constants.dart';
import 'package:elderly_prototype_app/core/models/avatar_options.dart';

// Re-exported so existing files that import avatarOptions/AvatarOption from
// this file (screens, widgets) keep working unchanged — the avatar system
// now lives in core/ since it's shared with the main Profile screen too.
export 'package:elderly_prototype_app/core/models/avatar_options.dart';

enum AgeRangeOption { fifties, sixties, seventies, eighties, ninetyPlus }

extension AgeRangeOptionLabel on AgeRangeOption {
  String get label {
    switch (this) {
      case AgeRangeOption.fifties:
        return AppStrings.ageRange50s;
      case AgeRangeOption.sixties:
        return AppStrings.ageRange60s;
      case AgeRangeOption.seventies:
        return AppStrings.ageRange70s;
      case AgeRangeOption.eighties:
        return AppStrings.ageRange80s;
      case AgeRangeOption.ninetyPlus:
        return AppStrings.ageRange90Plus;
    }
  }
}

class FriendProfileModel {
  final String bio;
  final AgeRangeOption? ageRange;
  final String? gender;
  final List<String> interests;
  final List<String> languages;
  final bool discoverable;
  final double? approxLatitude;
  final double? approxLongitude;
  final String? district;

  const FriendProfileModel({
    this.bio = '',
    this.ageRange,
    this.gender,
    this.interests = const [],
    this.languages = const [],
    this.discoverable = false,
    this.approxLatitude,
    this.approxLongitude,
    this.district,
  });

  bool get hasBeenSetUp => bio.isNotEmpty || interests.isNotEmpty;

  FriendProfileModel copyWith({
    String? bio,
    AgeRangeOption? ageRange,
    String? gender,
    List<String>? interests,
    List<String>? languages,
    bool? discoverable,
    double? approxLatitude,
    double? approxLongitude,
    String? district,
  }) {
    return FriendProfileModel(
      bio: bio ?? this.bio,
      ageRange: ageRange ?? this.ageRange,
      gender: gender ?? this.gender,
      interests: interests ?? this.interests,
      languages: languages ?? this.languages,
      discoverable: discoverable ?? this.discoverable,
      approxLatitude: approxLatitude ?? this.approxLatitude,
      approxLongitude: approxLongitude ?? this.approxLongitude,
      district: district ?? this.district,
    );
  }

  factory FriendProfileModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const FriendProfileModel();
    return FriendProfileModel(
      bio: map['bio'] as String? ?? '',
      ageRange: map['ageRange'] != null
          ? AgeRangeOption.values.firstWhere(
              (e) => e.name == map['ageRange'],
              orElse: () => AgeRangeOption.sixties,
            )
          : null,
      gender: map['gender'] as String?,
      interests: (map['interests'] as List?)?.cast<String>() ?? [],
      languages: (map['languages'] as List?)?.cast<String>() ?? [],
      discoverable: map['discoverable'] as bool? ?? false,
      approxLatitude: (map['approxLatitude'] as num?)?.toDouble(),
      approxLongitude: (map['approxLongitude'] as num?)?.toDouble(),
      district: map['district'] as String?,
    );
  }

  /// Fields written to the private users/{uid} doc.
  Map<String, dynamic> toUserDocMap() {
    return {
      'friendProfile': {
        'bio': bio,
        'ageRange': ageRange?.name,
        'gender': gender,
        'interests': interests,
        'languages': languages,
        'discoverable': discoverable,
        'approxLatitude': approxLatitude,
        'approxLongitude': approxLongitude,
        'district': district,
      },
    };
  }

  /// The safe-to-share subset written to publicProfiles/{uid}. Deliberately
  /// excludes anything not needed for discovery — no email, no exact
  /// location, nothing beyond what a nearby-people card needs to show.
  Map<String, dynamic> toPublicProfileMap({
    required String name,
    required int avatarId,
  }) {
    return {
      'name': name,
      'avatarId': avatarId,
      'bio': bio,
      'ageRange': ageRange?.name,
      'interests': interests,
      'languages': languages,
      'approxLatitude': approxLatitude,
      'approxLongitude': approxLongitude,
      'district': district,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
