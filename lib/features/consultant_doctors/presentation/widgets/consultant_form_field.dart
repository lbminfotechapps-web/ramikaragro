
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';

class ConsultantFormField {
  ConsultantFormField._();

  // ============================================================
  // MODERN COMPACT INPUT DECORATION
  // ============================================================

  static InputDecoration decoration(
    BuildContext context,
    String label, {
    IconData? icon,
    String? hint,
    bool isValid = false,
    bool enabled = true,
    Widget? suffixIcon,
    String? helperText,
  }) {
    final primary = context.appPrimary;
    final borderColor = context.appBorder;
    final subText = context.appSubText;
    final background = context.appInputBackground;
    final error = context.appError;

    OutlineInputBorder outline(
      Color color, {
      double width = 1,
    }) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return InputDecoration(
      // ==========================================================
      // LABEL & HINT
      // ==========================================================
      labelText: label,
      hintText: hint,

      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: subText,
      ),

      floatingLabelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: primary,
      ),

      hintStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: subText.withValues(alpha: 0.75),
      ),

      // ==========================================================
      // LEADING ICON
      // ==========================================================
      prefixIcon: icon == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(
                left: 9,
                right: 8,
              ),
              child: Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  icon,
                  size: 17,
                  color: enabled ? primary : subText,
                ),
              ),
            ),

      prefixIconConstraints: const BoxConstraints(
        minWidth: 48,
        minHeight: 42,
      ),

      // ==========================================================
      // TRAILING ICON
      // ==========================================================
      suffixIcon: suffixIcon,

      suffixIconConstraints: const BoxConstraints(
        minWidth: 38,
        minHeight: 38,
      ),

      // ==========================================================
      // BACKGROUND
      // ==========================================================
      filled: true,
      fillColor: enabled
          ? background
          : background.withValues(alpha: 0.6),

      // ==========================================================
      // COMPACT SPACING
      // ==========================================================
      isDense: true,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 13,
      ),

      // ==========================================================
      // BORDERS
      // ==========================================================
      border: outline(borderColor),

      enabledBorder: outline(
        isValid ? primary : borderColor,
      ),

      focusedBorder: outline(
        primary,
        width: 1.6,
      ),

      disabledBorder: outline(
        borderColor.withValues(alpha: 0.55),
      ),

      errorBorder: outline(error),

      focusedErrorBorder: outline(
        error,
        width: 1.5,
      ),

      // ==========================================================
      // ERROR / HELPER
      // ==========================================================
      helperText: helperText,

      helperStyle: TextStyle(
        fontSize: 10,
        color: subText,
      ),

      errorStyle: TextStyle(
        color: error,
        fontSize: 10,
        height: 1.1,
      ),

      errorMaxLines: 2,

      // Hide character counter for compact UI.
      counterText: '',
    );
  }
}
