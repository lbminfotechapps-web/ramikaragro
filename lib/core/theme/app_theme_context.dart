import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_extension.dart';

extension AppThemeContext on BuildContext {
  ThemeData get appThemeData => Theme.of(this);

  ColorScheme get appColors => Theme.of(this).colorScheme;

  AppThemeExtension get appTheme {
    return Theme.of(this).extension<AppThemeExtension>()!;
  }

  // Main theme colors
  Color get primaryColor => appColors.primary;
  Color get onPrimaryColor => appColors.onPrimary;

  // Text
  Color get primaryTextColor => appColors.onSurface;
  Color get secondaryTextColor => appTheme.textSecondary;

  // Background / card
  Color get backgroundColor => Theme.of(this).scaffoldBackgroundColor;

  Color get cardBackgroundColor => appTheme.cardBackground;
  Color get cardTextColor => appTheme.onCard;

  // Border
  Color get borderColor => appTheme.borderColor;

  // Gradient
  LinearGradient get appGradient => appTheme.appGradient;

  BoxDecoration get appGradientDecoration => appTheme.appGradientDecoration;
}
