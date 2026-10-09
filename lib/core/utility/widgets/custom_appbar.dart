import 'package:flutter/material.dart';

import 'package:solufine/core/theme/app_theme_context.dart';
import 'package:solufine/core/theme/theme_picker_sheet.dart';

// Adjust the imports above to match your actual project folders.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  final String? userName;
  final String? initials;

  // Login / Logout
  final bool showLogin;
  final bool showLogout;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogOutTap;

  // Generic right-side icon
  final IconData? actionIcon;
  final VoidCallback? onActionIconTap;

  // Back button
  final bool showBackButton;
  final VoidCallback? onBackTap;

  // Optional widgets
  final Widget? leading;
  final Widget? action;

  // Appearance
  // Nullable so the selected theme is used by default.
  final Color? backgroundColor;
  final double toolbarHeight;

  // Theme selection
  final bool showThemeButton;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.userName,
    this.initials,
    this.showLogin = false,
    this.showLogout = false,
    this.onLoginTap,
    this.onLogOutTap,
    this.actionIcon,
    this.onActionIconTap,
    this.showBackButton = false,
    this.onBackTap,
    this.leading,
    this.action,
    this.backgroundColor,
    this.toolbarHeight = 60,

    // Automatically show palette icon on every CustomAppBar.
    this.showThemeButton = true,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final appBarTheme = theme.appBarTheme;

    final Color effectiveBackground =
        backgroundColor ?? appBarTheme.backgroundColor ?? colors.surface;

    final Color foreground = backgroundColor == null
        ? (appBarTheme.foregroundColor ?? colors.onSurface)
        : colors.onSurface;

    final Color primaryColor = colors.primary;
    final Color onPrimaryColor = colors.onPrimary;

    final Color secondaryTextColor = context.secondaryTextColor;

    // Theme-aware background for action icons.
    final Color iconBackground = foreground.withValues(alpha: 0.09);

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: effectiveBackground,
      foregroundColor: foreground,
      surfaceTintColor: Colors.transparent,
      elevation: 2,
      toolbarHeight: toolbarHeight,
      titleSpacing: 12,
      shadowColor: colors.shadow.withValues(alpha: 0.12),

      shape: Border(
        bottom: BorderSide(
          color: primaryColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),

      title: Row(
        children: [
          // ====================================================
          // LEADING
          // ====================================================
          if (leading != null)
            leading!
          else if (showBackButton)
            IconButton(
              tooltip: 'Back',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 40),
              onPressed: onBackTap ?? () => Navigator.maybePop(context),
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: foreground,
              ),
            ),

          if (leading != null || showBackButton) const SizedBox(width: 8),

          // ====================================================
          // PROFILE INITIALS
          // ====================================================
          if (initials != null) ...[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.12),
                border: Border.all(color: primaryColor.withValues(alpha: 0.25)),
              ),
              alignment: Alignment.center,
              child: Text(
                initials!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
          ],

          // ====================================================
          // TITLE / SUBTITLE / USER NAME
          // ====================================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ).merge(titleStyle),
                  ),

                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: foreground.withValues(alpha: 0.75),
                    ).merge(subtitleStyle),
                  ),
                ],

                if (userName != null)
                  Text(
                    userName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: foreground,
                    ).merge(titleStyle),
                  ),
              ],
            ),
          ),

          // ====================================================
          // CUSTOM ACTION
          // ====================================================
          if (action != null) ...[const SizedBox(width: 4), action!],

          // ====================================================
          // GENERIC ACTION ICON
          // ====================================================
          if (actionIcon != null && onActionIconTap != null) ...[
            const SizedBox(width: 4),
            _AppBarCircleButton(
              icon: actionIcon!,
              tooltip: 'Action',
              backgroundColor: iconBackground,
              foregroundColor: foreground,
              onTap: onActionIconTap!,
            ),
          ],

          // ====================================================
          // LOGIN BUTTON
          // ====================================================
          if (showLogin) ...[
            const SizedBox(width: 4),
            Material(
              color: primaryColor,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onLoginTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.login_rounded,
                        size: 17,
                        color: onPrimaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Login',
                        style: TextStyle(
                          color: onPrimaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],

          // ====================================================
          // LOGOUT BUTTON
          // ====================================================
          if (showLogout) ...[
            const SizedBox(width: 4),
            _AppBarCircleButton(
              icon: Icons.logout_outlined,
              tooltip: 'Logout',
              backgroundColor: iconBackground,
              foregroundColor: foreground,
              onTap: onLogOutTap ?? () {},
            ),
          ],

          // ====================================================
          // THEME CHANGE ICON
          // ====================================================
          if (showThemeButton) ...[
            const SizedBox(width: 4),
            _AppBarCircleButton(
              icon: Icons.palette_outlined,
              tooltip: 'Change Theme',
              backgroundColor: primaryColor.withValues(alpha: 0.12),
              foregroundColor: primaryColor,
              onTap: () {
                ThemePickerSheet.show(context);
              },
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// REUSABLE APP BAR ICON BUTTON
// ============================================================

class _AppBarCircleButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onTap;

  const _AppBarCircleButton({
    required this.icon,
    required this.tooltip,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 38,
            height: 38,
            child: Center(child: Icon(icon, size: 20, color: foregroundColor)),
          ),
        ),
      ),
    );
  }
}

/*
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? subtitle;

  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  final String? userName;
  final String? initials;

  // Login / Logout
  final bool showLogin;
  final bool showLogout;
  final VoidCallback? onLoginTap;
  final VoidCallback? onLogOutTap;

  // Generic right-side icon
  final IconData? actionIcon;
  final VoidCallback? onActionIconTap;

  // Back button
  final bool showBackButton;
  final VoidCallback? onBackTap;

  // Optional widgets
  final Widget? leading;
  final Widget? action;

  // Appearance
  final Color backgroundColor;
  final double toolbarHeight;

  const CustomAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.userName,
    this.initials,

    this.showLogin = false,
    this.showLogout = false,
    this.onLoginTap,
    this.onLogOutTap,

    // Generic action
    this.actionIcon,
    this.onActionIconTap,

    // Back
    this.showBackButton = false,
    this.onBackTap,

    // Custom widgets
    this.leading,
    this.action,

    this.backgroundColor = Colors.white,
    this.toolbarHeight = 60,
  });

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
      elevation: 2,
      toolbarHeight: toolbarHeight,
      titleSpacing: 16,
      shadowColor: Colors.black.withOpacity(0.12),

      title: Row(
        children: [
          // ============================================================
          // LEADING
          // ============================================================
          if (leading != null)
            leading!
          else if (showBackButton)
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 20,
                color: AppColors.darkBackgroundColor,
              ),
            ),

          if (leading != null || showBackButton) const SizedBox(width: 12),

          // ============================================================
          // PROFILE
          // ============================================================
          if (initials != null) ...[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 101, 158, 35),
                border: Border.all(color: const Color(0xFFE5E5E5)),
              ),
              alignment: Alignment.center,
              child: Text(
                initials!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF16803A),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // ============================================================
          // TITLE / SUBTITLE / USERNAME
          // ============================================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        titleStyle ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                  ),

                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        subtitleStyle ??
                        const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                  ),
                ],

                if (userName != null)
                  Text(
                    userName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        titleStyle ??
                        const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                  ),
              ],
            ),
          ),

          // ============================================================
          // CUSTOM ACTION
          // ============================================================
          if (action != null) ...[const SizedBox(width: 10), action!],

          // ============================================================
          // GENERIC ACTION ICON
          // ============================================================
          if (actionIcon != null && onActionIconTap != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onActionIconTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF7FBF3),
                ),
                child: Icon(
                  actionIcon,
                  size: 21,
                  color: const Color(0xFF16803A),
                ),
              ),
            ),
          ],

          // ============================================================
          // LOGIN BUTTON
          // ============================================================
          if (showLogin) ...[
            const SizedBox(width: 10),
            InkWell(
              onTap: onLoginTap,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFF16803A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.login_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ============================================================
          // LOGOUT BUTTON
          // ============================================================
          if (showLogout) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: onLogOutTap,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF7FBF3),
                ),
                child: const Icon(
                  Icons.logout_outlined,
                  size: 20,
                  color: Color(0xFF16803A),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
*/
