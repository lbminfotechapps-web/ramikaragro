import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  // Main title
  final String? title;

  // Optional subtitle
  final String? subtitle;

  // Dynamic title style
  final TextStyle? titleStyle;

  // Dynamic subtitle style
  final TextStyle? subtitleStyle;

  // Home/profile data
  final String? userName;
  final String? initials;

  // Notification
  final int notificationCount;
  final VoidCallback? onLogOutTap;

  // Generic right-side icon
  final IconData? actionIcon;
  final VoidCallback? onActionIconTap;

  // Back button
  final bool showBackButton;
  final VoidCallback? onBackTap;

  // Optional leading widget
  final Widget? leading;

  // Optional custom action
  final Widget? action;

  // App bar appearance
  final Color backgroundColor;
  final double toolbarHeight;

  const CustomAppBar({
    super.key,

    this.title,
    this.subtitle,

    // Dynamic styles
    this.titleStyle,
    this.subtitleStyle,

    this.userName,
    this.initials,

    // Notification
    this.notificationCount = 0,
    this.onLogOutTap,

    // Generic action icon
    this.actionIcon,
    this.onActionIconTap,

    // Back
    this.showBackButton = false,
    this.onBackTap,

    // Leading / custom action
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
      elevation: 2,
      toolbarHeight: toolbarHeight,
      titleSpacing: 16,
      shadowColor: Colors.black.withOpacity(0.12),

      title: Row(
        children: [
          // ------------------------------------------------
          // LEADING
          // ------------------------------------------------
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

          // ------------------------------------------------
          // PROFILE
          // ------------------------------------------------
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

          // ------------------------------------------------
          // TITLE / SUBTITLE / USER NAME
          // ------------------------------------------------
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // TITLE
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

                // SUBTITLE
                if (subtitle != null)
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

                if (subtitle != null && title != null)
                  const SizedBox(height: 2),

                // USER NAME
                if (userName != null)
                  Text(
                    userName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        titleStyle ??
                        const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                  ),
              ],
            ),
          ),

          // ------------------------------------------------
          // CUSTOM ACTION
          // ------------------------------------------------
          if (action != null) ...[const SizedBox(width: 10), action!],

          // ------------------------------------------------
          // GENERIC ACTION ICON
          // ------------------------------------------------
          if (actionIcon != null && onActionIconTap != null) ...[
            const SizedBox(width: 10),

            GestureDetector(
              onTap: onActionIconTap,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF7FBF3),
                ),
                child: Icon(
                  actionIcon,
                  size: 28,
                  color: const Color(0xFF16803A),
                ),
              ),
            ),
          ],

          // ------------------------------------------------
          // NOTIFICATION
          // ------------------------------------------------
          if (onLogOutTap != null) ...[
            const SizedBox(width: 10),

            GestureDetector(
              onTap: onLogOutTap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
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

                  if (notificationCount > 0)
                    Positioned(
                      right: 2,
                      top: 1,
                      child: Container(
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: notificationCount < 10
                              ? BoxShape.circle
                              : BoxShape.rectangle,
                          borderRadius: notificationCount >= 10
                              ? BorderRadius.circular(10)
                              : null,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: notificationCount >= 10
                            ? Text(
                                notificationCount > 99
                                    ? '99+'
                                    : notificationCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            : const SizedBox(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
