
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';


class AppTextStyles {
  AppTextStyles._();

  // ============================================================
  // FONT WEIGHTS
  // ============================================================

  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight semiBold = FontWeight.w600;
  static const FontWeight bold = FontWeight.w700;
  static const FontWeight extraBold = FontWeight.w800;

  // ============================================================
  // FONT SIZES
  // ============================================================

  static double get size10 => 10.sp;
  static double get size11 => 11.sp;
  static double get size12 => 12.sp;
  static double get size13 => 13.sp;
  static double get size14 => 14.sp;
  static double get size15 => 15.sp;
  static double get size16 => 16.sp;
  static double get size18 => 18.sp;
  static double get size20 => 20.sp;
  static double get size22 => 22.sp;
  static double get size24 => 24.sp;
  static double get size28 => 28.sp;
  static double get size32 => 32.sp;

  // ============================================================
  // DISPLAY STYLES
  // Large values, totals, statistics and dashboard numbers
  // ============================================================

  static TextStyle get displayLarge => TextStyle(
        fontSize: size32,
        fontWeight: bold,
        height: 1.15,
        letterSpacing: -0.5,
      );

  static TextStyle get displayMedium => TextStyle(
        fontSize: size28,
        fontWeight: bold,
        height: 1.20,
        letterSpacing: -0.4,
      );

  static TextStyle get displaySmall => TextStyle(
        fontSize: size24,
        fontWeight: bold,
        height: 1.20,
      );

  // ============================================================
  // PAGE TITLE
  // Main heading of a screen
  // ============================================================

  static TextStyle get pageTitle => TextStyle(
        fontSize: size22,
        fontWeight: bold,
        height: 1.25,
        letterSpacing: -0.3,
      );

  static TextStyle get pageSubtitle => TextStyle(
        fontSize: size13,
        fontWeight: regular,
        height: 1.4,
      );

  // ============================================================
  // HEADINGS
  // ============================================================

  static TextStyle get headingLarge => TextStyle(
        fontSize: size20,
        fontWeight: bold,
        height: 1.25,
      );

  static TextStyle get headingMedium => TextStyle(
        fontSize: size18,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get headingSmall => TextStyle(
        fontSize: size16,
        fontWeight: semiBold,
        height: 1.3,
      );

  // ============================================================
  // SECTION TITLES
  // ============================================================

  static TextStyle get sectionTitle => TextStyle(
        fontSize: size18,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get sectionSubtitle => TextStyle(
        fontSize: size12,
        fontWeight: regular,
        height: 1.4,
      );

  // ============================================================
  // CARD TYPOGRAPHY
  // ============================================================

  static TextStyle get cardTitle => TextStyle(
        fontSize: size16,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get cardSubtitle => TextStyle(
        fontSize: size13,
        fontWeight: regular,
        height: 1.4,
      );

  static TextStyle get cardValue => TextStyle(
        fontSize: size20,
        fontWeight: bold,
        height: 1.2,
      );

  static TextStyle get cardDescription => TextStyle(
        fontSize: size12,
        fontWeight: regular,
        height: 1.45,
      );

  // ============================================================
  // BODY TEXT
  // ============================================================

  static TextStyle get bodyLarge => TextStyle(
        fontSize: size16,
        fontWeight: regular,
        height: 1.5,
      );

  static TextStyle get body => TextStyle(
        fontSize: size14,
        fontWeight: regular,
        height: 1.45,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontSize: size14,
        fontWeight: medium,
        height: 1.45,
      );

  static TextStyle get bodySmall => TextStyle(
        fontSize: size12,
        fontWeight: regular,
        height: 1.45,
      );

  // ============================================================
  // LABELS
  // Form labels, dropdown labels and field titles
  // ============================================================

  static TextStyle get labelLarge => TextStyle(
        fontSize: size14,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get label => TextStyle(
        fontSize: size13,
        fontWeight: medium,
        height: 1.3,
      );

  static TextStyle get labelSmall => TextStyle(
        fontSize: size11,
        fontWeight: medium,
        height: 1.3,
      );

  // ============================================================
  // TEXT FIELDS
  // ============================================================

  static TextStyle get input => TextStyle(
        fontSize: size14,
        fontWeight: regular,
        height: 1.4,
      );

  static TextStyle get inputHint => TextStyle(
        fontSize: size14,
        fontWeight: regular,
        height: 1.4,
      );

  static TextStyle get inputLabel => TextStyle(
        fontSize: size14,
        fontWeight: medium,
        height: 1.3,
      );

  static TextStyle get inputError => TextStyle(
        fontSize: size12,
        fontWeight: regular,
        height: 1.3,
      );

  // ============================================================
  // BUTTONS
  // ============================================================

  static TextStyle get buttonLarge => TextStyle(
        fontSize: size16,
        fontWeight: semiBold,
        height: 1.2,
      );

  static TextStyle get button => TextStyle(
        fontSize: size14,
        fontWeight: semiBold,
        height: 1.2,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontSize: size12,
        fontWeight: semiBold,
        height: 1.2,
      );

  // ============================================================
  // NAVIGATION
  // ============================================================

  static TextStyle get navigationLabel => TextStyle(
        fontSize: size11,
        fontWeight: medium,
        height: 1.2,
      );

  static TextStyle get navigationLabelSelected => TextStyle(
        fontSize: size11,
        fontWeight: bold,
        height: 1.2,
      );

  // ============================================================
  // DIALOGS
  // ============================================================

  static TextStyle get dialogTitle => TextStyle(
        fontSize: size18,
        fontWeight: bold,
        height: 1.3,
      );

  static TextStyle get dialogBody => TextStyle(
        fontSize: size14,
        fontWeight: regular,
        height: 1.5,
      );

  // ============================================================
  // CAPTIONS AND HELPER TEXT
  // ============================================================

  static TextStyle get caption => TextStyle(
        fontSize: size11,
        fontWeight: regular,
        height: 1.35,
      );

  static TextStyle get helperText => TextStyle(
        fontSize: size10,
        fontWeight: regular,
        height: 1.4,
      );

  // ============================================================
  // BADGES AND CHIPS
  // ============================================================

  static TextStyle get badge => TextStyle(
        fontSize: size10,
        fontWeight: semiBold,
        height: 1.2,
      );

  static TextStyle get chip => TextStyle(
        fontSize: size12,
        fontWeight: medium,
        height: 1.2,
      );

  // ============================================================
  // LIST ITEMS
  // ============================================================

  static TextStyle get listTitle => TextStyle(
        fontSize: size14,
        fontWeight: semiBold,
        height: 1.3,
      );

  static TextStyle get listSubtitle => TextStyle(
        fontSize: size12,
        fontWeight: regular,
        height: 1.4,
      );

  // ============================================================
  // TABLES AND REPORTS
  // ============================================================

  static TextStyle get tableHeader => TextStyle(
        fontSize: size12,
        fontWeight: bold,
        height: 1.3,
      );

  static TextStyle get tableCell => TextStyle(
        fontSize: size12,
        fontWeight: regular,
        height: 1.4,
      );

  // ============================================================
  // APP BAR
  // ============================================================

  static TextStyle get appBarTitle => TextStyle(
        fontSize: size18,
        fontWeight: semiBold,
        height: 1.25,
      );

  static TextStyle get appBarSubtitle => TextStyle(
        fontSize: size11,
        fontWeight: regular,
        height: 1.3,
      );

  // ============================================================
  // OPTIONAL STYLE CUSTOMIZATION
  // ============================================================

  static TextStyle withColor(
    TextStyle style,
    Color color,
  ) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(
    TextStyle style,
    FontWeight weight,
  ) {
    return style.copyWith(fontWeight: weight);
  }
}
