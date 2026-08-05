import 'package:shared_preferences/shared_preferences.dart';

/// Stores the user's favorited/pinned bus stops on-device, so their usual
/// stop(s) always stay at the top of the list.
class BusStopFavoritesService {
  static const String _prefsKey = 'favorite_bus_stop_ids';

  Future<Set<int>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_prefsKey) ?? [];
    return stored.map((e) => int.tryParse(e)).whereType<int>().toSet();
  }

  Future<void> saveFavoriteIds(Set<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      ids.map((e) => e.toString()).toList(),
    );
  }
}
