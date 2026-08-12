import 'friend_profile_model.dart';

/// The safe-to-share subset of another user's profile, read from
/// publicProfiles/{uid}. Never contains exact location or private fields.
class PublicProfileModel {
  final String uid;
  final String name;
  final int avatarId;
  final String bio;
  final AgeRangeOption? ageRange;
  final List<String> interests;
  final List<String> languages;
  final double? approxLatitude;
  final double? approxLongitude;
  final String? district;

  const PublicProfileModel({
    required this.uid,
    required this.name,
    this.avatarId = 0,
    this.bio = '',
    this.ageRange,
    this.interests = const [],
    this.languages = const [],
    this.approxLatitude,
    this.approxLongitude,
    this.district,
  });

  factory PublicProfileModel.fromMap(String uid, Map<String, dynamic>? map) {
    return PublicProfileModel(
      uid: uid,
      name: map?['name'] as String? ?? 'HealthCare+ User',
      avatarId: (map?['avatarId'] as num?)?.toInt() ?? 0,
      bio: map?['bio'] as String? ?? '',
      ageRange: map?['ageRange'] != null
          ? AgeRangeOption.values.firstWhere(
              (e) => e.name == map!['ageRange'],
              orElse: () => AgeRangeOption.sixties,
            )
          : null,
      interests: (map?['interests'] as List?)?.cast<String>() ?? [],
      languages: (map?['languages'] as List?)?.cast<String>() ?? [],
      approxLatitude: (map?['approxLatitude'] as num?)?.toDouble(),
      approxLongitude: (map?['approxLongitude'] as num?)?.toDouble(),
      district: map?['district'] as String?,
    );
  }
}

class PublicProfileWithDistance {
  final PublicProfileModel profile;
  final double? distanceMeters;

  const PublicProfileWithDistance({
    required this.profile,
    this.distanceMeters,
  });
}

class FriendRequestModel {
  final String id;
  final String fromUid;
  final String toUid;
  final String fromName;
  final int fromAvatarId;
  final String status;
  final DateTime? createdAt;

  const FriendRequestModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.fromName,
    required this.fromAvatarId,
    required this.status,
    this.createdAt,
  });
}

class FriendshipModel {
  final String pairId;
  final String friendUid;
  final String friendName;
  final int friendAvatarId;
  final DateTime? since;
  final bool isTrustedContact;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final bool isUnreadMessage;

  const FriendshipModel({
    required this.pairId,
    required this.friendUid,
    required this.friendName,
    required this.friendAvatarId,
    this.since,
    this.isTrustedContact = false,
    this.lastMessageText,
    this.lastMessageAt,
    this.isUnreadMessage = false,
  });

  FriendshipModel copyWithMessagePreview({
    String? lastMessageText,
    DateTime? lastMessageAt,
    bool? isUnreadMessage,
  }) {
    return FriendshipModel(
      pairId: pairId,
      friendUid: friendUid,
      friendName: friendName,
      friendAvatarId: friendAvatarId,
      since: since,
      isTrustedContact: isTrustedContact,
      lastMessageText: lastMessageText ?? this.lastMessageText,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isUnreadMessage: isUnreadMessage ?? this.isUnreadMessage,
    );
  }
}
