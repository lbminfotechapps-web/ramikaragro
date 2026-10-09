
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_theme_colors.dart';
import '../app_theme_palette.dart';
import '../data/theme_local_storage.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  final ThemeLocalStorage _storage;

  Future<void> _pendingSave = Future<void>.value();

  ThemeCubit({
    required ThemeLocalStorage storage,
    required AppThemePalette initialTheme,
  })  : _storage = storage,
        super(ThemeState(selectedTheme: initialTheme));

  // ==========================================================
  // GET CURRENT SELECTED THEME
  // ==========================================================

  AppThemePalette get currentTheme => state.selectedTheme;

  // ==========================================================
  // CHANGE THEME AND SAVE
  // ==========================================================

  Future<void> changeTheme(AppThemePalette theme) {
    final selectedTheme = AppThemeColors.fromId(theme.id);

    if (state.selectedTheme.id == selectedTheme.id) {
      return Future<void>.value();
    }

    // Update UI immediately.
    emit(state.copyWith(selectedTheme: selectedTheme));

    // Serialize writes so rapid selections cannot overwrite
    // a newer preference with an older one.
    _pendingSave = _pendingSave
        .catchError((Object error) {
          // Allow a later save to proceed after a failed write.
        })
        .then((_) => _storage.saveTheme(selectedTheme.id));

    return _pendingSave;
  }

  // ==========================================================
  // CHANGE THEME BY ID
  // ==========================================================

  Future<void> changeThemeById(String themeId) {
    return changeTheme(AppThemeColors.fromId(themeId));
  }

  // ==========================================================
  // RESET TO DEFAULT THEME
  // ==========================================================

  Future<void> resetTheme() {
    return changeTheme(AppThemeColors.defaultTheme);
  }

  // ==========================================================
  // CHECK SELECTED THEME
  // ==========================================================

  bool isSelected(String themeId) {
    return state.selectedTheme.id == themeId;
  }
}
