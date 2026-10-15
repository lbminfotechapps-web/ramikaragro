import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import '../../domain/entities/notification.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;

  const NotificationCard({super.key, required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 13),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.055),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(context),

                const SizedBox(width: 13),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.body.copyWith(
                          color: context.cardTextColor,
                        ),
                      ),

                      // const SizedBox(height: 5),

                      // Text(
                      //   '#${notification.notificationId}',
                      //   style: TextStyle(
                      //     fontSize: 10.5,
                      //     fontWeight:
                      //         FontWeight.w500,
                      //     color: context.primaryColor
                      //         .withOpacity(0.8),
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
              ],
            ),

            const SizedBox(height: 14),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                notification.message,
                style: AppTextStyles.listTitle.copyWith(
                  height: 1.55,
                  color: context.secondaryTextColor,
                ),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _buildInfoItem(
                  context,
                  icon: Icons.calendar_today_rounded,
                  value: notification.notificationDate,
                ),

                const SizedBox(width: 18),

                _buildInfoItem(
                  context,
                  icon: Icons.access_time_rounded,
                  value: notification.notificationTime,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: context.primaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(
        Icons.notifications_active_rounded,
        color: context.onPrimaryColor,
        size: 23,
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String value,
  }) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: context.primaryColor),

          const SizedBox(width: 6),

          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.labelSmall.copyWith(
                color: context.secondaryTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
