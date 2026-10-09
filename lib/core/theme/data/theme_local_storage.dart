
import 'package:shared_preferences/shared_preferences.dart';

class ThemeLocalStorage {
  static const String _themeKey = 'selected_app_theme_id';

  final SharedPreferencesAsync _preferences;

  ThemeLocalStorage(this._preferences);

  // ==========================================================
  // SAVE SELECTED THEME
  // ==========================================================

  Future<void> saveTheme(String themeId) async {
    await _preferences.setString(_themeKey, themeId);
  }

  // ==========================================================
  // GET SAVED THEME ID
  // ==========================================================

  Future<String?> getSavedThemeId() async {
    return _preferences.getString(_themeKey);
  }

  // ==========================================================
  // REMOVE SAVED THEME
  // ==========================================================

  Future<void> clearSavedTheme() async {
    await _preferences.remove(_themeKey);
  }
}
