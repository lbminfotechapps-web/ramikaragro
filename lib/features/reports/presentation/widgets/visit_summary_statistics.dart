import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

class VisitSummaryStatistics extends StatelessWidget {
  final int total;
  final int present;
  final int absent;
  final int dealerVisits;
  final int farmerVisits;

  const VisitSummaryStatistics({
    super.key,
    required this.total,
    required this.present,
    required this.absent,
    required this.dealerVisits,
    required this.farmerVisits,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Summary',
          style: AppTextStyles.cardTitle.copyWith(color: context.cardTextColor),
        ),

        const SizedBox(height: 7),

        // ============================================================
        // TOTAL / PRESENT / ABSENT
        // ============================================================
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Total',
                value: total,
                icon: Icons.list_alt_rounded,
                iconColor: context.primaryColor,
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: _StatCard(
                title: 'Present',
                value: present,
                icon: Icons.check_circle_outline_rounded,
                iconColor: context.primaryColor,
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: _StatCard(
                title: 'Absent',
                value: absent,
                icon: Icons.cancel_outlined,
                iconColor: context.appColors.error,
              ),
            ),
          ],
        ),

        const SizedBox(height: 7),

        // ============================================================
        // DEALER / FARMER
        // ============================================================
        Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Dealer Visits',
                value: dealerVisits,
                icon: Icons.storefront_outlined,
                iconColor: context.appColors.secondary,
              ),
            ),

            const SizedBox(width: 7),

            Expanded(
              child: _StatCard(
                title: 'Farmer Visits',
                value: farmerVisits,
                icon: Icons.agriculture_outlined,
                iconColor: context.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ========================================================================
// STAT CARD
// ========================================================================

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,

      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),

      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(11),

        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .035),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),

      child: Row(
        children: [
          // ============================================================
          // ICON
          // ============================================================
          Container(
            height: 30,
            width: 30,

            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(8),
            ),

            child: Icon(icon, color: iconColor, size: 17),
          ),

          const SizedBox(width: 7),

          // ============================================================
          // TEXT
          // ============================================================
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),

                const SizedBox(height: 1),

                Text(
                  '$value',

                  style: AppTextStyles.headingMedium.copyWith(color: iconColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
