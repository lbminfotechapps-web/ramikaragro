
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';
import 'package:solufine/core/theme/app_theme_colors.dart';
import 'package:solufine/core/theme/app_theme_extension.dart';
import 'package:solufine/core/theme/app_theme_palette.dart';
class AppColor {
  AppColor._();

  // ============================================================
  // LEGACY DEFAULT GRADIENT
  // ============================================================
  //
  // Kept temporarily for existing widgets.
  // This is STATIC and will not change when a user selects a theme.
  // We will migrate its usages to context.appTheme in later steps.
  //
  static const BoxDecoration appGradientDecoration = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF3F9D39),
        Color(0xFFA9E6A5),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ============================================================
  // DYNAMIC THEME GENERATOR
  // ============================================================

  static ThemeData getLightTheme([
    AppThemePalette palette = AppThemeColors.defaultTheme,
  ]) {
    final bool isDark = palette.id == AppThemeColors.charcoalDark.id;

    final ColorScheme colorScheme = ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      secondary: palette.secondary,
      onSecondary: palette.onSecondary,
      surface: palette.surface,
      onSurface: palette.onSurface,
      error: isDark
          ? const Color(0xFFE57373)
          : const Color(0xFFD32F2F),
      onError: isDark ? Colors.black : Colors.white,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,

      // ========================================================
      // MAIN COLORS
      // ========================================================

      primaryColor: palette.primary,
   scaffoldBackgroundColor:
    isDark ? Colors.black : Colors.white,

canvasColor:
    isDark ? Colors.black : Colors.white,
      dividerColor: palette.border,
      disabledColor: palette.textSecondary.withValues(alpha: 0.5),

      // ========================================================
      // APP BAR
      // ========================================================

      appBarTheme: AppBarTheme(
        backgroundColor: palette.appBarBackground,
        foregroundColor: palette.appBarForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: palette.appBarForeground,
        ),
        actionsIconTheme: IconThemeData(
          color: palette.appBarForeground,
        ),
        titleTextStyle: TextStyle(
          color: palette.appBarForeground,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ========================================================
      // CARDS
      // ========================================================

      cardColor: palette.cardBackground,

      cardTheme: CardThemeData(
        color: palette.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
          side: BorderSide(
            color: palette.border,
            width: 0.5,
          ),
        ),
      ),

      // ========================================================
      // ELEVATED BUTTONS
      // ========================================================

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          disabledBackgroundColor:
              palette.primary.withValues(alpha: 0.35),
          disabledForegroundColor:
              palette.onPrimary.withValues(alpha: 0.7),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),

      // ========================================================
      // TEXT BUTTONS
      // ========================================================

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: palette.primary,
        ),
      ),

      // ========================================================
      // OUTLINED BUTTONS
      // ========================================================

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: palette.primary,
          side: BorderSide(color: palette.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),

      // ========================================================
      // FLOATING ACTION BUTTON
      // ========================================================

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
      ),

      // ========================================================
      // INPUT DECORATION
      // ========================================================

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.inputBackground,

        hintStyle: TextStyle(
          color: palette.textSecondary,
        ),

        labelStyle: TextStyle(
          color: palette.textSecondary,
        ),

        floatingLabelStyle: TextStyle(
          color: palette.primary,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: palette.border,
          ),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: palette.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: palette.primary,
            width: 1.5,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: colorScheme.error,
          ),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: 1.5,
          ),
        ),
      ),

      // ========================================================
      // TEXT THEME
      // ========================================================

      textTheme: TextTheme(
        displayLarge: TextStyle(color: palette.textPrimary),
        displayMedium: TextStyle(color: palette.textPrimary),
        displaySmall: TextStyle(color: palette.textPrimary),

        headlineLarge: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineSmall: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.bold,
        ),

        titleLarge: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleSmall: TextStyle(
          color: palette.textPrimary,
          fontWeight: FontWeight.w600,
        ),

        bodyLarge: TextStyle(color: palette.textPrimary),
        bodyMedium: TextStyle(color: palette.textPrimary),
        bodySmall: TextStyle(color: palette.textSecondary),

        labelLarge: TextStyle(color: palette.textPrimary),
        labelMedium: TextStyle(color: palette.textPrimary),
        labelSmall: TextStyle(color: palette.textSecondary),
      ),

      // ========================================================
      // ICONS
      // ========================================================

      iconTheme: IconThemeData(
        color: palette.textPrimary,
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.textSecondary,
        selectedIconTheme: IconThemeData(color: palette.primary),
        unselectedIconTheme:
            IconThemeData(color: palette.textSecondary),
        type: BottomNavigationBarType.fixed,
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.primary.withValues(alpha: 0.15),
      ),

      // ========================================================
      // TABS
      // ========================================================

      tabBarTheme: TabBarThemeData(
        labelColor: palette.primary,
        unselectedLabelColor: palette.textSecondary,
        indicatorColor: palette.primary,
        dividerColor: palette.border,
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================

      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
      ),

      // ========================================================
      // SWITCHES / CHECKBOXES
      // ========================================================

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return null;
        }),
        checkColor: WidgetStatePropertyAll(palette.onPrimary),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.onPrimary;
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return palette.primary;
          }
          return null;
        }),
      ),

      // ========================================================
      // DIALOGS AND BOTTOM SHEETS
      // ========================================================

      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        titleTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: palette.textPrimary,
          fontSize: 14,
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.surface,
        modalBackgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================

      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.primary,
        contentTextStyle: TextStyle(
          color: palette.onPrimary,
        ),
        behavior: SnackBarBehavior.floating,
      ),

      

      extensions: [
        AppThemeExtension.fromPalette(palette),
      ],
    );
  }
}