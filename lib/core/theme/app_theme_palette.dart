import 'package:flutter/material.dart';

@immutable
class AppThemePalette {
  final String id;
  final String name;

  final Color primary;
  final Color onPrimary;

  final Color secondary;
  final Color onSecondary;

  final Color background;
  final Color onBackground;

  final Color surface;
  final Color onSurface;

  final Color appBarBackground;
  final Color appBarForeground;

  final Color cardBackground;
  final Color onCard;

  final Color textPrimary;
  final Color textSecondary;

  final Color border;
  final Color inputBackground;

  final Color gradientStart;
  final Color gradientEnd;

  const AppThemePalette({
    required this.id,
    required this.name,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.background,
    required this.onBackground,
    required this.surface,
    required this.onSurface,
    required this.appBarBackground,
    required this.appBarForeground,
    required this.cardBackground,
    required this.onCard,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.inputBackground,
    required this.gradientStart,
    required this.gradientEnd,
  });

  LinearGradient get gradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [gradientStart, gradientEnd],
      );

  BoxDecoration get gradientDecoration => BoxDecoration(
        gradient: gradient,
      );
}