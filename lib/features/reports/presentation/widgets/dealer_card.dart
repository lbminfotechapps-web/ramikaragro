import 'package:solufine/core/theme/typography/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:solufine/core/theme/app_theme_context.dart';

import '../../domain/entities/not_visited_dealer.dart';

class DealerCard extends StatelessWidget {
  final NotVisitedDealer dealer;

  const DealerCard({super.key, required this.dealer});

  @override
  Widget build(BuildContext context) {
    final name = dealer.outletName.trim().isNotEmpty
        ? dealer.outletName.trim()
        : 'Unknown Dealer';

    final initials = _getInitials(name);
    final hasMobile = dealer.mobile.trim().isNotEmpty;
    final hasAddress = dealer.address.trim().isNotEmpty;
    final lastVisit = dealer.lastTransactionDate?.trim();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: context.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.appColors.shadow.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =====================================================
          // HEADER
          // =====================================================
          Row(
            children: [
              // Avatar
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: BorderRadius.circular(13),
                ),
                alignment: Alignment.center,
                child: Text(
                  initials,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: context.onPrimaryColor,
                  ),
                ),
              ),

              SizedBox(width: 11),

              // Name + ID
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.cardTitle.copyWith(
                        color: context.cardTextColor,
                      ),
                    ),
                    // SizedBox(height: 3),
                    // Text(
                    //   'Dealer ID: ${dealer.outletId}',
                    //   style: TextStyle(
                    //     fontSize: 11,
                    //     color: context.secondaryTextColor,
                    //   ),
                    // ),
                  ],
                ),
              ),

              // Status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: context.appColors.secondary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Not Visited',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: context.appColors.secondary,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 11),

          // =====================================================
          // MOBILE + LAST VISIT
          // =====================================================
          Row(
            children: [
              if (hasMobile)
                Expanded(
                  child: _InfoItem(
                    icon: Icons.phone_rounded,
                    text: dealer.mobile,
                  ),
                ),

              if (hasMobile) SizedBox(width: 10),

              Expanded(
                child: _InfoItem(
                  icon: Icons.calendar_today_rounded,
                  text: lastVisit?.isNotEmpty == true ? lastVisit! : 'Never',
                  iconColor: lastVisit?.isNotEmpty == true
                      ? context.primaryColor
                      : context.appColors.secondary,
                ),
              ),
            ],
          ),

          // =====================================================
          // ADDRESS
          // =====================================================
          if (hasAddress) ...[
            SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: 17,
                  color: context.primaryColor,
                ),
                SizedBox(width: 7),
                Expanded(
                  child: Text(
                    dealer.address,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      height: 1.3,
                      color: context.secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =============================================================
  // INITIALS
  // =============================================================

  String _getInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'D';
    }

    if (parts.length == 1) {
      return parts.first
          .substring(0, parts.first.length >= 2 ? 2 : 1)
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}

// =============================================================
// INFO ITEM
// =============================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;

  const _InfoItem({required this.icon, required this.text, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor ?? context.primaryColor),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: context.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }
}
