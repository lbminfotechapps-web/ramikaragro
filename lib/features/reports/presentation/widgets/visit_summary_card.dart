import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import '../../domain/entities/visit_report.dart';

class VisitSummaryCard extends StatelessWidget {
  final VisitReport report;

  const VisitSummaryCard({super.key, required this.report});

  bool get isPresent {
    return report.status.toLowerCase() == 'present';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: .035),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // ============================================================
          // HEADER
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
            child: Row(
              children: [
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    color: isPresent
                        ? context.primaryColor.withValues(alpha: 0.08)
                        : context.appColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    isPresent
                        ? Icons.person_pin_circle_outlined
                        : Icons.person_off_outlined,
                    color: isPresent
                        ? context.primaryColor
                        : context.appColors.error,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 9),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.empName.isEmpty ? 'Employee' : report.empName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.listTitle.copyWith(
                          color: context.cardTextColor,
                        ),
                      ),

                      // const SizedBox(height: 1),

                      // Text(
                      //   report.empCode,
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(
                      //     fontSize: 10.5,
                      //     color: context.secondaryTextColor,
                      //     fontWeight: FontWeight.w600,
                      //   ),
                      // ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),

                _StatusBadge(status: report.status),
              ],
            ),
          ),

          Divider(height: 1, thickness: .7, indent: 12, endIndent: 12),

          // ============================================================
          // DATE
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 5),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: context.secondaryTextColor,
                ),

                const SizedBox(width: 5),

                Text(
                  'Date',
                  style: AppTextStyles.caption.copyWith(
                    color: context.secondaryTextColor,
                  ),
                ),

                const Spacer(),

                Text(
                  _displayValue(report.date),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.cardTextColor,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // IN / OUT
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.login_rounded,
                    title: 'IN Time',
                    value: _displayValue(report.inTime),
                    iconColor: context.primaryColor,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.logout_rounded,
                    title: 'OUT Time',
                    value: _displayValue(report.outTime),
                    iconColor: context.appColors.error,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // VISITS
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.storefront_outlined,
                    title: 'Dealer Visits',
                    value: _displayValue(report.dealerVisit),
                    iconColor: context.appColors.secondary,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.agriculture_outlined,
                    title: 'Farmer Visits',
                    value: _displayValue(report.farmerVisit),
                    iconColor: context.primaryColor,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // KM / TIME
          // ============================================================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.route_outlined,
                    title: 'Total KM',
                    value: _displayValue(report.totalKm),
                    iconColor: context.primaryColor,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.timer_outlined,
                    title: 'Total Time',
                    value: _displayValue(report.totalTime),
                    iconColor: context.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          // ============================================================
          // EXPENSE / MAP KM
          // ============================================================
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 3, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.currency_rupee_rounded,
                    title: 'Expense',
                    value: _displayValue(report.expenseAmount),
                    iconColor: context.appColors.secondary,
                  ),
                ),

                const SizedBox(width: 7),

                Expanded(
                  child: _InfoItem(
                    icon: Icons.location_on_outlined,
                    title: 'On Map KM',
                    value: _displayValue(report.onMapKm),
                    iconColor: context.appColors.tertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _displayValue(String value) {
    if (value.trim().isEmpty) {
      return '-';
    }

    return value;
  }
}

// ========================================================================
// STATUS BADGE
// ========================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final bool present = status.toLowerCase() == 'present';

    final Color background = present
        ? context.primaryColor.withValues(alpha: 0.08)
        : context.appColors.error.withValues(alpha: 0.08);

    final Color foreground = present
        ? context.primaryColor
        : context.appColors.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            present ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 12,
            color: foreground,
          ),

          const SizedBox(width: 3),

          Text(
            status.isEmpty ? 'Unknown' : status,
            style: AppTextStyles.labelSmall.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

// ========================================================================
// INFO ITEM
// ========================================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: context.appColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),

          const SizedBox(width: 6),

          Expanded(
            child: Column(
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
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.cardTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
