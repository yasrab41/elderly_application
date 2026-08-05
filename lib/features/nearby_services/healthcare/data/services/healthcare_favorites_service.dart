import 'package:shared_preferences/shared_preferences.dart';

class HealthcareFavoritesService {
  static const String _prefsKey = 'favorite_healthcare_ids';

  Future<Set<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_prefsKey) ?? []).toSet();
  }

  Future<void> saveFavoriteIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, ids.toList());
  }
}
