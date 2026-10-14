
import 'package:flutter/material.dart';

import 'app_text_styles.dart';
import '../app_theme_context.dart';

/// Theme-aware text styles for the entire application.
///
/// Usage:
/// context.appTextStyles.pageTitle
/// context.appTextStyles.cardTitle
/// context.appTextStyles.body
///
/// Colors update automatically when ThemeCubit changes ThemeData.

extension AppTypographyExtension on BuildContext {
  AppTypography get appTextStyles => AppTypography(this);
}

class AppTypography {
  final BuildContext context;

  const AppTypography(this.context);

  // ============================================================
  // CURRENT THEME COLORS
  // ============================================================

  Color get _primaryText => context.appColors.onSurface;

  Color get _secondaryText => context.appTheme.textSecondary;

  Color get _cardText => context.appTheme.onCard;

  Color get _primary => context.appColors.primary;

  Color get _onPrimary => context.appColors.onPrimary;

  Color get _error => context.appColors.error;

  // ============================================================
  // DISPLAY STYLES
  // ============================================================

  TextStyle get displayLarge =>
      AppTextStyles.displayLarge.copyWith(color: _primaryText);

  TextStyle get displayMedium =>
      AppTextStyles.displayMedium.copyWith(color: _primaryText);

  TextStyle get displaySmall =>
      AppTextStyles.displaySmall.copyWith(color: _primaryText);

  // ============================================================
  // PAGE TITLES
  // ============================================================

  TextStyle get pageTitle =>
      AppTextStyles.pageTitle.copyWith(color: _primaryText);

  TextStyle get pageSubtitle =>
      AppTextStyles.pageSubtitle.copyWith(color: _secondaryText);

  // ============================================================
  // HEADINGS
  // ============================================================

  TextStyle get headingLarge =>
      AppTextStyles.headingLarge.copyWith(color: _primaryText);

  TextStyle get headingMedium =>
      AppTextStyles.headingMedium.copyWith(color: _primaryText);

  TextStyle get headingSmall =>
      AppTextStyles.headingSmall.copyWith(color: _primaryText);

  // ============================================================
  // SECTION TITLES
  // ============================================================

  TextStyle get sectionTitle =>
      AppTextStyles.sectionTitle.copyWith(color: _primaryText);

  TextStyle get sectionSubtitle =>
      AppTextStyles.sectionSubtitle.copyWith(color: _secondaryText);

  // ============================================================
  // CARD STYLES
  // ============================================================

  TextStyle get cardTitle =>
      AppTextStyles.cardTitle.copyWith(color: _cardText);

  TextStyle get cardSubtitle =>
      AppTextStyles.cardSubtitle.copyWith(color: _secondaryText);

  TextStyle get cardValue =>
      AppTextStyles.cardValue.copyWith(color: _cardText);

  TextStyle get cardDescription =>
      AppTextStyles.cardDescription.copyWith(color: _secondaryText);

  // ============================================================
  // BODY TEXT
  // ============================================================

  TextStyle get bodyLarge =>
      AppTextStyles.bodyLarge.copyWith(color: _primaryText);

  TextStyle get body =>
      AppTextStyles.body.copyWith(color: _primaryText);

  TextStyle get bodyMedium =>
      AppTextStyles.bodyMedium.copyWith(color: _primaryText);

  TextStyle get bodySmall =>
      AppTextStyles.bodySmall.copyWith(color: _secondaryText);

  // ============================================================
  // LABELS
  // ============================================================

  TextStyle get labelLarge =>
      AppTextStyles.labelLarge.copyWith(color: _primaryText);

  TextStyle get label =>
      AppTextStyles.label.copyWith(color: _primaryText);

  TextStyle get labelSmall =>
      AppTextStyles.labelSmall.copyWith(color: _secondaryText);

  // ============================================================
  // INPUT FIELD STYLES
  // ============================================================

  TextStyle get input =>
      AppTextStyles.input.copyWith(color: _primaryText);

  TextStyle get inputHint =>
      AppTextStyles.inputHint.copyWith(color: _secondaryText);

  TextStyle get inputLabel =>
      AppTextStyles.inputLabel.copyWith(color: _secondaryText);

  TextStyle get inputError =>
      AppTextStyles.inputError.copyWith(color: _error);

  // ============================================================
  // BUTTON STYLES
  // ============================================================

  TextStyle get buttonLarge =>
      AppTextStyles.buttonLarge.copyWith(color: _onPrimary);

  TextStyle get button =>
      AppTextStyles.button.copyWith(color: _onPrimary);

  TextStyle get buttonSmall =>
      AppTextStyles.buttonSmall.copyWith(color: _onPrimary);

  // For secondary or text buttons.
  TextStyle get textButton =>
      AppTextStyles.button.copyWith(color: _primary);

  // ============================================================
  // NAVIGATION
  // ============================================================

  TextStyle get navigationLabel =>
      AppTextStyles.navigationLabel.copyWith(
        color: _secondaryText,
      );

  TextStyle get navigationLabelSelected =>
      AppTextStyles.navigationLabelSelected.copyWith(
        color: _primary,
      );

  // ============================================================
  // DIALOGS
  // ============================================================

  TextStyle get dialogTitle =>
      AppTextStyles.dialogTitle.copyWith(color: _primaryText);

  TextStyle get dialogBody =>
      AppTextStyles.dialogBody.copyWith(color: _primaryText);

  // ============================================================
  // CAPTIONS AND HELPER TEXT
  // ============================================================

  TextStyle get caption =>
      AppTextStyles.caption.copyWith(color: _secondaryText);

  TextStyle get helperText =>
      AppTextStyles.helperText.copyWith(color: _secondaryText);

  // ============================================================
  // BADGES / CHIPS
  // ============================================================

  TextStyle get badge =>
      AppTextStyles.badge.copyWith(color: _onPrimary);

  TextStyle get chip =>
      AppTextStyles.chip.copyWith(color: _primaryText);

  // ============================================================
  // LIST ITEMS
  // ============================================================

  TextStyle get listTitle =>
      AppTextStyles.listTitle.copyWith(color: _primaryText);

  TextStyle get listSubtitle =>
      AppTextStyles.listSubtitle.copyWith(color: _secondaryText);

  // ============================================================
  // TABLES AND REPORTS
  // ============================================================

  TextStyle get tableHeader =>
      AppTextStyles.tableHeader.copyWith(color: _primaryText);

  TextStyle get tableCell =>
      AppTextStyles.tableCell.copyWith(color: _primaryText);

  // ============================================================
  // APP BAR
  // ============================================================

  TextStyle get appBarTitle =>
      AppTextStyles.appBarTitle.copyWith(
        color: Theme.of(context).appBarTheme.foregroundColor ??
            _primaryText,
      );

  TextStyle get appBarSubtitle =>
      AppTextStyles.appBarSubtitle.copyWith(
        color: (Theme.of(context).appBarTheme.foregroundColor ??
                _primaryText)
            .withValues(alpha: 0.80),
      );

  // ============================================================
  // SPECIAL TEXT STYLES
  // ============================================================

  // White/dark contrasting text on a primary-colored background.
  TextStyle get onPrimaryBody =>
      AppTextStyles.body.copyWith(color: _onPrimary);

  TextStyle get onPrimaryTitle =>
      AppTextStyles.headingMedium.copyWith(color: _onPrimary);

  // Theme primary-colored text.
  TextStyle get primaryText =>
      AppTextStyles.bodyMedium.copyWith(color: _primary);

  // Error messages.
  TextStyle get errorText =>
      AppTextStyles.bodySmall.copyWith(color: _error);

  // ============================================================
  // CUSTOM STYLE HELPER
  // ============================================================

  TextStyle customize(
    TextStyle base, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
    double? letterSpacing,
  }) {
    return base.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }
}
