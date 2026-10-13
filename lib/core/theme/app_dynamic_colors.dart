import 'package:flutter/material.dart';

import 'app_theme_context.dart';

extension AppDynamicColors on BuildContext {
  // Main colors
  Color get appPrimary => appColors.primary;
  Color get appOnPrimary => appColors.onPrimary;
  Color get appSecondary => appColors.secondary;

  // Background
  Color get appBackground => Theme.of(this).brightness == Brightness.dark
      ? Colors.black
      : Colors.white;
  Color get appSurface => appColors.surface;

  // Cards
  Color get appCard => cardBackgroundColor;
  Color get appOnCard => cardTextColor;

  // Text
  Color get appText => appColors.onSurface;
  Color get appSubText => secondaryTextColor;

  // Border
  Color get appBorder => borderColor;

  // Input
  Color get appInputBackground => appTheme.inputBackground;

  // Gradients
  LinearGradient get appBackgroundGradient => appGradient;

  // Status colors
  Color get appError => appColors.error;
  Color get appSuccess => appThemeData.brightness == Brightness.dark
      ? const Color(0xFF64C850)
      : const Color(0xFF388E3C);

  Color get appWarning => appThemeData.brightness == Brightness.dark
      ? const Color(0xFFFFB74D)
      : const Color(0xFFF57C00);

  // Surface / background foreground colors
  Color get appOnSurface => appColors.onSurface;

  // Card-specific text
  Color get appCardText => appTheme.onCard;

  // Primary button text
  Color get appButtonText => appColors.onPrimary;

  // Text field text
  Color get appInputText => Theme.of(this).brightness == Brightness.dark
      ? const Color(0xFFF5F6F8)
      : const Color(0xFF1F2937);

  // Check dark theme
  bool get isDarkTheme => Theme.of(this).brightness == Brightness.dark;
}
