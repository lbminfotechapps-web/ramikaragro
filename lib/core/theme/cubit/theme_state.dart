import 'package:equatable/equatable.dart';

import '../app_theme_palette.dart';
import '../app_theme_colors.dart';

class ThemeState extends Equatable {
  final AppThemePalette selectedTheme;

  const ThemeState({
    required this.selectedTheme,
  });

  factory ThemeState.initial() {
    return const ThemeState(
      selectedTheme: AppThemeColors.defaultTheme,
    );
  }

  ThemeState copyWith({
    AppThemePalette? selectedTheme,
  }) {
    return ThemeState(
      selectedTheme: selectedTheme ?? this.selectedTheme,
    );
  }

  @override
  List<Object?> get props => [
        selectedTheme.id,
      ];
}