import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';

/// Single source of truth for the app's current language.
///
/// This is deliberately a plain static holder, not a Riverpod provider —
/// AppStrings getters need to read the current language from dozens of
/// places that have no BuildContext or WidgetRef at all (repositories,
/// notifiers, plain Dart helper functions). `current` is instantly
/// readable from any of those. `notifier` is what the UI layer listens to
/// in order to know when to rebuild after a change.
class AppLanguageController {
  AppLanguageController._();

  static const String _prefsKey = 'app_language';

  static AppLanguage current = AppLanguage.english;

  static final ValueNotifier<AppLanguage> notifier =
      ValueNotifier(AppLanguage.english);

  static bool _initialized = false;

  /// Call once, before runApp. Resolves the starting language from a
  /// previously saved user choice, or — if the user has never chosen one —
  /// from the device's system language.
  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    AppLanguage resolved = AppLanguage.english;
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);

      if (saved == 'tr') {
        resolved = AppLanguage.turkish;
      } else if (saved == 'en') {
        resolved = AppLanguage.english;
      } else {
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        resolved = deviceLocale.languageCode.toLowerCase() == 'tr'
            ? AppLanguage.turkish
            : AppLanguage.english;
      }
    } catch (e) {
      debugPrint('[AppLanguageController] initialize FAILED, defaulting to '
          'English: $e');
      resolved = AppLanguage.english;
    }

    current = resolved;
    notifier.value = resolved;
  }

  static Future<void> setLanguage(AppLanguage language) async {
    current = language;
    notifier.value = language;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _prefsKey, language == AppLanguage.turkish ? 'tr' : 'en');
    } catch (e) {
      debugPrint('[AppLanguageController] Failed to persist language: $e');
      // Non-fatal: the in-memory language still changed for this session,
      // it just won't be remembered next launch.
    }
  }

  static bool get isTurkish => current == AppLanguage.turkish;
}
