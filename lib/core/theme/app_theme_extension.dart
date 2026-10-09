

import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_palette.dart';

@immutable
class AppThemeExtension extends ThemeExtension<AppThemeExtension> {
  final Color textSecondary;
  final Color cardBackground;
  final Color onCard;
  final Color inputBackground;
  final Color borderColor;
  final Color gradientStart;
  final Color gradientEnd;

  const AppThemeExtension({
    required this.textSecondary,
    required this.cardBackground,
    required this.onCard,
    required this.inputBackground,
    required this.borderColor,
    required this.gradientStart,
    required this.gradientEnd,
  });

  factory AppThemeExtension.fromPalette(AppThemePalette palette) {
    return AppThemeExtension(
      textSecondary: palette.textSecondary,
      cardBackground: palette.cardBackground,
      onCard: palette.onCard,
      inputBackground: palette.inputBackground,
      borderColor: palette.border,
      gradientStart: palette.gradientStart,
      gradientEnd: palette.gradientEnd,
    );
  }

  LinearGradient get appGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );

  BoxDecoration get appGradientDecoration => BoxDecoration(
        gradient: appGradient,
      );

  @override
  AppThemeExtension copyWith({
    Color? textSecondary,
    Color? cardBackground,
    Color? onCard,
    Color? inputBackground,
    Color? borderColor,
    Color? gradientStart,
    Color? gradientEnd,
  }) {
    return AppThemeExtension(
      textSecondary: textSecondary ?? this.textSecondary,
      cardBackground: cardBackground ?? this.cardBackground,
      onCard: onCard ?? this.onCard,
      inputBackground: inputBackground ?? this.inputBackground,
      borderColor: borderColor ?? this.borderColor,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
    );
  }

  @override
  AppThemeExtension lerp(
    covariant AppThemeExtension? other,
    double t,
  ) {
    if (other == null) return this;

    return AppThemeExtension(
      textSecondary:
          Color.lerp(textSecondary, other.textSecondary, t)!,
      cardBackground:
          Color.lerp(cardBackground, other.cardBackground, t)!,
      onCard: Color.lerp(onCard, other.onCard, t)!,
      inputBackground:
          Color.lerp(inputBackground, other.inputBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
      gradientStart:
          Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd:
          Color.lerp(gradientEnd, other.gradientEnd, t)!,
    );
  }
}