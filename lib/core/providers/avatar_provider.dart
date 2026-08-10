import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/avatar_service.dart';

class AvatarNotifier extends StateNotifier<int> {
  AvatarNotifier() : super(0);

  final AvatarService _service = AvatarService();
  bool _loaded = false;

  /// Safe to call from every screen's initState — only fetches once.
  /// Never throws: if the fetch fails, we simply keep the default avatar
  /// (id 0) rather than letting the error block anything else that's
  /// loading alongside it.
  Future<void> loadIfNeeded() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final id = await _service.getAvatarId();
      state = id;
    } catch (e) {
      debugPrint('[AvatarNotifier] loadIfNeeded FAILED: $e');
      // Leave state at its default (0) — non-fatal, avatar just won't be
      // personalized until the next successful load.
    }
  }

  Future<void> setAvatar(int avatarId) async {
    state = avatarId;
    _loaded = true;
    try {
      await _service.setAvatarId(avatarId);
    } catch (e) {
      debugPrint('[AvatarNotifier] setAvatar FAILED: $e');
      // Local state already updated for a responsive UI; the Firestore
      // write can be retried next time the user changes their avatar.
    }
  }
}

final avatarProvider = StateNotifierProvider<AvatarNotifier, int>((ref) {
  return AvatarNotifier();
});
